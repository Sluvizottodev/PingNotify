import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirestoreNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FirestoreNotificationService() {
    _initializeLocalNotifications();
    _registerToken();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _registerToken() async {
    String? token = await _fcm.getToken();
    if (token != null) {
      print('Token do dispositivo: $token');
      // Salve o token no Firestore, por exemplo, em um campo "deviceTokens"
      await FirebaseFirestore.instance.collection('users').doc('your_user_id').set({
        'deviceTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    }
  }

  void listenToTagChanges(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        List<String> tags = List<String>.from(snapshot.data()?['tags'] ?? []);
        _handleTagChanges(tags);
      }
    });
  }

  void _handleTagChanges(List<String> tags) {
    for (var tag in tags) {
      print('Nova tag detectada: $tag');
      _showLocalNotification(tag);
    }
  }

  void _showLocalNotification(String tag) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Nova Tag Adicionada',
      'Você recebeu uma nova tag: $tag',
      platformChannelSpecifics,
      payload: 'tag_payload',
    );
  }
}