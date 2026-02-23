import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../booking/presentation/providers/booking_providers.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final RefreshController _refreshController = RefreshController();
  int _page = 1;
  final int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      bookings.clear();
    }
    setState(() {
      _isLoadingMore = true;
    });
    final bookingVM = ref.read(bookingViewModelProvider.notifier);
    await bookingVM.loadBookings();
    final data = ref.read(bookingViewModelProvider).value ?? [];
    setState(() {
      bookings = data.take(_page * _pageSize).toList();
      _isLoadingMore = false;
      _hasMore = data.length > bookings.length;
    });
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  void _onRefresh() => _loadBookings(refresh: true);
  void _onLoading() {
    if (_hasMore) {
      setState(() {
        _page++;
      });
      _loadBookings();
    } else {
      _refreshController.loadNoData();
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final bookingVM = ref.read(bookingViewModelProvider.notifier);
    // Optimistic UI: remove booking immediately
    setState(() {
      bookings.removeWhere((b) => b.id == bookingId);
    });
    await bookingVM.cancel(bookingId);
    _loadBookings(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: bookingsAsync.when(
          loading: () => _buildShimmerList(),
          error: (e, _) => Center(child: Text('Failed to load bookings: $e')),
          data: (_) {
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
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child:
                                  b.listingImages != null &&
                                      b.listingImages!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _getFullImageUrl(
                                          b.listingImages!.first,
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.hotel, size: 40),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.listingTitle ?? 'Listing: ${b.listingId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (b.listingLocation != null)
                                    Text('Location: ${b.listingLocation}'),
                                  if (b.listingPropertyType != null)
                                    Text('Type: ${b.listingPropertyType}'),
                                  if (b.listingDescription != null)
                                    Text(
                                      'Description: ${b.listingDescription}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(b.status),
                              backgroundColor: b.status == 'confirmed'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              labelStyle: TextStyle(
                                color: b.status == 'confirmed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Check-in: ${b.checkInDate.toLocal().toString().split(' ')[0]}',
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Check-out: ${b.checkOutDate.toLocal().toString().split(' ')[0]}',
                            ),
                          ],
                        ),
                        Text('Total: NPR ${b.totalPrice}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: b.status == 'cancelled'
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
                                        BookingDetailsPage(booking: b),
                                  ),
                                );
                              },
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                        if (b.status == 'completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: RatingBar.builder(
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

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(width: 80, height: 80, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 16, width: 120, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 80, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 60, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFullImageUrl(String path) {
    if (path.startsWith('http')) return path;
    String normalized = path
        .replaceAll('\\', '/')
        .replaceAll('uploads/', '/uploads/');
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    return 'http://10.205.75.20:5050$normalized';
  }
}

// Booking Details Page
class BookingDetailsPage extends StatelessWidget {
  final dynamic booking;
  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.listingTitle ?? 'Listing: ${booking.listingId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (booking.listingImages != null &&
                booking.listingImages!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _getFullImageUrl(booking.listingImages!.first),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            if (booking.listingLocation != null)
              Text('Location: ${booking.listingLocation}'),
            if (booking.listingPropertyType != null)
              Text('Type: ${booking.listingPropertyType}'),
            if (booking.listingDescription != null)
              Text('Description: ${booking.listingDescription}'),
            const SizedBox(height: 8),
            Text(
              'Check-in: ${booking.checkInDate.toLocal().toString().split(' ')[0]}',
            ),
            Text(
              'Check-out: ${booking.checkOutDate.toLocal().toString().split(' ')[0]}',
            ),
            Text('Total: NPR ${booking.totalPrice}'),
            Chip(
              label: Text(booking.status),
              backgroundColor: booking.status == 'confirmed'
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              labelStyle: TextStyle(
                color: booking.status == 'confirmed'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: booking.status == 'cancelled'
                  ? null
                  : () {
                      // TODO: cancel booking from details
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel Booking'),
            ),
            if (booking.status == 'completed')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RatingBar.builder(
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
              ),
          ],
        ),
      ),
    );
  }
}
