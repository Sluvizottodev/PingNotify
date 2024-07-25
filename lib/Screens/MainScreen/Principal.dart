import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../Service/ntfyService.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart'; // Certifique-se de que isso está correto

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NtfyService _ntfyService = NtfyService();
  List<Map<String, dynamic>> _notifications = [];
  Set<String> _userTags = Set<String>();
  late String _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
    _initializeNotifications();
  }

  Future<void> _initializeDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ?? '';

    if (_deviceId.isEmpty) {
      // Generate a new UUID if not found
      _deviceId = Uuid().v4();
      await prefs.setString('device_id', _deviceId);
    }

    // Fetch user tags and notifications after getting device ID
    await _fetchUserTags();
  }

  void _initializeNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nova notificação recebida: ${message.notification?.title}');
      _handleNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, PageRoutes.messageDetail, arguments: message);
    });

    // Também escuta notificações enquanto o app está em background ou fechado
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _fetchUserTags() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_deviceId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final tags = List<String>.from(userData?['tags'] ?? []);
        setState(() {
          _userTags = tags.toSet();
        });
        _fetchNotifications(); // Recarrega as notificações após obter as tags do usuário
      }
    } catch (e) {
      print('Erro ao buscar tags do usuário: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tag', whereIn: _userTags.toList()) // Filtrar por tags
          .orderBy('timestamp', descending: true)
          .get();
      final notifications = notificationsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print('Notificações recebidas do servidor: $notifications');
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  void _handleNotification(RemoteMessage message) {
    setState(() {
      _notifications.insert(0, {
        'title': message.notification?.title ?? 'Sem título',
        'message': message.notification?.body ?? 'Sem mensagem',
        'timestamp': DateTime.now().toString(),
        'priority': message.data['priority'] ?? 'normal',
        'tag': message.data['tag'] ?? 'unknown',
      });
    });

    // Save notification to Firestore
    FirebaseFirestore.instance.collection('notifications').add({
      'title': message.notification?.title ?? 'Sem título',
      'message': message.notification?.body ?? 'Sem mensagem',
      'timestamp': DateTime.now(),
      'priority': message.data['priority'] ?? 'normal',
      'tag': message.data['tag'] ?? 'unknown',
    });
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
      appBar: AppBar(
        title: Text('Notificações', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.tag, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, PageRoutes.tagSelection);
            },
          ),
        ],
        automaticallyImplyLeading: false, // Remove a seta de retorno
      ),
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
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          _getIconForPriority(_notifications[index]['priority']),
                          color: TColors.textPrimary,
                        ),
                        title: Text(
                          _notifications[index]['title'],
                          style: TextStyle(color: TColors.textPrimary),
                        ),
                        subtitle: Text(
                          _notifications[index]['message'],
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Text(
                          _notifications[index]['timestamp'],
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: TColors.neutralColor,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            PageRoutes.messageDetail,
                            arguments: _notifications[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showNotificationsDetails,
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

  void _showNotificationsDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Todas as Notificações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          _getIconForPriority(_notifications[index]['priority']),
                          color: TColors.textPrimary,
                        ),
                        title: Text(
                          _notifications[index]['title'],
                          style: TextStyle(color: TColors.textPrimary),
                        ),
                        subtitle: Text(
                          _notifications[index]['message'],
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Text(
                          _notifications[index]['timestamp'],
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: TColors.neutralColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure that Flutter is initialized
  await Firebase.initializeApp();
  // Handle the notification in the background
}
