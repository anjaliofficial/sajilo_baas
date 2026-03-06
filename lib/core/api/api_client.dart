import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Riverpod provider for ApiClient
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(Dio(), baseUrl: ApiEndpoints.baseUrl),
);

class ApiClient {
  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Expose secure storage for biometric authentication
  FlutterSecureStorage get secureStorage => _secureStorage;

  ApiClient(Dio dio, {required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

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
          if (path.contains('/auth/login') || path.contains('/auth/register')) {
            return false;
          }
          if (kDebugMode) print('Retrying request: $path');
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

  /// ✅ Getter for Dio instance
  Dio get dio => _dio;

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
      if (kDebugMode) print('✅ Token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving token: $e');
    }
  }

  Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      if (kDebugMode) print('🗑️ Token removed');
    } catch (e) {
      if (kDebugMode) print('❌ Error removing token: $e');
    }
  }

  Future<String?> readToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (kDebugMode) {
        if (token != null && token.isNotEmpty) {
          print('✅ Token read: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ No token found');
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error reading token: $e');
      return null;
    }
  }

  // --------------------------
  // FILE UPLOAD
  // --------------------------
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
      // Skip token for login/register
      if (options.path.contains('/auth/login') ||
          options.path.contains('/auth/register')) {
        options.headers.remove('Authorization');
      } else {
        final token = await secureStorage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          if (kDebugMode) {
            print('🔑 Sending Authorization: ${token.substring(0, 20)}...');
          }
        }
      }
      handler.next(options);
    } catch (e) {
      if (kDebugMode) print('❌ Auth interceptor error: $e');
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
