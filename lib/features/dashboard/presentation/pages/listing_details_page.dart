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

class ListingDetailsPage extends StatefulWidget {
  final ListingEntity listing;
  const ListingDetailsPage({super.key, required this.listing});

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final pageCount = 5;
    final pageTitles = [
      'About',
      'Amenities',
      'House Rules',
      'Host Details',
      'Availability',
    ];
    final pageWidgets = [
      _buildAboutPage(widget.listing),
      _buildAmenitiesPage(widget.listing),
      _buildHouseRulesPage(widget.listing),
      _buildHostDetailsPage(widget.listing),
      _buildAvailabilityPage(context, widget.listing),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _ListingDetailsPager(
        pageCount: pageCount,
        pageTitles: pageTitles,
        pageWidgets: pageWidgets,
        imagesCarousel: _buildImagesCarousel(widget.listing),
      ),
    );
  }

  Widget _buildAboutPage(ListingEntity listing) {
    return SingleChildScrollView(
      child: Padding(
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
      ),
    );
  }

  Widget _buildAmenitiesPage(ListingEntity listing) {
    return SingleChildScrollView(
      child: Padding(
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
      ),
    );
  }

  Widget _buildHouseRulesPage(ListingEntity listing) {
    return SingleChildScrollView(
      child: Padding(
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
      ),
    );
  }

  Widget _buildHostDetailsPage(ListingEntity listing) {
    final host = listing.host;
    if (host == null) {
      return const Center(child: Text('No host details available'));
    }
    return SingleChildScrollView(
      child: Padding(
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
      ),
    );
  }

  Widget _buildAvailabilityPage(BuildContext context, ListingEntity listing) {
    return SingleChildScrollView(
      child: Padding(
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
                child: const Text(
                  'Reserve Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildImagesCarousel(ListingEntity listing) {
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

class _ListingDetailsPager extends StatefulWidget {
  final int pageCount;
  final List<String> pageTitles;
  final List<Widget> pageWidgets;
  final Widget imagesCarousel;
  const _ListingDetailsPager({
    required this.pageCount,
    required this.pageTitles,
    required this.pageWidgets,
    required this.imagesCarousel,
  });

  @override
  State<_ListingDetailsPager> createState() => _ListingDetailsPagerState();
}

class _ListingDetailsPagerState extends State<_ListingDetailsPager> {
  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      _currentPage = page;
    });
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.imagesCarousel,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                child: const Text('Previous'),
              ),
              Text(
                widget.pageTitles[_currentPage],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _currentPage < widget.pageCount - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: widget.pageWidgets,
          ),
        ),
      ],
    );
  }
}

// ...existing code.
