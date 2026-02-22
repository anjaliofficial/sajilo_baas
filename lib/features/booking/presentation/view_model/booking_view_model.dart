import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/cancel_booking.dart';

class BookingViewModel extends StateNotifier<AsyncValue<List<BookingEntity>>> {
  final GetMyBookings getMyBookings;
  final CancelBooking cancelBooking;

  BookingViewModel(this.getMyBookings, this.cancelBooking)
    : super(const AsyncLoading());

  Future<void> loadBookings() async {
    state = const AsyncLoading();
    try {
      final bookings = await getMyBookings();
      state = AsyncData(bookings);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> cancel(String bookingId) async {
    await cancelBooking(bookingId);
    await loadBookings();
  }
}
