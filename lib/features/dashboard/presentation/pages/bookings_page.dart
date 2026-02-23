import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../booking/presentation/providers/booking_providers.dart';

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
      ref.invalidate(bookingViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(height: 120, padding: const EdgeInsets.all(16)),
          ),
        );
      },
    );
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

  String _getFullImageUrl(String path) {
    if (path.startsWith('http')) return path;
    String normalized = path
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    if (!normalized.startsWith('uploads/')) normalized = 'uploads/$normalized';
    return 'http://10.205.75.20:5050/$normalized';
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
          loading: () => _buildShimmerList(),
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
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
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
                              child: Text(
                                'Check-in: ${b.checkInDate.toLocal().toString().split(' ')[0]}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Check-out: ${b.checkOutDate.toLocal().toString().split(' ')[0]}',
                              ),
                            ),
                          ],
                        ),
                        Text('Total: NPR ${b.totalPrice}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: b.status.toLowerCase() == 'cancelled'
                                  ? null
                                  : () => _cancelBooking(b.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Cancel Booking'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingDetailsPageFull(booking: b),
                                  ),
                                );
                              },
                              child: const Text('Details'),
                            ),
                          ],
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

// Detailed Booking Page with Cancel, Chat, and Review
class BookingDetailsPageFull extends ConsumerWidget {
  final dynamic booking;
  const BookingDetailsPageFull({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String _getFullImageUrl(String path) {
      if (path.startsWith('http')) return path;
      String normalized = path
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/+'), '');
      if (!normalized.startsWith('uploads/'))
        normalized = 'uploads/$normalized';
      return 'http://10.205.75.20:5050/$normalized';
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

    Future<void> _cancelBooking(BuildContext context) async {
      try {
        final bookingVM = ref.read(bookingViewModelProvider.notifier);
        await bookingVM.cancel(booking.id);
        ref.invalidate(bookingViewModelProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.listingTitle ?? 'Listing ${booking.listingId}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (booking.listingImages != null &&
                booking.listingImages!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _getFullImageUrl(booking.listingImages!.first),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Chip(
              label: Text(booking.status.toUpperCase()),
              backgroundColor: _statusColor(booking.status),
              labelStyle: TextStyle(
                color: _statusTextColor(booking.status),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (booking.listingLocation != null)
              Text(
                'Location: ${booking.listingLocation}',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingPropertyType != null)
              Text(
                'Type: ${booking.listingPropertyType}',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingDescription != null)
              Text(
                'Description: ${booking.listingDescription}',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingMaxGuests != null)
              Text(
                'Max Guests: ${booking.listingMaxGuests}',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingMinStay != null)
              Text(
                'Min Stay: ${booking.listingMinStay} nights',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingCancellationPolicy != null)
              Text(
                'Cancellation: ${booking.listingCancellationPolicy}',
                style: const TextStyle(fontSize: 16),
              ),
            if (booking.listingHouseRules != null)
              Text(
                'House Rules: ${booking.listingHouseRules}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 12),
            Text(
              'Check-in: ${booking.checkInDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Check-out: ${booking.checkOutDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total: NPR ${booking.totalPrice}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: booking.status.toLowerCase() == 'cancelled'
                      ? null
                      : () => _cancelBooking(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel Booking'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat feature not implemented yet'),
                      ),
                    );
                  },
                  child: const Text('Chat Host'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (booking.status.toLowerCase() == 'completed')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate your stay:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      // TODO: submit rating
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
