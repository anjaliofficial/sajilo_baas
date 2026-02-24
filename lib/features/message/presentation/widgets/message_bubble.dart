import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
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
              // Incoming: avatar
              shownProfilePicture != null
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: NetworkImage(shownProfilePicture),
                      onBackgroundImageError: (_, __) {},
                    )
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[400],
                      child: Icon(Icons.person, size: 18, color: Colors.white),
                    ),
              SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                margin: EdgeInsets.only(
                  left: isMe ? 40 : 0,
                  right: isMe ? 0 : 40,
                ),
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
                            if (m.url == null || m.url.isEmpty) {
                              return Container(
                                width: 180,
                                height: 150,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
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
                              color: message.read
                                  ? Colors.greenAccent
                                  : Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
