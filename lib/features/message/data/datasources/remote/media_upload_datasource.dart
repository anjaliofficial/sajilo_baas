import 'package:dio/dio.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';

class MediaUploadDatasource {
  /// Upload a single file using the 'image' field (for backend compatibility)
  Future<Map<String, dynamic>> uploadSingle(String path) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(path),
    });
    final res = await dio.post(ApiEndpoints.uploadFile, data: form);
    return res.data;
  }

  final Dio dio;

  MediaUploadDatasource(this.dio);

  Future<List<Map<String, dynamic>>> upload(List<String> paths) async {
    final form = FormData.fromMap({
      'files': paths.map((p) => MultipartFile.fromFileSync(p)).toList(),
    });

    final res = await dio.post(ApiEndpoints.uploadFile, data: form);
    return List<Map<String, dynamic>>.from(res.data['files']);
  }
}
