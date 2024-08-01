import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permissão para iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão concedida');
    } else {
      print('Permissão negada');
    }

    // Lidar com mensagens em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Recebeu uma mensagem em primeiro plano: ${message.messageId}');
      if (message.notification != null) {
        print('Mensagem tem uma notificação: ${message.notification}');
      }
    });

    // Obter o token de FCM
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> subscribeToTags(List<String> tags) async {
    for (String tag in tags) {
      await _firebaseMessaging.subscribeToTopic(tag);
      print('Inscrito no tópico: $tag');
    }
  }

  Future<void> unsubscribeFromTags(List<String> tags) async {
    for (String tag in tags) {
      await _firebaseMessaging.unsubscribeFromTopic(tag);
      print('Desinscrito do tópico: $tag');
    }
  }
}
