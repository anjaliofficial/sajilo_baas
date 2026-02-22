import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/remote/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;

  BookingRepositoryImpl(this.remote);

  @override
  Future<void> createBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  }) {
    return remote.createBooking({
      'listingId': listingId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'totalNights': totalNights,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
    });
  }

  @override
  Future<List<BookingEntity>> getMyBookings() {
    return remote.getMyBookings();
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return remote.cancelBooking(bookingId);
  }
}
