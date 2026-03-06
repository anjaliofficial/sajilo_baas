import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/notification_model.dart';

class NotificationSocketDataSource {
  final WebSocketChannel channel;

  NotificationSocketDataSource(String url)
    : channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<NotificationModel> listenNotifications() {
    return channel.stream.map((event) {
      final data = jsonDecode(event);
      return NotificationModel.fromJson(data);
    });
  }
}
