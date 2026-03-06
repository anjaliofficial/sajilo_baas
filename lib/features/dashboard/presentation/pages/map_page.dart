import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/services/map_service.dart';
import '../pages/listing_details_page.dart';
import '../../domain/entities/listing_entity.dart';

class MapPage extends StatefulWidget {
  final ListingEntity? selectedListing;

  const MapPage({super.key, this.selectedListing});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapService _mapService;

  LatLng? _userLocation;
  String? _currentLocationName;
  String? _destinationLocationName;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _error;
  double _radiusKm = 10;
  double? _distanceToSelected;
  int? _driveTimeMinutes;
  List<ListingEntity> _listings = [];

  static const LatLng _defaultLocation = LatLng(27.7172, 85.3240); // Kathmandu

  // Calculate haversine distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadiusKm = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLong = _degreesToRadians(point2.longitude - point1.longitude);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            sin(dLong / 2) *
            sin(dLong / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  int _estimateDriveTime(double distanceKm) {
    // Rough estimate: ~30 km/h average speed
    // 30 km/h = 0.5 km/min
    return (distanceKm / 0.5).round();
  }

  Future<String?> _getLocationName(LatLng location) async {
    try {
      final nominatimUrl =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}';

      final response = await Dio().get(
        nominatimUrl,
        options: Options(headers: {'User-Agent': 'SajiloBaas/1.0'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Get address in order: road, city, state
          final road = address['road'] ?? address['street'] ?? '';
          final city = address['city'] ?? address['town'] ?? '';
          final area = address['suburb'] ?? address['neighbourhood'] ?? '';

          if (road.isNotEmpty) {
            return '$road, $city';
          } else if (city.isNotEmpty) {
            return city;
          } else if (area.isNotEmpty) {
            return area;
          }
        }
      }
    } catch (e) {
      // Silently fail and return null
    }
    return null;
  }

  Future<void> _createRoutePolyline(
    LatLng userLocation,
    LatLng destination,
  ) async {
    try {
      // Use OSRM (Open Source Routing Machine) - FREE, no API key needed
      final osrmUrl =
          'https://router.project-osrm.org/route/v1/driving/${userLocation.longitude},${userLocation.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

      final response = await Dio().get(osrmUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final route = routes[0] as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>?;

          if (geometry != null) {
            final coordinates = geometry['coordinates'] as List?;

            if (coordinates != null && coordinates.isNotEmpty) {
              // Convert coordinates to LatLng points
              final routePoints = coordinates
                  .map(
                    (coord) => LatLng(
                      (coord[1] as num).toDouble(),
                      (coord[0] as num).toDouble(),
                    ),
                  )
                  .toList();

              final polylines = <Polyline>[];
              polylines.add(
                Polyline(
                  points: routePoints,
                  color: Colors.blue,
                  strokeWidth: 4.0,
                ),
              );

              setState(() {
                _polylines = polylines;
              });
              return;
            }
          }
        }
      }

      // Fallback to straight line if route fetch fails
      final polylines = <Polyline>[];
      polylines.add(
        Polyline(
          points: [userLocation, destination],
          color: Colors.blue,
          strokeWidth: 4.0,
        ),
      );

      setState(() {
        _polylines = polylines;
      });
    } catch (e) {
      // Fallback to straight line if there's an error
      final polylines = <Polyline>[];
      polylines.add(
        Polyline(
          points: [userLocation, destination],
          color: Colors.blue,
          strokeWidth: 4.0,
        ),
      );

      if (mounted) {
        setState(() {
          _polylines = polylines;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _mapService = MapService(dio);
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user location
      final position = await _mapService.getUserLocation();
      final userLat = position?.latitude ?? _defaultLocation.latitude;
      final userLng = position?.longitude ?? _defaultLocation.longitude;
      final userLocation = LatLng(userLat, userLng);

      // Get current location name
      final locationName = await _getLocationName(userLocation);

      setState(() {
        _userLocation = userLocation;
        _currentLocationName = locationName ?? 'Current Location';
      });

      // If a specific listing is selected, show only that property with route
      if (widget.selectedListing != null) {
        final selectedListing = widget.selectedListing!;

        // Check if we have coordinates for this listing
        if (selectedListing.latitude != null &&
            selectedListing.longitude != null) {
          final selectedPoint = LatLng(
            selectedListing.latitude!,
            selectedListing.longitude!,
          );

          // Display only the selected listing
          _createMarkersForSelectedListing(selectedListing, selectedPoint);

          // Get destination location name
          final destName = await _getLocationName(selectedPoint);

          // Create route polyline with real road path
          await _createRoutePolyline(_userLocation!, selectedPoint);

          // Calculate distance and drive time
          final distance = _calculateDistance(_userLocation!, selectedPoint);
          final driveTime = _estimateDriveTime(distance);

          setState(() {
            _distanceToSelected = distance;
            _driveTimeMinutes = driveTime;
            _destinationLocationName = destName ?? selectedListing.location;
          });
        } else {
          // No coordinates available, show listing at default location
          _createMarkersForSelectedListing(selectedListing, _userLocation!);

          setState(() {
            _error = 'Location coordinates not available for this property';
          });
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Browse mode: fetch all nearby listings
        final listingsData = await _mapService.getNearbyListings(
          latitude: userLat,
          longitude: userLng,
          radiusKm: _radiusKm,
        );

        if (mounted) {
          _createMarkers(listingsData);

          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load map: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _createMarkersForSelectedListing(
    ListingEntity listing,
    LatLng location,
  ) {
    final newMarkers = <Marker>[];
    final newListings = <ListingEntity>[listing];

    // Add user location marker (blue dot like Google Maps)
    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          point: _userLocation!,
          width: 60,
          height: 60,
          rotate: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add property location marker
    newMarkers.add(
      Marker(
        point: location,
        width: 100,
        height: 100,
        rotate: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                listing.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.location_pin, color: Colors.green, size: 40),
          ],
        ),
      ),
    );

    setState(() {
      _markers = newMarkers;
      _listings = newListings;
    });
  }

  void _createMarkers(List<dynamic> listingsData) {
    final newMarkers = <Marker>[];
    final newListings = <ListingEntity>[];

    // Add user location marker first (blue dot like Google Maps)
    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          point: _userLocation!,
          width: 60,
          height: 60,
          rotate: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    for (final listing in listingsData) {
      try {
        final lat = listing['latitude'] ?? listing['lat'];
        final lng = listing['longitude'] ?? listing['lng'];

        if (lat != null && lng != null) {
          final markerId = listing['_id'] ?? listing['id'] ?? '';
          final title = listing['title'] ?? 'Property';
          final price = listing['pricePerNight'] ?? 0;

          // Create marker
          newMarkers.add(
            Marker(
              point: LatLng(
                double.parse(lat.toString()),
                double.parse(lng.toString()),
              ),
              width: 80,
              height: 80,
              rotate: false,
              child: GestureDetector(
                onTap: () => _showListingPreview(listing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_pin, color: Colors.red, size: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NPR $price',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Store listing for details navigation
          newListings.add(
            ListingEntity(
              id: markerId,
              title: title,
              description: listing['description'] ?? '',
              location: listing['location'] ?? '',
              propertyType: listing['propertyType'] ?? '',
              amenities: List<String>.from(listing['amenities'] ?? []),
              pricePerNight: (price as num).toInt(),
              availableFrom: listing['availableFrom'] != null
                  ? DateTime.parse(listing['availableFrom'])
                  : DateTime.now(),
              availableTo: listing['availableTo'] != null
                  ? DateTime.parse(listing['availableTo'])
                  : DateTime.now(),
              minStay: listing['minStay'] ?? 1,
              maxGuests: listing['maxGuests'] ?? 1,
              cancellationPolicy: listing['cancellationPolicy'] ?? '',
              houseRules: listing['houseRules'] ?? '',
              images: List<String>.from(listing['images'] ?? []),
              status: listing['status'] ?? '',
              latitude: double.tryParse(lat.toString()),
              longitude: double.tryParse(lng.toString()),
            ),
          );
        }
      } catch (e) {
        // Error creating marker, skipping
      }
    }

    setState(() {
      _markers = newMarkers;
      _listings = newListings;
    });
  }

  void _showListingPreview(Map<String, dynamic> listing) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing['title'] ?? 'Property',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('NPR ${listing['pricePerNight'] ?? 0}/night'),
              Text(listing['location'] ?? 'Unknown location'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final listingEntity = _listings.firstWhere(
                      (l) => l.id == (listing['_id'] ?? listing['id']),
                      orElse: () => ListingEntity(
                        id: '',
                        title: '',
                        description: '',
                        location: '',
                        propertyType: '',
                        amenities: [],
                        pricePerNight: 0,
                        availableFrom: DateTime.now(),
                        availableTo: DateTime.now(),
                        minStay: 1,
                        maxGuests: 1,
                        cancellationPolicy: '',
                        houseRules: '',
                        images: [],
                        status: '',
                      ),
                    );
                    Navigator.pop(context);
                    if (listingEntity.id.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailsPage(listing: listingEntity),
                        ),
                      );
                    }
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateRadius(double newRadius) {
    setState(() {
      _radiusKm = newRadius;
    });
    _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isNavigating && widget.selectedListing != null
            ? Row(
                children: [
                  const Icon(Icons.navigation, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_distanceToSelected?.toStringAsFixed(1)} km • $_driveTimeMinutes min',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          widget.selectedListing?.title ?? 'Property',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                widget.selectedListing != null
                    ? 'Property Location'
                    : 'Nearby Properties',
              ),
        backgroundColor: _isNavigating ? Colors.blue : Colors.white,
        foregroundColor: _isNavigating ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Flutter Map (OpenStreetMap - FREE, no API key needed)
          if (_userLocation != null && !_isLoading)
            FlutterMap(
              options: MapOptions(
                initialCenter: _userLocation ?? _defaultLocation,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sajilo_baas',
                ),
                if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
                MarkerLayer(markers: _markers),
              ],
            )
          else if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _error ?? 'Could not get your location',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMapData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          // Navigation header at top (when navigating)
          if (_isNavigating && widget.selectedListing != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To: ${_destinationLocationName ?? widget.selectedListing?.title ?? "Property"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${_distanceToSelected?.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Text(
                              '$_driveTimeMinutes min',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(
                              'ETA',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Info card at bottom
          if (!_isLoading && !_isNavigating)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.selectedListing != null &&
                        _distanceToSelected != null &&
                        _driveTimeMinutes != null) ...[
                      // Show distance and drive time for selected listing
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Start location
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Start',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _currentLocationName ??
                                            'Current Location',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            // Destination location
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Destination',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _destinationLocationName ??
                                            widget.selectedListing?.title ??
                                            'Property',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Distance and time info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.route, color: Colors.blue),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_distanceToSelected?.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Distance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.drive_eta,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_driveTimeMinutes min',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Drive Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Navigation button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isNavigating = !_isNavigating;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isNavigating
                                      ? Colors.red
                                      : Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isNavigating
                                          ? Icons.stop_circle
                                          : Icons.navigation,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isNavigating
                                          ? 'Stop Navigation'
                                          : 'Start Navigation',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (widget.selectedListing == null) ...[
                      // Show search radius slider for browsing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Search Radius',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_radiusKm.toStringAsFixed(0)} km'),
                        ],
                      ),
                      Slider(
                        value: _radiusKm,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: _updateRadius,
                      ),
                      Text(
                        '${_markers.length} properties found',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Navigation stop button (floating at bottom)
          if (_isNavigating)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isNavigating = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stop_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'End Navigation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
