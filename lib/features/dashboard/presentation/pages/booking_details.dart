import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

class BookingDetailsPage extends StatelessWidget {
  final dynamic booking;
  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    String getFullImageUrl(String path) {
      if (path.startsWith('http')) return path;
      String normalized = path
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/+'), '');
      if (!normalized.startsWith('uploads/')) {
        normalized = 'uploads/$normalized';
      }
      return '${ApiEndpoints.staticBaseUrl}/$normalized';
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (booking.listingImages != null &&
                booking.listingImages!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  getFullImageUrl(booking.listingImages!.first),
                  height: 180,
                  width: double.infinity,
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
          ],
        ),
      ),
    );
  }
}

class BookingDetailsPageFull extends ConsumerWidget {
  final dynamic booking;
  const BookingDetailsPageFull({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String getFullImageUrl(String path) {
      if (path.startsWith('http')) return path;
      String normalized = path
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/+'), '');
      if (!normalized.startsWith('uploads/')) {
        normalized = 'uploads/$normalized';
      }
      return '${ApiEndpoints.staticBaseUrl}/$normalized';
    }

    Future<void> cancelBooking(BuildContext context) async {
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
      } catch (_) {
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
                  getFullImageUrl(booking.listingImages!.first),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                      : () => cancelBooking(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel Booking'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'hostId': booking.hostId,
                        'listingId': booking.listingId,
                      },
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
