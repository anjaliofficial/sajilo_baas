import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/star_rating_widget.dart';
import '../providers/review_provider.dart';

class BookingReviewPage extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingReviewPage({super.key, required this.bookingId});

  @override
  ConsumerState<BookingReviewPage> createState() => _BookingReviewPageState();
}

class _BookingReviewPageState extends ConsumerState<BookingReviewPage> {
  int rating = 0;
  final TextEditingController commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate your experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// ⭐ STAR RATING
            StarRatingWidget(
              rating: rating,
              onChanged: (value) {
                setState(() => rating = value);
              },
            ),

            const SizedBox(height: 20),

            /// 💬 COMMENT
            TextField(
              controller: commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            /// 🚀 SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: rating == 0
                    ? null
                    : () async {
                        await ref
                            .read(reviewProvider.notifier)
                            .createReview(
                              bookingId: widget.bookingId,
                              rating: rating,
                              comment: commentCtrl.text,
                            );
                        final error = ref.read(reviewProvider).error;
                        if (error != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        // Reload reviews for the current user
                        final auth = ref.read(authViewModelProvider);
                        if (auth.authEntity != null &&
                            auth.authEntity!.authId != null) {
                          await ref
                              .read(reviewProvider.notifier)
                              .loadReviews(auth.authEntity!.authId!);
                          await ref
                              .read(reviewProvider.notifier)
                              .loadReviewsGiven();
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
