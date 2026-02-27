import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';
import 'package:sajilo_baas/core/utils/image_utils.dart';

class ReviewListPage extends ConsumerStatefulWidget {
  final String userId;
  const ReviewListPage({super.key, required this.userId});

  @override
  ConsumerState<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends ConsumerState<ReviewListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadReviews(widget.userId);
    });
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        ref.read(reviewProvider.notifier).loadReviews(widget.userId);
      } else {
        ref.read(reviewProvider.notifier).loadReviewsGiven();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final reviews = reviewState.reviews;
    final isLoading = reviewState.loading;
    final isReceivedTab = _tabController.index == 0;

    // Calculate average rating for received reviews
    double avgRating = 0;
    int totalReviews = 0;
    if (isReceivedTab && reviews.isNotEmpty) {
      avgRating =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      totalReviews = reviews.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Reviews'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Received'),
                Tab(text: 'Given'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isReceivedTab)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: reviews.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Text(
                          '⭐ ${avgRating.toStringAsFixed(1)} ($totalReviews Reviews)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? const Center(child: Text('No reviews found.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final r = reviews[i];
                      return _ReviewCard(
                        review: r,
                        isReceivedTab: isReceivedTab,
                        currentUserId: widget.userId,
                        onReply: (replyText) async {
                          await ref
                              .read(reviewProvider.notifier)
                              .addReplyOptimistic(
                                reviewId: r.id,
                                authorId: widget.userId,
                                text: replyText,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reply sent!')),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  final bool isReceivedTab;
  final String currentUserId;
  final Future<void> Function(String replyText)? onReply;

  const _ReviewCard({
    required this.review,
    required this.isReceivedTab,
    required this.currentUserId,
    this.onReply,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final replied = review.replies != null && review.replies.isNotEmpty;
    final reply = replied ? review.replies.first : null;
    final canReply =
        isReceivedTab && !replied && review.revieweeId == currentUserId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage:
                      review.reviewerProfile != null &&
                          review.reviewerProfile.isNotEmpty
                      ? NetworkImage(getFullImageUrl(review.reviewerProfile))
                      : null,
                  radius: 22,
                  child:
                      (review.reviewerProfile == null ||
                          review.reviewerProfile.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceivedTab
                            ? review.authorName
                            : (review.propertyName ?? review.authorName),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 18),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reviewed on: ${review.createdAt.toLocal().toString().split(" ")[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (replied && reply != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12, left: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.reply,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isReceivedTab
                                            ? 'Your Reply:'
                                            : 'Owner Reply:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        reply.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (canReply)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.reply, size: 18),
                            label: const Text('Reply'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () async {
                              final replyText = await showDialog<String>(
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
                                          final text = replyController.text
                                              .trim();
                                          if (text.isNotEmpty) {
                                            Navigator.of(context).pop(text);
                                          }
                                        },
                                        child: const Text('Send'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (replyText != null &&
                                  replyText.isNotEmpty &&
                                  onReply != null) {
                                await onReply!(replyText);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
