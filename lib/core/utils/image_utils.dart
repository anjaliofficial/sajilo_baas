import 'package:sajilo_baas/core/api/api_endpoints.dart';

String getFullImageUrl(String path) {
  if (path.startsWith('http')) return path;
  // Normalize backslashes to forward slashes
  String normalized = path.replaceAll('\\', '/');
  // Ensure leading slash
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  return '${ApiEndpoints.staticBaseUrl}$normalized';
}
