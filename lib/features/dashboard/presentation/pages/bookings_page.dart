import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/presentation/providers/booking_providers.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  // ✅ Helper must be OUTSIDE build method
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                child: ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 80,
                    child:
                        b.listingImages != null && b.listingImages!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getFullImageUrl(b.listingImages!.first),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : const Icon(Icons.hotel, size: 40),
                  ),
                  title: Text(
                    b.listingTitle ?? 'Listing: ${b.listingId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 6),
                      Text(
                        'Check-in: ${b.checkInDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'Check-out: ${b.checkOutDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text('Total: NPR ${b.totalPrice}'),
                      Text(
                        'Status: ${b.status}',
                        style: TextStyle(
                          color: b.status == 'confirmed'
                              ? Colors.green
                              : Colors.orange,
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
    );
  }
}
