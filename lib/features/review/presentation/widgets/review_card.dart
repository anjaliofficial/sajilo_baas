import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/review/presentation/providers/review_provider.dart';

class ReplyButton extends ConsumerWidget {
  final String reviewId;
  final String authorId;
  final TextEditingController replyController;
  const ReplyButton({
    super.key,
    required this.reviewId,
    required this.authorId,
    required this.replyController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final text = replyController.text.trim();
        if (text.isEmpty) return;
        ref
            .read(reviewProvider.notifier)
            .addReplyOptimistic(
              reviewId: reviewId,
              authorId: authorId,
              text: text,
            );
        replyController.clear();
      },
      child: const Text('Reply'),
    );
  }
}
