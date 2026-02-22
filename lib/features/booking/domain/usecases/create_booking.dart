import '../repositories/booking_repository.dart';
import '../entities/booking_entity.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<BookingEntity> call({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pricePerNight,
  }) async {
    final totalNights = checkOut.difference(checkIn).inDays;
    final totalPrice = totalNights * pricePerNight;

    return repository.createBooking(
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
      totalNights: totalNights,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
    );
  }
}
