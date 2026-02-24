import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../model/message_model.dart';

class MessageSocketDatasource {
  late IO.Socket socket;

  /// Connect to socket server using the JWT token
  void connect(String token) {
    socket = IO.io(
      ApiEndpoints.staticBaseUrl, // e.g., http://10.205.75.20:5050
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });
  }

  /// Listen for incoming messages
  void onReceiveMessage(Function(MessageModel) onMessage) {
    socket.on('receiveMessage', (data) {
      onMessage(MessageModel.fromJson(data));
    });
  }

  /// Emit a message to the server
  void sendMessage(Map<String, dynamic> messageData) {
    socket.emit('sendMessage', messageData);
  }

  void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}
