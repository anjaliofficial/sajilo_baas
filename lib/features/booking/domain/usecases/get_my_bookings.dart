import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetMyBookings {
  final BookingRepository repository;

  GetMyBookings(this.repository);

  Future<List<BookingEntity>> call() {
    return repository.getMyBookings();
  }
}
