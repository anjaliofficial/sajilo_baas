import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../model/message_model.dart';

class MessageSocketDatasource {
  late IO.Socket socket;

  void connect(String token) {
    socket = IO.io(
      'http://YOUR_SERVER:5050',
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'Authorization': 'Bearer $token',
      }).build(),
    );
  }

  Stream<MessageModel> onMessage() {
    return socket
        .on('receiveMessage')
        .map((data) => MessageModel.fromJson(data));
  }
}
