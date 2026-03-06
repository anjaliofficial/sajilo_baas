import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> init() async {
    await _messaging.requestPermission();
    return await _messaging.getToken();
  }

  void listenForeground(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  void listenBackground(Function(RemoteMessage) onTap) {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }
}
