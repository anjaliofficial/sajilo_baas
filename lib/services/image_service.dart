class ImageService {
  bool isValidImage(String fileName) {
    return fileName.endsWith('.jpg') || fileName.endsWith('.png');
  }
}
