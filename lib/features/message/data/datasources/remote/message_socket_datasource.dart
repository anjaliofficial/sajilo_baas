import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../model/message_model.dart';

class MessageSocketDatasource {
  late IO.Socket socket;

  void connect(String token) {
    socket = IO.io(
      'http://YOUR_SERVER_IP:5050',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.connect();
  }

  void onReceiveMessage(Function(MessageModel) onMessage) {
    socket.on('receiveMessage', (data) {
      onMessage(MessageModel.fromJson(data));
    });
  }

  void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}
