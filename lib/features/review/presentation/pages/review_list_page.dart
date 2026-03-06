import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';
import 'package:sajilo_baas/core/utils/image_utils.dart';
import '../../domain/entities/review_entity.dart';

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
    ref.listen(reviewProvider, (previous, next) {
      if (next.error != null &&
          next.error!.isNotEmpty &&
          next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(reviewProvider);
    final receivedReviews = state.receivedReviews;
    final givenReviews = state.givenReviews;

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

  Widget _buildList(List<ReviewEntity> reviews, bool isReceivedTab) {
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

// ---------------- Review Card ----------------
class ReviewCard extends ConsumerStatefulWidget {
  final ReviewEntity review;
  final bool isReceivedTab;
  final String currentUserId;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isReceivedTab,
    required this.currentUserId,
  });

  @override
  ConsumerState<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<ReviewCard>
    with SingleTickerProviderStateMixin {
  bool showReplyInput = false;
  bool expandedReplies = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleReplies() {
    setState(() {
      expandedReplies = !expandedReplies;
      if (expandedReplies) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showReplyInput() {
    setState(() {
      showReplyInput = true;
    });
  }

  void _hideReplyInput() {
    setState(() {
      showReplyInput = false;
    });
  }

  Future<void> _submitReply(String text) async {
    if (text.trim().isEmpty) return;
    await ref
        .read(reviewProvider.notifier)
        .addReplyOptimistic(
          reviewId: widget.review.id,
          text: text.trim(),
          authorId: widget.currentUserId,
        );
    _hideReplyInput();
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.review.replies;
    final showViewMore = replies.length > 1 && !expandedReplies;
    final showViewLess = replies.length > 1 && expandedReplies;

    bool isLikelyMongoId(String value) {
      return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
    }

    String normalizeDisplayName(String? value, String? userId) {
      final name = value?.trim() ?? '';
      if (name.isNotEmpty && !isLikelyMongoId(name)) return name;
      if ((userId ?? '').isNotEmpty && userId == widget.currentUserId) {
        return 'You';
      }
      if ((userId ?? '').isNotEmpty && !isLikelyMongoId(userId!)) {
        return userId;
      }
      return 'User';
    }

    // Determine which user to show on each side
    final reviewerId = widget.review.reviewerId;
    final revieweeId = widget.review.revieweeId;

    final reviewerNameRaw = widget.review.reviewerName;
    final revieweeNameRaw = widget.review.revieweeName;

    final reviewerName = normalizeDisplayName(reviewerNameRaw, reviewerId);
    final revieweeName = normalizeDisplayName(revieweeNameRaw, revieweeId);
    final reviewerProfile = widget.review.reviewerProfile;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      (reviewerProfile != null && reviewerProfile.isNotEmpty)
                      ? NetworkImage(getFullImageUrl(reviewerProfile))
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: (reviewerProfile == null || reviewerProfile.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reviewerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              revieweeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(widget.review.rating.toString()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.review.comment),
                      const SizedBox(height: 6),
                      Text(
                        widget.review.createdAt.toString().split(" ")[0],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Reply button
            if (!showReplyInput && widget.isReceivedTab)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _showReplyInput,
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text("Reply"),
                ),
              ),

            // Reply input
            if (showReplyInput)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 34),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onSubmitted: _submitReply,
                      ),
                    ),
                  ],
                ),
              ),

            // Replies
            if (replies.isNotEmpty)
              Column(
                children: [
                  ...replies
                      .take(expandedReplies ? replies.length : 1)
                      .map(
                        (r) => ReplyBubble(
                          reply: r,
                          isOwner: r.authorId == widget.review.revieweeId,
                        ),
                      ),
                  if (showViewMore)
                    TextButton(
                      onPressed: _toggleReplies,
                      child: Text('View more replies (${replies.length})'),
                    ),
                  if (showViewLess)
                    TextButton(
                      onPressed: _toggleReplies,
                      child: const Text('View less'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Reply Bubble ----------------
class ReplyBubble extends StatelessWidget {
  final dynamic reply;
  final bool isOwner;

  const ReplyBubble({super.key, required this.reply, this.isOwner = false});

  String timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOwner ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage:
                    (reply.author != null &&
                        reply.author['profilePicture'] != null &&
                        (reply.author['profilePicture'] as String).isNotEmpty)
                    ? NetworkImage(
                        getFullImageUrl(reply.author['profilePicture']),
                      )
                    : null,
                backgroundColor: Colors.grey.shade200,
                child:
                    (reply.author == null ||
                        reply.author['profilePicture'] == null ||
                        (reply.author['profilePicture'] as String).isEmpty)
                    ? const Icon(Icons.person, size: 14, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                (reply.author != null &&
                        reply.author['fullName'] != null &&
                        (reply.author['fullName'] as String).isNotEmpty)
                    ? reply.author['fullName']
                    : (reply.authorId ?? 'Unknown'),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: isOwner ? Colors.blue : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(reply.text ?? '', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            timeAgo(reply.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
