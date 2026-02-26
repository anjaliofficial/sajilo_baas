import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../application/saved_bookings_provider.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import 'booking_details.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    // If already absolute URL, return as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Normalize slashes
    String normalized = path.replaceAll('\\', '/');
    // Remove leading slashes
    normalized = normalized.replaceFirst(RegExp(r'^/+'), '');
    // Ensure 'uploads/' prefix
    if (!normalized.startsWith('uploads/')) {
      normalized = 'uploads/$normalized';
    }
    return '${ApiEndpoints.staticBaseUrl}/$normalized';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedBookingsProvider);
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    // Ensure saved bookings and bookings are fetched when page is opened
    Future.microtask(() {
      ref.read(savedBookingsProvider.notifier).fetchSavedBookings();
      ref.read(bookingViewModelProvider.notifier).loadBookings();
    });

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
                          _getFullImageUrl(b.listingImages!.first),
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
