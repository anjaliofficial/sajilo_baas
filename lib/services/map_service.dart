import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

class MapService {
  final Dio _dio;

  MapService(this._dio);

  /// Get user's current location
  Future<Position?> getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied ||
            requestPermission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // Check if location services are enabled
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      // Error getting user location
      return null;
    }
  }

  /// Fetch nearby listings from backend
  Future<List<Map<String, dynamic>>> getNearbyListings({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      print(
        'DEBUG MapService: Fetching listings - lat: $latitude, lng: $longitude, radius: $radiusKm km',
      );

      final response = await _dio.get(
        ApiEndpoints.listings,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radiusKm': radiusKm,
          'page': page,
          'limit': limit,
        },
      );

      print('DEBUG MapService: Response status: ${response.statusCode}');
      print(
        'DEBUG MapService: Response data type: ${response.data.runtimeType}',
      );

      // Check if response has data property or is directly a list
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data')) {
          final listings = List<Map<String, dynamic>>.from(data['data'] ?? []);
          print(
            'DEBUG MapService: Parsed ${listings.length} listings from data.data',
          );
          return listings;
        }
      }

      if (response.data is List) {
        final listings = List<Map<String, dynamic>>.from(response.data ?? []);
        print(
          'DEBUG MapService: Parsed ${listings.length} listings from direct list',
        );
        return listings;
      }

      print('DEBUG MapService: No listings found in response');
      return [];
    } catch (e) {
      print('DEBUG MapService: Error fetching nearby listings: $e');
      return [];
    }
  }

  /// Permission handling helper
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestPermission = await Geolocator.requestPermission();
      return requestPermission == LocationPermission.whileInUse ||
          requestPermission == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
