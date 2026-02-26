import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/saved_bookings_provider.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import 'booking_details.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedBookingsProvider);
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (bookings) {
          final savedBookings = bookings
              .where((b) => savedIds.contains(b.id.toString()))
              .toList();
          if (savedBookings.isEmpty) {
            return const Center(
              child: Text('No favorites yet.', style: TextStyle(fontSize: 18)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: savedBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final b = savedBookings[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      b.listingImages != null && b.listingImages!.isNotEmpty
                      ? Image.network(
                          b.listingImages!.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.hotel, size: 40),
                  title: Text(b.listingTitle ?? 'Listing ${b.listingId}'),
                  subtitle: b.listingLocation != null
                      ? Text(b.listingLocation!)
                      : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailsPageFull(booking: b),
                    ),
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
