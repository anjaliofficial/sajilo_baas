import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/usecases/get_listings_usecases.dart';
import '../view_model/dashboard_view_model.dart';

final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((
  ref,
) {
  final apiClient = ApiClient(Dio(), baseUrl: ApiEndpoints.baseUrl);
  final repository = ListingRepositoryImpl(dio: apiClient.dio);
  final usecase = GetListingsUsecase(repository);
  return DashboardViewModel(usecase);
});
