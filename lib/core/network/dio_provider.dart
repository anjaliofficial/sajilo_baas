import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core//api/api_endpoints.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Attach Authorization header from authViewModelProvider
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final authState = ref.read(authViewModelProvider);
        final token = authState.authEntity?.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
