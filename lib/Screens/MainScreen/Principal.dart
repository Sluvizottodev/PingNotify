import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../Service/NotificationFireSevice.dart';
import '../../Service/TagProvider.dart';
import '../../utils/componentes/AppBarPrincipal.dart';
import '../../utils/componentes/NotificationCard.dart';
import '../../utils/componentes/NotificationsModal.dart';
import '../../utils/constants/colors.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  List<Map<String, dynamic>> _notifications = [];
  late String _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    await _initializeDeviceId();
    await _fetchUserTags();
    await _fetchNotifications();

    // Configure Firebase Messaging
    final notificationService = NotificationService();
    await notificationService.initialize();
  }

  Future<void> _initializeDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ?? '';

    if (_deviceId.isEmpty) {
      _deviceId = Uuid().v4();
      await prefs.setString('device_id', _deviceId);
    }
  }

  Future<void> _fetchUserTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_deviceId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final tags = List<String>.from(userData?['tags'] ?? []);
        tagProvider.setSelectedTags(tags.toSet()); // Atualiza as tags selecionadas
        await _fetchNotifications(); // Atualiza as notificações após as tags serem carregadas
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
          .where('tag', whereIn: tagProvider.selectedTags.isNotEmpty ? tagProvider.selectedTags.toList() : ['default'])
          .orderBy('timestamp', descending: true)
          .get();
      final notifications = notificationsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  void _handleNotification(Map<String, dynamic> notification) {
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
                      icon: _getIconForPriority(_notifications[index]['priority']),
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
  // Adicione lógica para salvar a notificação no Firestore ou atualizá-la aqui.
}
