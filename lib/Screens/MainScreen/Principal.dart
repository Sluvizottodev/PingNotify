import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfty/utils/componentes/AppBarPrincipal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../Service/ntfyService.dart';
import '../../utils/componentes/NotificationCard.dart';
import '../../utils/componentes/NotificationsModal.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NtfyService _ntfyService = NtfyService();
  late WebSocketChannel _webSocketChannel;
  List<Map<String, dynamic>> _notifications = [];
  late String _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeWebSocket();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    await _initializeDeviceId();
    _initializeNotifications();
  }

  Future<void> _initializeDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ?? '';

    if (_deviceId.isEmpty) {
      _deviceId = Uuid().v4();
      await prefs.setString('device_id', _deviceId);
    }

    await _fetchUserTags();
  }

  void _initializeWebSocket() {
    _webSocketChannel = WebSocketChannel.connect(
      Uri.parse(
          'ws://seu-servidor-websocket.com'), // Altere para o URL do seu WebSocket
    );

    _webSocketChannel.stream.listen((message) {
      final notification = {
        'title': 'Nova mensagem WebSocket',
        'message': message,
        'timestamp': DateTime.now().toString(),
        'priority': 'normal',
        'tag': 'websocket',
      };

      setState(() {
        _notifications.insert(0, notification);
      });

      FirebaseFirestore.instance.collection('notifications').add(notification);
    });
  }

  void _initializeNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nova notificação recebida: ${message.notification?.title}');
      _handleNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, PageRoutes.messageDetail,
          arguments: message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _fetchUserTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_deviceId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final tags = List<String>.from(userData?['tags'] ?? []);
        tagProvider.setSelectedTags(tags.toSet());
        await _fetchNotifications();
      }
    } catch (e) {
      print('Erro ao buscar tags do usuário: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tag', whereIn: tagProvider.selectedTags.toList())
          .orderBy('timestamp', descending: true)
          .get();
      final notifications = notificationsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print('Notificações recebidas do servidor: $notifications');
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  void _handleNotification(RemoteMessage message) {
    final notification = {
      'title': message.notification?.title ?? 'Sem título',
      'message': message.notification?.body ?? 'Sem mensagem',
      'timestamp': DateTime.now().toString(),
      'priority': message.data['priority'] ?? 'normal',
      'tag': message.data['tag'] ?? 'unknown',
    };

    setState(() {
      _notifications.insert(0, notification);
    });

    FirebaseFirestore.instance.collection('notifications').add(notification);
  }

  IconData _getIconForPriority(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'low':
        return Icons.low_priority;
      case 'normal':
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPrincipal(fetchNotifications: _fetchNotifications),
      body: Container(
        color: TColors.backgroundLight,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _notifications.isEmpty
              ? Text(
                  'Nenhuma notificação recebida.',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontSize: 16,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return NotificationCard(
                            notification: _notifications[index],
                            icon: _getIconForPriority(
                                _notifications[index]['priority']),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        showNotificationsModal(context, _notifications);
                      },
                      child: Text('Mostrar Todas as Notificações'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: TColors.textWhite,
                        backgroundColor: TColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Notificação recebida no background: ${message.messageId}');
}
