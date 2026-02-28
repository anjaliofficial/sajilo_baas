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

// ---------------- Review Card ----------------
class ReviewCard extends ConsumerStatefulWidget {
  final dynamic review;
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

  bool _canEditReview() {
    return widget.review.reviewerId == widget.currentUserId;
  }

  bool _canEditReply() {
    if (widget.review.replies == null || widget.review.replies.isEmpty) {
      return false;
    }
    return widget.review.replies.first.authorId == widget.currentUserId;
  }

  void _showMenu(
    BuildContext context,
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
      final text = isReply
          ? widget.review.replies.first.text
          : widget.review.comment;
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Copied!")));
    }

    if (selected == 'edit') isReply ? _editReply() : _editReview();
    if (selected == 'delete') isReply ? _deleteReply() : _deleteReview();
  }

  Future<void> _editReview() async {
    final controller = TextEditingController(text: widget.review.comment);
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
          .editReviewOptimistic(reviewId: widget.review.id, comment: result);
    }
  }

  Future<void> _deleteReview() async {
    await ref
        .read(reviewProvider.notifier)
        .deleteReviewOptimistic(reviewId: widget.review.id);
  }

  Future<void> _editReply() async {
    final reply = widget.review.replies.first;
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
            reviewId: widget.review.id,
            replyId: reply.id,
            text: result,
          );
    }
  }

  Future<void> _deleteReply() async {
    final reply = widget.review.replies.first;
    await ref
        .read(reviewProvider.notifier)
        .deleteReplyOptimistic(reviewId: widget.review.id, replyId: reply.id);
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.review.replies ?? [];
    final showViewMore = replies.length > 1 && !expandedReplies;
    final showViewLess = replies.length > 1 && expandedReplies;

    // Determine which user to show on each side
    final reviewer = widget.review.reviewer;
    final reviewee = widget.review.reviewee;
    final reviewerName = reviewer?.fullName?.isNotEmpty == true
        ? reviewer!.fullName
        : (widget.review.reviewerName != null &&
              widget.review.reviewerName!.isNotEmpty)
        ? widget.review.reviewerName!
        : 'Unknown';
    final revieweeName = reviewee?.fullName?.isNotEmpty == true
        ? reviewee!.fullName
        : (widget.review.revieweeName != null &&
              widget.review.revieweeName!.isNotEmpty)
        ? widget.review.revieweeName!
        : 'Unknown';
    final reviewerProfile =
        reviewer?.profilePicture != null && reviewer!.profilePicture!.isNotEmpty
        ? reviewer!.profilePicture
        : (widget.review.reviewerProfile != null &&
              widget.review.reviewerProfile!.isNotEmpty)
        ? widget.review.reviewerProfile
        : null;
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
                      Text(widget.review.comment ?? ''),
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
                      )
                      .toList(),
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
