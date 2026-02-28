import 'package:flutter/material.dart';
import '../../domain/entities/reply_entity.dart';

class ReplyWidget extends StatelessWidget {
  final ReplyEntity reply;
  final bool isMe;

  const ReplyWidget({super.key, required this.reply, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isOptimistic = reply.id.startsWith('temp-');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isOptimistic
              ? Colors.grey.shade300
              : isMe
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reply.text),
            if (isOptimistic)
              const Text(
                'Sending...',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
