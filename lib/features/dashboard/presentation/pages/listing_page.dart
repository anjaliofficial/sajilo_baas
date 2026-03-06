import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/dashboard/sensors/widgets/shake_detector_widget.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';
import 'dart:async';
import '../providers/dashboard_provider.dart';
import 'listing_details_page.dart';
import 'package:sajilo_baas/features/dashboard/sensors/pages/sensors_page.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

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

class ListingPage extends ConsumerStatefulWidget {
  const ListingPage({super.key});

  @override
  ConsumerState<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends ConsumerState<ListingPage> {
  DateTime? _lastShakeAt;
  final TextEditingController _searchController = TextEditingController();
  String _selectedPropertyType = 'All types';
  Timer? _searchDebounce;
  String _debouncedQuery = '';
  static const double _twoLakh = 200000;
  RangeValues _priceRange = const RangeValues(0, _twoLakh);
  bool _twoLakhPlusOnly = false;

  String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    final s = dateTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _debouncedQuery = value.trim().toLowerCase();
      });
    });
  }

  List<ListingEntity> _filteredListings(List<ListingEntity> source) {
    final query = _debouncedQuery;
    final minPrice = _priceRange.start;
    final maxPrice = _priceRange.end;

    return source.where((listing) {
      final title = listing.title.toLowerCase();
      final location = listing.location.toLowerCase();
      final type = listing.propertyType.toLowerCase();
      final price = listing.pricePerNight;

      final matchesQuery =
          query.isEmpty || title.contains(query) || location.contains(query);
      final matchesType =
          _selectedPropertyType == 'All types' ||
          type == _selectedPropertyType.toLowerCase();
      final matchesPrice = _twoLakhPlusOnly
          ? price >= _twoLakh
          : (price >= minPrice && price <= maxPrice);

      return matchesQuery && matchesType && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(dashboardViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.isLoading && vm.listings.isEmpty) {
        vm.fetchListings();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Listings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: Colors.blueGrey.shade50,
            child: Text(
              'Last shake: ${_lastShakeAt == null ? '--:--:--' : _formatTime(_lastShakeAt!)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        actions: [
          // Sensor Settings Button
          IconButton(
            icon: const Icon(Icons.sensors),
            tooltip: 'Sensor Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SensorsPage()),
              );
            },
          ),
        ],
      ),
      // Wrap body with ShakeDetectorWidget
      body: ShakeDetectorWidget(
        feedbackMessage: '🤝 Refreshing properties...',
        onShake: () async {
          setState(() {
            _lastShakeAt = DateTime.now();
          });

          // Refresh listings on shake
          await vm.fetchListings();
        },
        child: _buildListingBody(vm),
      ),
    );
  }

  /// Build the actual listing body
  Widget _buildListingBody(vm) {
    final allListings = vm.listings;
    final safeEnd = _priceRange.end > _twoLakh ? _twoLakh : _priceRange.end;
    final safeStart = _priceRange.start > safeEnd ? 0.0 : _priceRange.start;
    final effectiveRange = RangeValues(safeStart, safeEnd);

    if (effectiveRange != _priceRange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _priceRange = effectiveRange;
        });
      });
    }

    final filtered = _filteredListings(allListings);

    return vm.isLoading
        ? const Center(child: CircularProgressIndicator())
        : vm.error != null
        ? Center(child: Text('Error: ${vm.error}'))
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filtered.isEmpty ? 2 : filtered.length + 1,
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
                          // Search by property name or location
                          const Text(
                            'Search',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search by name or location',
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Range Slider
                          Text(
                            'Price range: NPR ${_priceRange.start.round()} - NPR ${_priceRange.end.round()}',
                          ),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: _twoLakh,
                            divisions: 50,
                            labels: RangeLabels(
                              'NPR ${_priceRange.start.round()}',
                              'NPR ${_priceRange.end.round()}',
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _twoLakhPlusOnly = false;
                                _priceRange = values;
                              });
                            },
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _twoLakhPlusOnly,
                            title: const Text('Show only 2 Lakh+ properties'),
                            subtitle: const Text('NPR 200000 and above'),
                            onChanged: (value) {
                              setState(() {
                                _twoLakhPlusOnly = value ?? false;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          // Property Type
                          const Text('Property type'),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPropertyType,
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
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedPropertyType = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  child: Text(
                                    'Apply Filters (${filtered.length})',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _debouncedQuery = '';
                                    _selectedPropertyType = 'All types';
                                    _priceRange = const RangeValues(
                                      0,
                                      _twoLakh,
                                    );
                                    _twoLakhPlusOnly = false;
                                  });
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (filtered.isEmpty && index == 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try another name, location, property type, or price range.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Listing items
              final listing = filtered[index - 1];

              return Card(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
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
                    '${listing.location} • NPR ${listing.pricePerNight}/night',
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
          );
  }
}
