import 'package:dio/dio.dart';

class MediaUploadDatasource {
  final Dio dio;

  MediaUploadDatasource(this.dio);

  Future<List<Map<String, dynamic>>> upload(List<String> paths) async {
    final form = FormData.fromMap({
      'files': paths.map((p) => MultipartFile.fromFileSync(p)).toList(),
    });

    final res = await dio.post('/api/files/upload', data: form);
    return List<Map<String, dynamic>>.from(res.data['files']);
  }
}
