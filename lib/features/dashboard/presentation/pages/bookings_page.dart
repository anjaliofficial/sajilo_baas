import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/presentation/providers/booking_providers.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load bookings: $e')),
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
                  title: Text('Listing: ${b.listingId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in: ${b.checkInDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'Check-out: ${b.checkOutDate.toLocal().toString().split(' ')[0]}',
                      ),
                      Text('Total: NPR ${b.totalPrice}'),
                      Text('Status: ${b.status}'),
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
