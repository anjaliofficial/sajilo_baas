import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';
import 'package:sajilo_baas/features/dashboard/domain/usecases/get_listings_usecases.dart';
// import '../../data/datasources/remote/listing_remote_datasource.dart';

class DashboardViewModel extends ChangeNotifier {
  final GetListingsUsecase getListingsUsecase;

  bool isLoading = false;
  List<ListingEntity> listings = [];
  String? error;
  String _searchQuery = '';

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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ListingEntity> get filteredListings {
    if (_searchQuery.isEmpty) return listings;
    final q = _searchQuery.toLowerCase();
    return listings
        .where(
          (l) =>
              l.title.toLowerCase().contains(q) ||
              l.location.toLowerCase().contains(q) ||
              l.propertyType.toLowerCase().contains(q),
        )
        .toList();
  }
}
