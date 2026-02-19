class ApiEndpoints {
  ApiEndpoints._();

  // Base URL for API routes
  static const String baseUrl = 'http://10.0.2.2:5050/api';

  // Base URL for static file serving
  static const String staticBaseUrl = 'http://10.0.2.2:5050';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String logout = '/auth/logout';

  // Profile endpoints
  static const String updateProfile = '/auth/update';

  // File upload
  static const String uploadFile = '/files/upload';
}
