import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/network/dio_provider.dart';
import 'package:sajilo_baas/features/booking/domain/entities/booking_entity.dart';

// import '../../../core/providers/dio_provider.dart';

import '../../data/datasources/remote/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../view_model/booking_view_model.dart';

// Data source
final bookingRemoteDataSourceProvider = Provider(
  (ref) => BookingRemoteDataSourceImpl(ref.read(dioProvider)),
);

// Repository
final bookingRepositoryProvider = Provider(
  (ref) => BookingRepositoryImpl(ref.read(bookingRemoteDataSourceProvider)),
);

// Use cases
final getMyBookingsProvider = Provider(
  (ref) => GetMyBookings(ref.read(bookingRepositoryProvider)),
);

final cancelBookingProvider = Provider(
  (ref) => CancelBooking(ref.read(bookingRepositoryProvider)),
);

// ViewModel
final bookingViewModelProvider =
    StateNotifierProvider<BookingViewModel, AsyncValue<List<BookingEntity>>>(
      (ref) => BookingViewModel(
        ref.read(getMyBookingsProvider),
        ref.read(cancelBookingProvider),
      ),
    );
