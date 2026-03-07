import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';
import 'package:sajilo_baas/features/dashboard/domain/repositories/i_listing_repository.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/customer_main_navigation.dart';
import 'package:sajilo_baas/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sajilo_baas/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:sajilo_baas/features/dashboard/domain/usecases/get_listings_usecases.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';

void main() {
  testWidgets('renders CustomerMainNavigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => _MockDashboardViewModel(),
          ),
        ],
        child: MaterialApp(home: CustomerMainNavigation()),
      ),
    );
    expect(find.byType(CustomerMainNavigation), findsOneWidget);
  });
}

// Mock DashboardViewModel
class _MockDashboardViewModel extends DashboardViewModel {
  _MockDashboardViewModel() : super(_FakeGetListingsUsecase());
  @override
  bool isLoading = false;
  @override
  List<ListingEntity> listings = [];
  @override
  String? error;
  @override
  final String _searchQuery = '';
  @override
  List<ListingEntity> get filteredListings => listings;
  @override
  Future<void> fetchListings() async {}
  @override
  void setSearchQuery(String query) {}
}

class _FakeGetListingsUsecase extends GetListingsUsecase {
  _FakeGetListingsUsecase() : super(_FakeRepository());
  @override
  Future<List<ListingEntity>> call() async => [];
}

class _FakeRepository implements IListingRepository {
  @override
  Future<List<ListingEntity>> getListings() async => [];
}
