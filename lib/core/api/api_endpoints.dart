// lib/core/api/api_endpoints.dart

// lib/core/api/api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL pointing to your backend
  static const String baseUrl = 'http://10.0.2.2:5050/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String logout = '/auth/logout';

  // ✅ Profile endpoint (update)
  static const String updateProfile = '/auth/update';
}
