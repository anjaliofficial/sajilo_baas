import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text message
            if (message.type == 'text') Text(message.content),

            // Media messages
            if (message.type == 'media' && message.media != null)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.media!.length,
                  itemBuilder: (_, index) {
                    final m = message.media![index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: mediaBubble(m.url, m.type),
                    );
                  },
                ),
              ),

            // Seen / delivered icon
            if (isMe)
              Icon(
                message.read ? Icons.done_all : Icons.done,
                size: 14,
                color: message.read ? Colors.green : Colors.white,
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
      child: Image.network(url, width: 180, fit: BoxFit.cover),
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
    return const SizedBox();
  }
}
