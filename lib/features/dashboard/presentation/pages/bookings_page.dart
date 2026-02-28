import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/features/review/presentation/pages/booking_review_page.dart';
import 'package:shimmer/shimmer.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import 'booking_details.dart'; // <-- import details page

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final bookingVM = ref.read(bookingViewModelProvider.notifier);
      await bookingVM.cancel(bookingId);
      await bookingVM.loadBookings(); // Explicitly reload bookings after cancel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onRefresh() {
    ref.invalidate(bookingViewModelProvider);
    _refreshController.refreshCompleted();
  }

  String _getFullImageUrl(String path) {
    if (path.startsWith('http')) return path;
    String normalized = path
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    if (!normalized.startsWith('uploads/')) normalized = 'uploads/$normalized';
    return '${ApiEndpoints.staticBaseUrl}/$normalized';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'pending':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(height: 120, padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _onRefresh,
        child: bookingsAsync.when(
          loading: _buildShimmerList,
          error: (e, _) => Center(child: Text('Failed to load bookings: $e')),
          data: (bookings) {
            if (bookings.isEmpty) {
              return const Center(
                child: Text(
                  'You have no bookings yet.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  b.listingImages != null &&
                                      b.listingImages!.isNotEmpty
                                  ? Image.network(
                                      _getFullImageUrl(b.listingImages!.first),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.hotel, size: 60),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.listingTitle ?? 'Listing ${b.listingId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (b.listingLocation != null)
                                    Text(b.listingLocation!),
                                  if (b.listingPropertyType != null)
                                    Text('Type: ${b.listingPropertyType}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(b.status.toUpperCase()),
                              backgroundColor: _statusColor(b.status),
                              labelStyle: TextStyle(
                                color: _statusTextColor(b.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: b.status.toLowerCase() == 'cancelled'
                                    ? null
                                    : () => _cancelBooking(b.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel Booking'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingDetailsPageFull(booking: b),
                                  ),
                                ),
                                child: const Text('Details'),
                              ),
                            ),
                          ],
                        ),
                        if (b.status.toLowerCase() == 'confirmed' ||
                            b.status.toLowerCase() == 'completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingReviewPage(
                                      bookingId: b.id.toString(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Write a Review'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
