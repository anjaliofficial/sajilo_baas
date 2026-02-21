import '../entities/listing_entity.dart';
import '../repositories/i_listing_repository.dart';

class GetListingsUsecase {
  final IListingRepository repository;

  GetListingsUsecase(this.repository);

  Future<List<ListingEntity>> call() async {
    return await repository.getListings();
  }
}
