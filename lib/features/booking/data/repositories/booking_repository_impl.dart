import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/remote/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;

  BookingRepositoryImpl(this.remote);

  @override
  Future<BookingEntity> createBooking({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  }) async {
    return await remote.createBooking(
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
      totalNights: totalNights,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
    );
  }

  @override
  Future<List<BookingEntity>> getMyBookings() {
    return remote.getMyBookings();
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return remote.cancelBooking(bookingId);
  }

  @override
  Future<List<DateTime>> getBookedDates(String listingId) async {
    return await remote.getBookedDates(listingId);
  }
}
