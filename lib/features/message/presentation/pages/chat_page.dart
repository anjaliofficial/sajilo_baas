import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/message/presentation/providers/message_providers.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String otherUserId;
  final String listingId;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.listingId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial conversation
    Future.microtask(
      () => ref
          .read(chatViewModelProvider.notifier)
          .load(widget.otherUserId, widget.listingId),
    );

    // Listen to new messages and auto-scroll
    ref.read(chatViewModelProvider.notifier).addListener((state) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref
        .read(chatViewModelProvider.notifier)
        .send(widget.otherUserId, widget.listingId, text);

    _controller.clear();
    _scrollToBottom();
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
              otherUserAvatar != null && otherUserAvatar.isNotEmpty
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: NetworkImage(otherUserAvatar),
                      onBackgroundImageError: (_, __) {},
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      child: Icon(Icons.person, color: Colors.white, size: 24),
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
                        await ref
                            .read(chatViewModelProvider.notifier)
                            .load(widget.otherUserId, widget.listingId);
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
                          );
                        },
                      ),
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
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
                onPressed: () {},
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
                onPressed: _sendMessage,
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
