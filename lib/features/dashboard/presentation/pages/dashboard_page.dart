import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/notification/presentation/pages/notifications_page.dart';
import 'package:sajilo_baas/features/notification/presentation/providers/notification_provider.dart';
import 'package:sajilo_baas/features/review/presentation/pages/review_list_page.dart';
import 'package:sajilo_baas/features/dashboard/presentation/pages/map_page.dart';
import 'listing_page.dart';
import 'listing_details_page.dart';
import 'profile_screen.dart';
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Color primaryBlue = const Color(0xFF007BFF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(dashboardViewModelProvider);
      if (!state.isLoading && state.listings.isEmpty) {
        ref.read(dashboardViewModelProvider).fetchListings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.authEntity?.authId;
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
                onPressed: userId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewListPage(userId: userId),
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
    final state = ref.watch(dashboardViewModelProvider);
    final listings = state.listings;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sajilo Baas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, size: 28, color: Colors.black),
          onSelected: (String value) {
            if (value == 'notifications') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ).then((_) {
                ref.read(notificationProvider.notifier).fetchNotifications();
              });
            } else if (value == 'map') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapPage()),
              );
            } else if (value == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'notifications',
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Notifications'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'map',
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('Nearby Properties'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
          ],
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
