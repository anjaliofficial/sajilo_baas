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
        print('[DioProvider] Request: ${options.method} ${options.uri}');
        print('[DioProvider] Request headers: ${options.headers}');
        print('[DioProvider] Request body: ${options.data}');
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
      onResponse: (response, handler) {
        print(
          '[DioProvider] Response [${response.statusCode}]: ${response.requestOptions.uri}',
        );
        print('[DioProvider] Response headers: ${response.headers}');
        print('[DioProvider] Response body: ${response.data}');
        handler.next(response);
      },
      onError: (DioError error, handler) {
        print(
          '[DioProvider] Error [${error.response?.statusCode}]: ${error.requestOptions.uri}',
        );
        print('[DioProvider] Error response: ${error.response?.data}');
        handler.next(error);
      },
    ),
  );

  return dio;
});
