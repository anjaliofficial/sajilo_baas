// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

final savedBookingsProvider =
    StateNotifierProvider<SavedBookingsNotifier, Set<String>>((ref) {
      final apiClient = ref.read(apiClientProvider);
      return SavedBookingsNotifier(apiClient.dio);
    });

class SavedBookingsNotifier extends StateNotifier<Set<String>> {
  final Dio _dio;

  SavedBookingsNotifier(this._dio) : super({}) {
    fetchSavedBookings();
  }

  Future<void> fetchSavedBookings() async {
    try {
      final response = await _dio.get(ApiEndpoints.getSavedBookings);
      print(
        'fetchSavedBookings response: \\nStatus: \\${response.statusCode}\\nData: \\${response.data}',
      );
      if (response.statusCode == 200 && response.data is List) {
        // Try to extract id or _id from each booking object
        state = Set<String>.from(
          response.data.map(
            (b) => (b['id'] ?? b['_id'] ?? b['bookingId']).toString(),
          ),
        );
      } else if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['bookings'] is List) {
        // If wrapped in { bookings: [...] }
        final bookings = response.data['bookings'] as List;
        state = Set<String>.from(
          bookings.map(
            (b) => (b['id'] ?? b['_id'] ?? b['bookingId']).toString(),
          ),
        );
      }
    } catch (e, st) {
      print('fetchSavedBookings error: $e\\n$st');
    }
  }

  Future<void> toggle(String bookingId) async {
    try {
      final url = ApiEndpoints.saveBooking.replaceFirst('{id}', bookingId);
      final response = await _dio.post(url);
      if (response.statusCode == 200) {
        // Backend returns updated saved state (true/false)?
        if (state.contains(bookingId)) {
          state = Set<String>.from(state)..remove(bookingId);
        } else {
          state = Set<String>.from(state)..add(bookingId);
        }
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  bool isSaved(String bookingId) => state.contains(bookingId);
}
