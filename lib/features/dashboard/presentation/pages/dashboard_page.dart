import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/review/presentation/pages/review_list_page.dart';
import 'listing_page.dart';
import 'listing_details_page.dart';
import '../../domain/entities/listing_entity.dart';
import '../../presentation/providers/dashboard_provider.dart';

String getFullImageUrl(String path) {
  if (path.startsWith('http')) return path;
  // Normalize backslashes to forward slashes
  String normalized = path.replaceAll('\\', '/');
  // Ensure leading slash
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  return '${ApiEndpoints.staticBaseUrl}$normalized';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  final Color primaryBlue = const Color(0xFF007BFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    // Ensure listings are fetched when page is opened
    Future.microtask(() {
      if (!state.isLoading && state.listings.isEmpty) {
        ref.read(dashboardViewModelProvider).fetchListings();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: _buildHeader(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewListPage(userId: 'currentUserId'),
                    ),
                  );
                },
                child: const Text('View Reviews'),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(dashboardViewModelProvider)
                          .fetchListings();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildSearchBar(ref),
                          const SizedBox(height: 30),
                          _buildSectionHeader(
                            context: context,
                            title: 'Nearby your location',
                            actionText: 'See all',
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ListingPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildNearbyPropertyList(
                            state.filteredListings,
                            context,
                          ),
                          const SizedBox(height: 40),
                          _buildSectionHeader(
                            title: 'Popular Destination',
                            context: context,
                          ),
                          const SizedBox(height: 15),
                          _buildPopularDestinationList(
                            state.filteredListings,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // -------------------- HEADER --------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  'Kathmandu, Pepsicola',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.red),
        ),
      ],
    );
  }

  // -------------------- SEARCH BAR --------------------
  Widget _buildSearchBar(WidgetRef ref) {
    return TextFormField(
      onChanged: (value) {
        ref.read(dashboardViewModelProvider).setSearchQuery(value);
      },
      decoration: InputDecoration(
        hintText: 'Start Your Search',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  // -------------------- SECTION HEADER --------------------
  Widget _buildSectionHeader({
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 14,
                color: primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // -------------------- NEARBY PROPERTY LIST --------------------
  Widget _buildNearbyPropertyList(
    List<ListingEntity> listings,
    BuildContext context,
  ) {
    final nearby = listings.take(3).toList();
    return Column(
      children: nearby
          .map((listing) => _buildListingCard(context, listing))
          .toList(),
    );
  }

  // -------------------- POPULAR DESTINATION LIST --------------------
  Widget _buildPopularDestinationList(
    List<ListingEntity> listings,
    BuildContext context,
  ) {
    final popular = listings.skip(3).take(3).toList();
    return Column(
      children: popular
          .map((listing) => _buildListingCard(context, listing, isRow: true))
          .toList(),
    );
  }

  // -------------------- LISTING CARD --------------------
  Widget _buildListingCard(
    BuildContext context,
    ListingEntity listing, {
    bool isRow = false,
  }) {
    if (isRow) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailsPage(listing: listing),
          ),
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  listing.images.isNotEmpty
                      ? getFullImageUrl(listing.images[0])
                      : 'https://via.placeholder.com/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      listing.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ListingDetailsPage(listing: listing)),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                listing.images.isNotEmpty
                    ? getFullImageUrl(listing.images[0])
                    : 'https://via.placeholder.com/80',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: NPR${listing.pricePerNight}/night',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
