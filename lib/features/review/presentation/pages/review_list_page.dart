import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      ref.read(reviewProvider.notifier).loadReviewsGiven();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);

    // Filter reviews for received and given
    final receivedReviews = state.reviews
        .where((r) => r.revieweeId == widget.userId)
        .toList();
    final givenReviews = state.reviews
        .where((r) => r.reviewerId == widget.userId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Received"),
            Tab(text: "Given"),
          ],
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(receivedReviews, true),
                _buildList(givenReviews, false),
              ],
            ),
    );
  }

  Widget _buildList(List reviews, bool isReceivedTab) {
    if (reviews.isEmpty) {
      return const Center(child: Text("No reviews found"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return ReviewCard(
          review: reviews[index],
          isReceivedTab: isReceivedTab,
          currentUserId: widget.userId,
        );
      },
    );
  }
}

class ReviewCard extends ConsumerWidget {
  final dynamic review;
  final bool isReceivedTab;
  final String currentUserId;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isReceivedTab,
    required this.currentUserId,
  });

  bool _canEditReview() {
    return review.reviewerId == currentUserId;
  }

  bool _canEditReply() {
    if (review.replies == null || review.replies.isEmpty) return false;
    return review.replies.first.authorId == currentUserId;
  }

  void _showMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position, {
    required bool isReply,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        if ((isReply && _canEditReply()) || (!isReply && _canEditReview()))
          const PopupMenuItem(value: 'edit', child: Text("Edit")),
        if ((isReply && _canEditReply()) || (!isReply && _canEditReview()))
          const PopupMenuItem(value: 'delete', child: Text("Delete")),
        const PopupMenuItem(value: 'copy', child: Text("Copy")),
      ],
    );

    if (selected == 'copy') {
      final text = isReply ? review.replies.first.text : review.comment;
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Copied!")));
    }

    if (selected == 'edit') {
      isReply ? _editReply(context, ref) : _editReview(context, ref);
    }

    if (selected == 'delete') {
      isReply ? _deleteReply(context, ref) : _deleteReview(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replied = review.replies != null && review.replies.isNotEmpty;
    final reply = replied ? review.replies.first : null;

    final canReply =
        isReceivedTab && !replied && review.revieweeId == currentUserId;

    return GestureDetector(
      onLongPressStart: (details) =>
          _showMenu(context, ref, details.globalPosition, isReply: false),
      onSecondaryTapDown: (details) =>
          _showMenu(context, ref, details.globalPosition, isReply: false),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        review.reviewerProfile != null &&
                            review.reviewerProfile.isNotEmpty
                        ? NetworkImage(getFullImageUrl(review.reviewerProfile))
                        : null,
                    child:
                        review.reviewerProfile == null ||
                            review.reviewerProfile.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      review.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(review.rating.toString()),
                ],
              ),

              const SizedBox(height: 8),
              Text(review.comment),

              const SizedBox(height: 6),
              Text(
                review.createdAt.toString().split(" ")[0],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              /// REPLY VIEW
              if (replied && reply != null)
                GestureDetector(
                  onLongPressStart: (details) => _showMenu(
                    context,
                    ref,
                    details.globalPosition,
                    isReply: true,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(reply.text),
                  ),
                ),

              /// REPLY BUTTON
              if (canReply)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.reply),
                    label: const Text("Reply"),
                    onPressed: () async {
                      final controller = TextEditingController();
                      final result = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Reply to Review"),
                          content: TextField(
                            controller: controller,
                            maxLines: 3,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(
                                context,
                                controller.text.trim(),
                              ),
                              child: const Text("Send"),
                            ),
                          ],
                        ),
                      );

                      if (result != null && result.isNotEmpty) {
                        await ref
                            .read(reviewProvider.notifier)
                            .addReplyOptimistic(
                              reviewId: review.id,
                              authorId: currentUserId,
                              text: result,
                            );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editReview(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: review.comment);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Review"),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref
          .read(reviewProvider.notifier)
          .editReviewOptimistic(reviewId: review.id, comment: result);
    }
  }

  Future<void> _deleteReview(BuildContext context, WidgetRef ref) async {
    await ref
        .read(reviewProvider.notifier)
        .deleteReviewOptimistic(reviewId: review.id);
  }

  Future<void> _editReply(BuildContext context, WidgetRef ref) async {
    final reply = review.replies.first;
    final controller = TextEditingController(text: reply.text);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Reply"),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref
          .read(reviewProvider.notifier)
          .editReplyOptimistic(
            reviewId: review.id,
            replyId: reply.id,
            text: result,
          );
    }
  }

  Future<void> _deleteReply(BuildContext context, WidgetRef ref) async {
    final reply = review.replies.first;

    await ref
        .read(reviewProvider.notifier)
        .deleteReplyOptimistic(reviewId: review.id, replyId: reply.id);
  }
}
