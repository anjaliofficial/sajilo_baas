import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<void> call({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  }) {
    return repository.createBooking(
      listingId: listingId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      totalNights: totalNights,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
    );
  }
}
