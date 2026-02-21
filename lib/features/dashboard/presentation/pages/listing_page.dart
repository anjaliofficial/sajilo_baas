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
      if (!vm.isLoading && vm.listings.isEmpty) {
        vm.fetchListings();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('All Listings')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? Center(child: Text('Error: ${vm.error}'))
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: vm.listings.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Filter card at the top
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location
                            const Text(
                              'Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const TextField(
                              decoration: InputDecoration(
                                hintText: 'Kathmandu',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Price Range
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text('Min price'),
                                      SizedBox(height: 4),
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '100',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text('Max price'),
                                      SizedBox(height: 4),
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '400',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Property Type
                            const Text('Property type'),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: 'All types',
                              items:
                                  [
                                        'All types',
                                        'Apartment',
                                        'House',
                                        'Studio',
                                        'Villa',
                                      ]
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {},
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Check-in / out
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text('Check-in'),
                                      SizedBox(height: 4),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: 'dd-mm-yyyy',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text('Check-out'),
                                      SizedBox(height: 4),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: 'dd-mm-yyyy',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Guests
                            const Text('Guests'),
                            const SizedBox(height: 4),
                            const TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '2',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Apply filters
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Apply filters'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Listing items
                final listing = vm.listings[index - 1];

                return Card(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
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
