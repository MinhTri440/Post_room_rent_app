import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Title: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FireBaseMessagingApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token:  $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
  }
}
