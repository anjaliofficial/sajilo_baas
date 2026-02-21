import '../../../../../core/api/api_client.dart';
import '../../models/listing_api_model.dart';

class ListingRemoteDatasource {
  final ApiClient apiClient;

  ListingRemoteDatasource(this.apiClient);

  Future<List<ListingApiModel>> getListings() async {
    // 1️⃣ Call backend
    final response = await apiClient.get('/listings');

    // 2️⃣ Extract the wrapped data array safely
    final rawData = response.data['data'];
    final List data = (rawData is List) ? rawData : [];

    // 3️⃣ Filter only approved listings
    final approvedListings = data
        .where((e) => e['status'] == 'approved')
        .map((e) => ListingApiModel.fromJson(e))
        .toList();

    return approvedListings;
  }
}
