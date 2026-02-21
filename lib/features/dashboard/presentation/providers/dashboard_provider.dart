import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import '../../data/datasources/remote/listing_remote_datasource.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/usecases/get_listings_usecases.dart';
import '../view_model/dashboard_view_model.dart';

final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((
  ref,
) {
  final apiClient = ApiClient(baseUrl: 'http://10.33.46.20:5050/api');
  final repository = ListingRepositoryImpl(dio: apiClient.dio);
  final usecase = GetListingsUsecase(repository);
  return DashboardViewModel(usecase);
});
