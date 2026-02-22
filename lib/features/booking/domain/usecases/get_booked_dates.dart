import '../repositories/booking_repository.dart';

class GetBookedDates {
  final BookingRepository repository;

  GetBookedDates(this.repository);

  Future<List<DateTime>> call(String listingId) async {
    return repository.getBookedDates(listingId);
  }
}
