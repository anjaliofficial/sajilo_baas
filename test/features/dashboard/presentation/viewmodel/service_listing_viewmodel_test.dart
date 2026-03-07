import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:sajilo_baas/features/dashboard/domain/usecases/get_listings_usecases.dart';
import 'package:sajilo_baas/features/dashboard/domain/entities/listing_entity.dart';

class MockGetListingsUsecase extends Mock implements GetListingsUsecase {}

// AddService and DeleteService are not present in DashboardViewModel, so not needed

void main() {
  late MockGetListingsUsecase mockGetListingsUsecase;
  late DashboardViewModel viewModel;

  setUp(() {
    mockGetListingsUsecase = MockGetListingsUsecase();
    viewModel = DashboardViewModel(mockGetListingsUsecase);
  });

  test('should emit loading state when fetching services', () async {
    // Arrange
    when(() => mockGetListingsUsecase.call()).thenAnswer((_) async => <ListingEntity>[]);

    // Act
    final future = viewModel.fetchListings();

    // Assert
    expect(viewModel.isLoading, true);
    await future;
    expect(viewModel.isLoading, false);
  });

  test('should emit success state when services fetched', () async {
    // Arrange
    final listings = [
      ListingEntity(
        id: '1',
        title: 'Test Listing',
        description: 'Desc',
        location: 'Loc',
        propertyType: 'House',
        amenities: [],
        pricePerNight: 100,
        availableFrom: DateTime.now(),
        availableTo: DateTime.now(),
        minStay: 1,
        maxGuests: 2,
        cancellationPolicy: '',
        houseRules: '',
        images: [],
        host: null,
        status: 'approved',
        latitude: null,
        longitude: null,
      ),
    ];
    when(() => mockGetListingsUsecase.call()).thenAnswer((_) async => listings);

    // Act
    await viewModel.fetchListings();

    // Assert
    expect(viewModel.isLoading, false);
    expect(viewModel.listings, isNotEmpty);
    expect(viewModel.listings.length, 1);
    expect(viewModel.error, isNull);
  });

  test('should emit empty state when no services', () async {
    // Arrange
    when(() => mockGetListingsUsecase.call()).thenAnswer((_) async => <ListingEntity>[]);

    // Act
    await viewModel.fetchListings();

    // Assert
    expect(viewModel.isLoading, false);
    expect(viewModel.listings, isEmpty);
    expect(viewModel.error, isNull);
  });

  test('should emit error state when fetch fails', () async {
    // Arrange
    when(() => mockGetListingsUsecase.call()).thenThrow(Exception('Failed'));

    // Act
    await viewModel.fetchListings();

    // Assert
    expect(viewModel.isLoading, false);
    expect(viewModel.listings, isEmpty);
    expect(viewModel.error, isNotNull);
  });

  test('should filter listings by search query', () async {
    // Arrange
    final listings = [
      ListingEntity(
        id: '1',
        title: 'Test House',
        description: 'Desc',
        location: 'Kathmandu',
        propertyType: 'House',
        amenities: [],
        pricePerNight: 100,
        availableFrom: DateTime.now(),
        availableTo: DateTime.now(),
        minStay: 1,
        maxGuests: 2,
        cancellationPolicy: '',
        houseRules: '',
        images: [],
        host: null,
        status: 'approved',
        latitude: null,
        longitude: null,
      ),
      ListingEntity(
        id: '2',
        title: 'Villa',
        description: 'Desc',
        location: 'Pokhara',
        propertyType: 'Villa',
        amenities: [],
        pricePerNight: 200,
        availableFrom: DateTime.now(),
        availableTo: DateTime.now(),
        minStay: 1,
        maxGuests: 4,
        cancellationPolicy: '',
        houseRules: '',
        images: [],
        host: null,
        status: 'approved',
        latitude: null,
        longitude: null,
      ),
    ];
    when(() => mockGetListingsUsecase.call()).thenAnswer((_) async => listings);
    await viewModel.fetchListings();

    // Act
    viewModel.setSearchQuery('Pokhara');

    // Assert
    expect(viewModel.filteredListings.length, 1);
    expect(viewModel.filteredListings.first.location, 'Pokhara');
  });
}
