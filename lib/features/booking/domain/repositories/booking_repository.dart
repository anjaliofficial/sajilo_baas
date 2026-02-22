import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalNights,
    required double pricePerNight,
    required double totalPrice,
  });

  Future<List<BookingEntity>> getMyBookings();

  Future<void> cancelBooking(String bookingId);

  Future<List<DateTime>> getBookedDates(String listingId);
}
