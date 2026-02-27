import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';

class ReviewListPage extends ConsumerWidget {
  final bool showGiven; // true: reviews given, false: reviews received
  final String userId;
  const ReviewListPage({
    super.key,
    required this.userId,
    this.showGiven = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(reviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(showGiven ? 'Reviews Given' : 'Reviews Received'),
      ),
      body: FutureBuilder(
        future: showGiven
            ? ref.read(reviewProvider.notifier).loadReviewsGiven()
            : ref.read(reviewProvider.notifier).loadReviews(userId),
        builder: (context, snapshot) {
          final reviews = reviewState.reviews;
          if (reviewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final r = reviews[i];
              return ListTile(
                title: Text(r.authorName ?? 'User'),
                subtitle: Text(r.comment ?? ''),
                trailing: Text('⭐ ${r.rating}'),
              );
            },
          );
        },
      ),
    );
  }
}
