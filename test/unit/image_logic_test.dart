import 'package:flutter_test/flutter_test.dart';

bool isValidImage(String fileName) {
  return fileName.endsWith('.jpg') || fileName.endsWith('.png');
}

void main() {
  test('Accepts JPG image', () {
    expect(isValidImage('photo.jpg'), true);
  });

  test('Accepts PNG image', () {
    expect(isValidImage('image.png'), true);
  });

  test('Rejects non-image file', () {
    expect(isValidImage('file.txt'), false);
  });

  test('Rejects empty filename', () {
    expect(isValidImage(''), false);
  });

  test('Rejects unsupported image format', () {
    expect(isValidImage('image.gif'), false);
  });
}
