import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/message/presentation/providers/message_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../widgets/message_bubble.dart';
import '../../domain/entities/message_entity.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../providers/mark_conversation_read_provider.dart';

Future<void> _loadAndMergeAllHostMessages(
  WidgetRef ref,
  String otherUserId,
  String listingId,
  List<String>? allListingIds,
) async {
  final chatVM = ref.read(chatViewModelProvider.notifier);
  List<String> listingIds = allListingIds ?? [listingId];
  List<MessageEntity> messages = [];
  for (final id in listingIds) {
    final msgs = await chatVM.getConversation(otherUserId, id);
    messages.addAll(msgs);
  }
  messages = messages.toSet().toList();
  messages.sort(
    (a, b) =>
        (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
  );
  chatVM.state = chatVM.state.copyWith(messages: messages, loading: false);
  // Mark all conversations as read
  for (final id in listingIds) {
    await ref.read(markConversationReadProvider).call(otherUserId, id);
  }
  ref.read(threadsViewModelProvider.notifier).loadThreads();
}

class ChatPage extends ConsumerStatefulWidget {
  final String otherUserId;
  final String listingId;
  final List<String>? allListingIds;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.listingId,
    this.allListingIds,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    // Load and merge messages from all listings for this host
    Future.microtask(() async {
      final chatVM = ref.read(chatViewModelProvider.notifier);
      List<String> listingIds = widget.allListingIds ?? [widget.listingId];
      List<MessageEntity> messages = [];
      for (final id in listingIds) {
        final msgs = await chatVM.getConversation(widget.otherUserId, id);
        messages.addAll(msgs);
      }
      // Sort and deduplicate messages
      messages = messages.toSet().toList().cast<MessageEntity>();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      chatVM.state = chatVM.state.copyWith(messages: messages, loading: false);
      // Mark all conversations as read
      for (final id in listingIds) {
        await ref
            .read(markConversationReadProvider)
            .call(widget.otherUserId, id);
      }
      ref.read(threadsViewModelProvider.notifier).loadThreads();
    });
    // Listen to new messages and auto-scroll
    ref.read(chatViewModelProvider.notifier).addListener((state) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
    // Socket.io for live updates
    final authState = ref.read(authViewModelProvider);
    final token = authState.authEntity?.token;
    final socketUrl = ApiEndpoints.socketBaseUrl;
    debugPrint('Connecting to socket: $socketUrl');
    if (token != null && token.isNotEmpty && socketUrl.isNotEmpty) {
      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
      });
      _socket!.connect();
      _socket!.onConnect((_) {
        debugPrint('Socket connected (chat)');
        // Optionally join all listing rooms
        for (final id in widget.allListingIds ?? [widget.listingId]) {
          _socket!.emit('joinRoom', id);
        }
      });
      _socket!.on('receiveMessage', (data) async {
        final chatVM = ref.read(chatViewModelProvider.notifier);
        List<String> listingIds = widget.allListingIds ?? [widget.listingId];
        List<MessageEntity> messages = [];
        for (final id in listingIds) {
          final msgs = await chatVM.getConversation(widget.otherUserId, id);
          messages.addAll(msgs);
        }
        messages = messages.toSet().toList();
        messages.sort(
          (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          ),
        );
        chatVM.state = chatVM.state.copyWith(
          messages: messages,
          loading: false,
        );
      });
    }
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(WidgetRef ref) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Prevent sending if IDs are empty
    if (widget.otherUserId.isEmpty || widget.listingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid chat: missing user or listing ID"),
        ),
      );
      return;
    }

    await ref
        .read(chatViewModelProvider.notifier)
        .send(widget.otherUserId, widget.listingId, text);

    await _loadAndMergeAllHostMessages(
      ref,
      widget.otherUserId,
      widget.listingId,
      widget.allListingIds,
    );

    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendMedia(WidgetRef ref) async {
    // Show dialog for image or video
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Image from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMedia(ImageSource.gallery, isVideo: false);
                  await _loadAndMergeAllHostMessages(
                    ref,
                    widget.otherUserId,
                    widget.listingId,
                    widget.allListingIds,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Video from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMedia(ImageSource.gallery, isVideo: true);
                  await _loadAndMergeAllHostMessages(
                    ref,
                    widget.otherUserId,
                    widget.listingId,
                    widget.allListingIds,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMedia(ImageSource.camera, isVideo: false);
                  await _loadAndMergeAllHostMessages(
                    ref,
                    widget.otherUserId,
                    widget.listingId,
                    widget.allListingIds,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Record Video"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMedia(ImageSource.camera, isVideo: true);
                  await _loadAndMergeAllHostMessages(
                    ref,
                    widget.otherUserId,
                    widget.listingId,
                    widget.allListingIds,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    // Request permissions
    if (source == ImageSource.gallery) {
      final galleryStatus = await Permission.photos.request();
      if (!galleryStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gallery permission denied")),
        );
        return;
      }
    } else if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    }

    XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: source);
    } else {
      pickedFile = await _picker.pickImage(source: source);
    }
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        // Upload file to backend (single file)
        final mediaUploadDatasource = ref.read(mediaUploadDatasourceProvider);
        final uploaded = await mediaUploadDatasource.uploadSingle(
          pickedFile.path,
        );
        final fileUrl = uploaded['url'] ?? uploaded['path'] ?? '';
        if (fileUrl.isNotEmpty) {
          // Determine mimeType
          String mimeType = '';
          if (isVideo) {
            if (fileUrl.endsWith('.mp4')) {
              mimeType = 'video/mp4';
            } else if (fileUrl.endsWith('.mov')) {
              mimeType = 'video/quicktime';
            } else {
              mimeType = 'video/*';
            }
          } else {
            if (fileUrl.endsWith('.png')) {
              mimeType = 'image/png';
            } else if (fileUrl.endsWith('.jpg') || fileUrl.endsWith('.jpeg')) {
              mimeType = 'image/jpeg';
            } else if (fileUrl.endsWith('.gif')) {
              mimeType = 'image/gif';
            } else {
              mimeType = 'image/*';
            }
          }
          await ref
              .read(chatViewModelProvider.notifier)
              .sendMedia(
                widget.otherUserId,
                widget.listingId,
                fileUrl,
                isVideo ? 'video' : 'image',
                mimeType,
              );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;

    // Determine other user's name and avatar from the first message
    String otherUserName = 'User';
    String? otherUserAvatar;
    if (state.messages.isNotEmpty) {
      final firstMsg = state.messages.first;
      final isMeSender =
          currentUserId != null && firstMsg.senderId == currentUserId;
      if (isMeSender) {
        otherUserName = firstMsg.receiverName ?? 'User';
        otherUserAvatar = firstMsg.receiverProfilePicture;
      } else {
        otherUserName = firstMsg.senderName ?? 'User';
        otherUserAvatar = firstMsg.senderProfilePicture;
      }
      // Normalize avatar URL if needed
      if (otherUserAvatar != null && otherUserAvatar.startsWith('/uploads/')) {
        otherUserAvatar = ApiEndpoints.staticBaseUrl + otherUserAvatar;
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF1976D2),
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[400],
                backgroundImage:
                    (otherUserAvatar != null && otherUserAvatar.isNotEmpty)
                    ? NetworkImage(otherUserAvatar)
                    : const AssetImage('assets/images/default_avatar.jpg')
                          as ImageProvider,
                child: (otherUserAvatar == null || otherUserAvatar.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
                onBackgroundImageError: (_, _) {},
              ),
              SizedBox(width: 12),
              Text(
                otherUserName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.messages.isEmpty
                  ? const Center(child: Text('No messages yet.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _loadAndMergeAllHostMessages(
                          ref,
                          widget.otherUserId,
                          widget.listingId,
                          widget.allListingIds,
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 0,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe =
                              currentUserId != null &&
                              msg.senderId == currentUserId;
                          return MessageBubble(
                            message: msg,
                            isMe: isMe,
                            otherUserId: widget.otherUserId,
                            listingId: widget.listingId,
                            headerName: otherUserName,
                            headerAvatar: otherUserAvatar,
                          );
                        },
                      ),
                    ),
            ),
            _buildInputBar(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(WidgetRef ref) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Attach icon
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.attach_file_rounded, color: Colors.grey[700]),
                onPressed: _isUploading ? null : () => _pickAndSendMedia(ref),
                splashRadius: 22,
              ),
            ),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Message",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Send icon
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976D2).withOpacity(0.18),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _sendMessage(ref),
                splashRadius: 24,
              ),
            ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
