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
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/listings',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radiusKm': radiusKm,
          'page': page,
          'limit': limit,
        },
      );

      // Check if response has data property or is directly a list
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data ?? []);
      }

      return [];
    } catch (e) {
      // Error fetching nearby listings
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
