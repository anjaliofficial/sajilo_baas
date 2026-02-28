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
        // Debug logging for token and Authorization header
        print('[DioProvider] Token: $token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('[DioProvider] Authorization header set: Bearer $token');
        } else {
          print(
            '[DioProvider] No valid token found, Authorization header not set',
          );
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
