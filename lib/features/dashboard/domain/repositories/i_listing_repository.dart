import '../entities/listing_entity.dart';

abstract class IListingRepository {
  Future<List<ListingEntity>> getListings();
}
