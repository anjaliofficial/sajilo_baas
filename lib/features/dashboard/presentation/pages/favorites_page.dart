import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../application/saved_bookings_provider.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import 'booking_details.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(savedBookingsProvider.notifier).fetchSavedBookings();
      ref.read(bookingViewModelProvider.notifier).loadBookings();
    });
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    String normalized = path.replaceAll('\\', '/');
    normalized = normalized.replaceFirst(RegExp(r'^/+'), '');
    if (!normalized.startsWith('uploads/')) {
      normalized = 'uploads/$normalized';
    }
    return '${ApiEndpoints.staticBaseUrl}/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    final savedIds = ref.watch(savedBookingsProvider);
    final bookingsAsync = ref.watch(bookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (bookings) {
                final savedBookings = bookings
                    .where((b) => savedIds.contains(b.id.toString()))
                    .where(
                      (b) =>
                          _searchQuery.isEmpty ||
                          (b.listingTitle != null &&
                              b.listingTitle!.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              )),
                    )
                    .toList();
                if (savedBookings.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedBookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final b = savedBookings[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading:
                            b.listingImages != null &&
                                b.listingImages!.isNotEmpty
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
          ),
        ],
      ),
    );
  }
}
