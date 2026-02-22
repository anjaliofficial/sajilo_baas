import 'package:dio/dio.dart';
import '../../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(Map<String, dynamic> body);
  Future<List<BookingModel>> getMyBookings();
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl(this.dio);

  @override
  Future<void> createBooking(Map<String, dynamic> body) async {
    await dio.post('/bookings', data: body);
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
}
