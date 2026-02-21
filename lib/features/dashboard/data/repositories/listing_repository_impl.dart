import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sajilo_baas/features/dashboard/domain/repositories/i_listing_repository.dart';
import '../../domain/entities/listing_entity.dart';

class ListingRepositoryImpl implements IListingRepository {
  final Dio _dio;

  ListingRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<ListingEntity>> getListings() async {
    try {
      final response = await _dio.get('http://10.33.46.20:5050/api/listings');

      if (response.statusCode == 200) {
        final data = response.data;

        // Safely access 'listings'
        final listingsJson = data['listings'] as List<dynamic>? ?? [];

        return listingsJson
            .map((json) => ListingEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load listings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching listings: $e');
      return [];
    }
  }

}
