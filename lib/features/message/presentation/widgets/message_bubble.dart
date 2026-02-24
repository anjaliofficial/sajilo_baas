import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import 'package:sajilo_baas/features/message/presentation/providers/message_providers.dart';
import 'package:sajilo_baas/features/message/presentation/pages/chat_page.dart';

class MessageBubble extends ConsumerWidget {
  final MessageEntity message;
  final bool isMe;
  final String otherUserId;
  final String listingId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.otherUserId,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? displayName = isMe
        ? message.senderName
        : message.receiverName;
    final String? profilePicture = isMe
        ? message.senderProfilePicture
        : message.receiverProfilePicture;

    final String shownName = (displayName == null || displayName.isEmpty)
        ? (isMe ? 'You' : 'Unknown')
        : displayName;
    final String? shownProfilePicture =
        (profilePicture == null || profilePicture.isEmpty)
        ? null
        : profilePicture;

    // Debug print for troubleshooting avatar display
    print(
      'MessageBubble: isMe=$isMe, shownProfilePicture=$shownProfilePicture',
    );

    final timeString = TimeOfDay.fromDateTime(
      message.createdAt,
    ).format(context);

    return Semantics(
      label: 'Message from $shownName at $timeString',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Builder(
                builder: (context) {
                  final isNetwork =
                      shownProfilePicture != null &&
                      shownProfilePicture.isNotEmpty;
                  print(
                    'Avatar loading: isNetwork=$isNetwork, url=$shownProfilePicture',
                  );
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[400],
                    backgroundImage: isNetwork
                        ? NetworkImage(shownProfilePicture)
                        : const AssetImage('assets/images/default_avatar.jpg'),
                    child: (!isNetwork)
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                    onBackgroundImageError: (_, __) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avatar image failed to load!'),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(width: 8),
            ],
            Flexible(
              child: isMe
                  ? GestureDetector(
                      onLongPress: () async {
                        final now = DateTime.now();
                        final canEdit =
                            now.difference(message.createdAt).inMinutes < 15;
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: Text(
                                      'More',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  if (canEdit)
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                      onTap: () =>
                                          Navigator.pop(context, 'edit'),
                                    ),
                                  ListTile(
                                    leading: Icon(Icons.delete_forever),
                                    title: Text('Delete for everyone'),
                                    onTap: () => Navigator.pop(
                                      context,
                                      'delete_everyone',
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete for me'),
                                    onTap: () =>
                                        Navigator.pop(context, 'delete_me'),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.copy),
                                    title: Text('Copy message'),
                                    onTap: () => Navigator.pop(context, 'copy'),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        );
                        if (result == 'edit') {
                          final newText = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(
                                text: message.content,
                              );
                              return AlertDialog(
                                title: Text('Edit Message'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Edit your message',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      controller.text.trim(),
                                    ),
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (newText != null &&
                              newText.isNotEmpty &&
                              newText != message.content) {
                            await ref
                                .read(chatViewModelProvider.notifier)
                                .editMessage(
                                  message.id,
                                  newText,
                                  otherUserId,
                                  listingId,
                                );
                          }
                        } else if (result == 'delete_everyone') {
                          await ref
                              .read(chatViewModelProvider.notifier)
                              .deleteMessage(
                                message.id,
                                'for_everyone',
                                otherUserId,
                                listingId,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: AnimatedOpacity(
                                opacity: 1.0,
                                duration: Duration(milliseconds: 400),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Message deleted for everyone',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.all(18),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (result == 'delete_me') {
                          await ref
                              .read(chatViewModelProvider.notifier)
                              .deleteMessage(
                                message.id,
                                'for_me',
                                otherUserId,
                                listingId,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: AnimatedOpacity(
                                opacity: 1.0,
                                duration: Duration(milliseconds: 400),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Message deleted for you',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.all(18),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (result == 'copy') {
                          await Clipboard.setData(
                            ClipboardData(text: message.content),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message copied')),
                          );
                        }
                      },
                      child: _bubbleContent(
                        isMe,
                        shownName,
                        message,
                        timeString,
                      ),
                    )
                  : _bubbleContent(isMe, shownName, message, timeString),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted bubble content for reuse
Widget _bubbleContent(
  bool isMe,
  String shownName,
  MessageEntity message,
  String timeString,
) {
  final String? shownProfilePicture = isMe
      ? message.senderProfilePicture
      : message.receiverProfilePicture;
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    margin: EdgeInsets.only(left: isMe ? 40 : 0, right: isMe ? 0 : 40),
    decoration: BoxDecoration(
      color: isMe ? Color(0xFF1976D2) : Color(0xFFF1F1F1),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(isMe ? 16 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 16),
      ),
      boxShadow: [
        if (!isMe)
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
      ],
    ),
    child: Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(
              shownName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        if (message.type == 'text')
          Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            textAlign: isMe ? TextAlign.right : TextAlign.left,
          ),
        if (message.type == 'media' &&
            message.media != null &&
            message.media!.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: message.media!.length,
              itemBuilder: (_, index) {
                final m = message.media![index];
                if (m.url.isEmpty) {
                  return Container(
                    width: 180,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image)),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: mediaBubble(m.url, m.type),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 4),
                Icon(
                  message.read ? Icons.done_all : Icons.done,
                  size: 15,
                  color: message.read ? Colors.greenAccent : Colors.white70,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper widget for media display
Widget mediaBubble(String url, String kind) {
  if (kind == 'image') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 180,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 180,
          height: 150,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  } else if (kind == 'video') {
    return Container(
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white, size: 50),
      ),
    );
  } else {
    return Container(
      width: 180,
      height: 150,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.help_outline)),
    );
  }
}
