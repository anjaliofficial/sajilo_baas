import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Riverpod provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Log the base URL for debugging (especially helpful for network issues)
    if (kDebugMode) {
      print('🌐 API Base URL: ${ApiEndpoints.baseUrl}');
      print('📱 Is Physical Device: ${ApiEndpoints.isPhysicalDevice}');
      // print('🧪 Using Mock Data: ${ApiEndpoints.useMockData}');
    }

    // JWT Interceptor
    _dio.interceptors.add(_AuthInterceptor(_secureStorage));

    // Retry failed requests automatically
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, _) {
          final path = error.requestOptions.path;
          // Don't retry auth endpoints
          if (path.contains('/auth/login') || path.contains('/auth/register')) {
            return false;
          }
          if (kDebugMode) {
            print('Retrying request: $path');
          }
          return true;
        },
      ),
    );

    // Pretty logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  // --------------------------
  // HTTP METHODS
  // --------------------------

  Future<Response> get(
    String path, {
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) => _dio.get(path, options: options, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);

  // --------------------------
  // TOKEN HELPERS
  // --------------------------

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('✅ Token saved successfully: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving token: $e');
      }
    }
  }

  Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      if (kDebugMode) {
        print('🗑️ Token removed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing token: $e');
      }
    }
  }

  Future<String?> readToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (kDebugMode) {
        if (token != null && token.isNotEmpty) {
          print('✅ Token read successfully: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ No token found in secure storage');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading token: $e');
      }
      return null;
    }
  }

  // --------------------------
  // FILE UPLOAD
  // --------------------------

  /// Upload a file with optional custom field name
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });
    return _dio.post(path, data: formData);
  }
}

// --------------------------
// JWT INTERCEPTOR
// --------------------------
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  static const _tokenKey = 'auth_token';

  _AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Remove token for login/register
      if (options.path.contains('/auth/login') ||
          options.path.contains('/auth/register')) {
        options.headers.remove('Authorization');
        if (kDebugMode) {
          print('🔓 Making ${options.method} ${options.path} without auth');
        }
      } else {
        final token = await secureStorage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          if (kDebugMode) {
            print('✅ Added token to ${options.method} ${options.path}');
          }
        } else {
          if (kDebugMode) {
            print(
              '⚠️ Warning: No token found for ${options.method} ${options.path}',
            );
            print('   This is normal if you haven\'t logged in yet.');
          }
        }
      }
      handler.next(options);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth interceptor error: $e');
      }
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ API Error: ${err.message}');
      print('   Status: ${err.response?.statusCode}');
      print('   Path: ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}
