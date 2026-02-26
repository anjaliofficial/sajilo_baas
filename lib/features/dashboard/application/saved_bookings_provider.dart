// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/network/dio_provider.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

final savedBookingsProvider =
    StateNotifierProvider<SavedBookingsNotifier, Set<String>>((ref) {
      final dio = ref.read(dioProvider);
      return SavedBookingsNotifier(dio);
    });

class SavedBookingsNotifier extends StateNotifier<Set<String>> {
  final Dio _dio;

  SavedBookingsNotifier(this._dio) : super({}) {
    fetchSavedBookings();
  }

  Future<void> fetchSavedBookings() async {
    try {
      final response = await _dio.get(ApiEndpoints.getSavedBookings);
      if (response.statusCode == 200 && response.data is List) {
        // Assuming response.data is a list of booking objects with 'id' field
        state = Set<String>.from(response.data.map((b) => b['id'].toString()));
      }
    } catch (e) {
      // Optionally handle error
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
