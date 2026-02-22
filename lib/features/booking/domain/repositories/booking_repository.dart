import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<void> createBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  });

  Future<List<BookingEntity>> getMyBookings();

  Future<void> cancelBooking(String bookingId);
}
