import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Configurações para Android e iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
      _showNotification(message);
    });

    // Lidar com mensagens em segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mensagem aberta a partir da notificação: ${message.messageId}');
      _handleMessage(message);
    });

    // Obter o token de FCM
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'default_channel_id',
      'default_channel_name',
      channelDescription: 'default_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['payload'],
    );
  }

  void _handleMessage(RemoteMessage message) {
    // Ações específicas quando o usuário abre o app a partir de uma notificação
    // Você pode navegar para uma página específica ou executar outras ações
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
