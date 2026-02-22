import 'package:flutter/material.dart';
import '../../domain/entities/listing_entity.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../../booking/presentation/pages/bookingPage.dart';

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

class ListingDetailsPage extends StatelessWidget {
  final ListingEntity listing;
  const ListingDetailsPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildImagesCarousel(),
          Expanded(
            child: PageView(
              children: [
                _buildAboutPage(),
                _buildAmenitiesPage(),
                _buildHouseRulesPage(),
                _buildHostDetailsPage(),
                _buildAvailabilityPage(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            listing.location,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Price: \$${listing.pricePerNight}/night',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Property type: ${listing.propertyType}'),
          Text('Max guests: ${listing.maxGuests}'),
          Text('Min stay: ${listing.minStay} nights'),
          Text('Cancellation: ${listing.cancellationPolicy}'),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(listing.description),
        ],
      ),
    );
  }

  Widget _buildAmenitiesPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: listing.amenities
                .map((a) => Chip(label: Text(a)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseRulesPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'House rules',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(listing.houseRules),
        ],
      ),
    );
  }

  Widget _buildHostDetailsPage() {
    final host = listing.host;
    if (host == null) {
      return const Center(child: Text('No host details available'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: host.profilePicture.isNotEmpty
                    ? NetworkImage(getFullImageUrl(host.profilePicture))
                    : null,
                radius: 32,
                child: host.profilePicture.isEmpty
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    host.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Phone: ${host.phoneNumber}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Available from: ${_formatDate(listing.availableFrom)}'),
          Text('Available to: ${_formatDate(listing.availableTo)}'),
          const SizedBox(height: 16),
          Text('Status: ${listing.status}'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      listingId: listing.id,
                      pricePerNight: listing.pricePerNight.toDouble(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reserve Now', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildImagesCarousel() {
    if (listing.images.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.home, size: 80)),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView(
        children: listing.images
            .map(
              (url) => Image.network(
                getFullImageUrl(url),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
            .toList(),
      ),
    );
  }
}
