import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/booking/domain/usecases/create_booking.dart';
import 'package:sajilo_baas/features/booking/domain/usecases/get_booked_dates.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_filter.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/cancel_booking.dart';

class BookingViewModel extends StateNotifier<AsyncValue<List<BookingEntity>>> {
  final GetMyBookings _getMyBookings;
  final CancelBooking _cancelBooking;
  final CreateBooking _createBooking;
  final GetBookedDates _getBookedDates;

  List<BookingEntity> _allBookings = [];

  BookingViewModel(
    this._getMyBookings,
    this._cancelBooking,
    this._createBooking,
    this._getBookedDates,
  ) : super(const AsyncLoading());

  // -------------------
  // Load bookings
  // -------------------
  Future<void> loadBookings() async {
    try {
      state = const AsyncLoading();
      _allBookings = await _getMyBookings();
      state = AsyncData(_allBookings);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // -------------------
  // Apply filters
  // -------------------
  void applyFilter(BookingFilter filter) {
    final filtered = _allBookings.where((booking) {
      // Status
      if (filter.status != null && booking.status != filter.status) {
        return false;
      }

      // From date
      if (filter.fromDate != null &&
          booking.checkInDate.isBefore(filter.fromDate!)) {
        return false;
      }

      // To date
      if (filter.toDate != null &&
          booking.checkOutDate.isAfter(filter.toDate!)) {
        return false;
      }

      // Search query
      if (filter.query != null) {
        final title = booking.listingTitle;
        if (title == null ||
            !title.toLowerCase().contains(filter.query!.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    state = AsyncData(filtered);
  }

  // -------------------
  // Cancel booking
  // -------------------
  Future<void> cancel(String bookingId) async {
    await _cancelBooking(bookingId);
    await loadBookings();
  }
}
