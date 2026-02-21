import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';
import 'package:sajilo_baas/features/dashboard/domain/usecases/get_listings_usecases.dart';
// import '../../data/datasources/remote/listing_remote_datasource.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetListingsUsecase getListingsUsecase;

  bool isLoading = false;
  List<ListingEntity> listings = [];
  String? error;

  DashboardViewModel(this.getListingsUsecase);

  Future<void> fetchListings() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      listings = await getListingsUsecase.call();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
