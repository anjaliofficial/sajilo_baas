import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/dashboard_provider.dart';
import 'listing_details_page.dart';

String getFullImageUrl(String path) {
  if (path.startsWith('http')) return path;
  // Normalize backslashes to forward slashes
  String normalized = path.replaceAll('\\', '/');
  // Ensure leading slash
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  return 'http://10.33.46.20:5050$normalized';
}

class ListingPage extends ConsumerWidget {
  const ListingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(dashboardViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.isLoading && vm.listings.isEmpty) vm.fetchListings();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('All Listings')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? Center(child: Text('Error: ${vm.error}'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.listings.length,
              itemBuilder: (context, index) {
                final listing = vm.listings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: listing.images.isNotEmpty
                        ? Image.network(
                            getFullImageUrl(listing.images[0]),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.home, size: 40),
                    title: Text(listing.title),
                    subtitle: Text(
                      '${listing.location} • \$${listing.pricePerNight}/night',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingDetailsPage(listing: listing),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
