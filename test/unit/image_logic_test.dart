import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/services/image_service.dart';

void main() {
  final imageService = ImageService();

  test('Accepts JPG image', () {
    expect(imageService.isValidImage('photo.jpg'), true);
  });

  test('Accepts PNG image', () {
    expect(imageService.isValidImage('image.png'), true);
  });

  test('Rejects non-image file', () {
    expect(imageService.isValidImage('file.txt'), false);
  });

  test('Rejects empty filename', () {
    expect(imageService.isValidImage(''), false);
  });

  test('Rejects unsupported image format', () {
    expect(imageService.isValidImage('image.gif'), false);
  });
}
