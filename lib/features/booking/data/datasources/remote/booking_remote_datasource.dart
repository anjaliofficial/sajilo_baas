import 'package:dio/dio.dart';
import 'package:sajilo_baas/features/booking/domain/entities/booking_entity.dart';
import '../../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingEntity> createBooking({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  });
  Future<List<BookingModel>> getMyBookings();
  Future<void> cancelBooking(String bookingId);
  Future<List<DateTime>> getBookedDates(String listingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl(this.dio);

  @override
  Future<BookingEntity> createBooking({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  }) async {
    // Debug print: show headers before making the request
    print('🟢 Booking API call headers: ${dio.options.headers}');
    final res = await dio.post(
      '/bookings/customer',
      data: {
        'listingId': listingId,
        'checkInDate': checkIn.toIso8601String(),
        'checkOutDate': checkOut.toIso8601String(),
        'totalNights': totalNights,
        'pricePerNight': pricePerNight,
        'totalPrice': totalPrice,
      },
    );
    if (res.data == null || res.data['booking'] == null) {
      throw Exception(res.data?['message'] ?? 'Unknown booking error');
    }
    return BookingModel.fromJson(res.data['booking']);
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    final res = await dio.get('/bookings/customer/my');
    return (res.data['bookings'] as List)
        .map((e) => BookingModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await dio.put('/bookings/customer/$bookingId/cancel');
  }

  @override
  Future<List<DateTime>> getBookedDates(String listingId) async {
    try {
      final res = await dio.get('/bookings/$listingId/booked-dates');
      if (res.statusCode == 200 &&
          res.data is Map &&
          (res.data['dates'] is List)) {
        return (res.data['dates'] as List)
            .map((e) => DateTime.tryParse(e as String))
            .whereType<DateTime>()
            .toList();
      } else {
        print('Booked dates endpoint missing or invalid response: ${res.data}');
        return [];
      }
    } catch (e) {
      print('Error fetching booked dates: $e');
      return [];
    }
  }
}
