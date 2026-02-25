class MessageMediaEntity {
  final String url;
  final String kind;
  final String mimeType;
  final String? fileName;

  const MessageMediaEntity({
    required this.url,
    required this.kind,
    required this.mimeType,
    this.fileName,
  });
}
