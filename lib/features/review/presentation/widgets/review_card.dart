ElevatedButton(
  onPressed: () {
    ref.read(reviewProvider.notifier).addReplyOptimistic(
          reviewId: review.id,
          authorId: currentUserId,
          text: replyController.text,
        );

    replyController.clear();
  },
  child: const Text('Reply'),
);