import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';

class ReviewListPage extends ConsumerStatefulWidget {
  final bool showGiven; // true: reviews given, false: reviews received
  final String userId;
  const ReviewListPage({
    super.key,
    required this.userId,
    this.showGiven = false,
  });

  @override
  ConsumerState<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends ConsumerState<ReviewListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showGiven) {
        ref.read(reviewProvider.notifier).loadReviewsGiven();
      } else {
        ref.read(reviewProvider.notifier).loadReviews(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final reviews = reviewState.reviews;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showGiven ? 'Reviews Given' : 'Reviews Received'),
      ),
      body: reviewState.loading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const Center(child: Text('No reviews found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final r = reviews[i];
                return ListTile(
                  leading:
                      r.reviewerProfile != null && r.reviewerProfile!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(r.reviewerProfile!),
                          radius: 22,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.person),
                          radius: 22,
                        ),
                  title: Text(r.authorName ?? 'User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.comment ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        'Reviewed on: \\${r.createdAt.toLocal().toString().split(" ")[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⭐ \\${r.rating}'),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.reply, size: 20),
                        tooltip: 'Reply',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController replyController =
                                  TextEditingController();
                              return AlertDialog(
                                title: const Text('Reply to Review'),
                                content: TextField(
                                  controller: replyController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your reply',
                                  ),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement reply submission logic
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Reply sent (not implemented)',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Send'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
