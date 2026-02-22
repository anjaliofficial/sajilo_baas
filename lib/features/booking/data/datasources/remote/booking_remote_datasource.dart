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
    final res = await dio.post(
      '/bookings',
      data: {
        'listingId': listingId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'totalNights': totalNights,
        'pricePerNight': pricePerNight,
        'totalPrice': totalPrice,
      },
    );
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
    final res = await dio.get('/bookings/$listingId/booked-dates');
    return (res.data['dates'] as List)
        .map((e) => DateTime.parse(e as String))
        .toList();
  }
}
