import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Service/WebSocketService.dart';
import '../../Service/TagProvider.dart';
import '../../Service/ntfy/ntfyService.dart';
import '../../utils/WorkmanagerService.dart';
import '../../utils/constants/colors.dart';
import 'package:workmanager/workmanager.dart';

import '../../utils/constants/routes.dart';
import '../../widgets/AppBarPrincipal.dart';
import '../../widgets/NotificationCard.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  late NtfyService _ntfyService;
  late WebSocketService _webSocketService;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _ntfyService = NtfyService();
    _initializeApp().then((_) => _initializeWebSocketService());
    Workmanager().initialize(callbackDispatcher); // Inicializa o WorkManager
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _fetchUserTags();
    await _subscribeToTags();
    await _fetchNotifications();
  }

  Future<void> _fetchUserTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(tagProvider.deviceId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final tags = List<String>.from(userData?['tags'] ?? []);
        tagProvider.setSelectedTags(tags.toSet());
      }
    } catch (e) {
      print('Erro ao buscar tags do usuário: $e');
    }
  }

  Future<void> _subscribeToTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      await _ntfyService.subscribeToTags(tagProvider.selectedTags.toList());
    } catch (e) {
      print('Erro ao inscrever-se nas tags: $e');
    }
  }

  void _initializeWebSocketService() {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    final urls = tagProvider.selectedTags.map((tag) => 'wss://ntfy.sh/$tag/ws').toList();
    _webSocketService = WebSocketService(urls);

    _webSocketService.messages.listen((message) {
      print('Mensagem recebida via WebSocket: $message');

      try {
        final decodedMessage = jsonDecode(message) as Map<String, dynamic>;
        final extractedMessage = decodedMessage['message'] ?? 'Sem Mensagem';
        final eventType = decodedMessage['event'] ?? '';
        final timestamp = DateTime.now().toUtc().add(Duration(hours: -3));

        if (eventType != 'open' && !extractedMessage.contains('result: success, dartTask:')) {
          setState(() {
            _notifications.insert(0, {
              'title': 'Nova Notificação',
              'message': extractedMessage,
              'timestamp': timestamp.millisecondsSinceEpoch,
            });
          });

          _saveNotificationToFirestore('Nova Notificação', extractedMessage, timestamp);
          _scheduleNotification('Nova Notificação', extractedMessage);
        }
      } catch (e) {
        print('Erro ao decodificar a mensagem: $e');
      }
    });

    // Verifica mensagens não lidas ao abrir o WebSocket
    _fetchUnreadNotifications();
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tags', arrayContainsAny: tagProvider.selectedTags.toList())
          .where('read', isEqualTo: false) // Assumindo que há um campo 'read' para controlar o status
          .orderBy('timestamp', descending: true)
          .get();

      final unreadNotifications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp timestamp = data['timestamp'] as Timestamp;
        return {
          ...data,
          'timestamp': timestamp.toDate().millisecondsSinceEpoch,
        };
      }).toList();

      setState(() {
        _notifications.addAll(unreadNotifications);
      });
    } catch (e) {
      print('Erro ao buscar notificações não lidas: $e');
    }
  }

  Future<void> _saveNotificationToFirestore(String title, String message, DateTime timestamp) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('message', isEqualTo: message)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Mensagem já existe no Firestore. Não salvando novamente.');
        return;
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'tags': Provider.of<TagProvider>(context, listen: false).selectedTags.toList(),
        'read': false, // Adiciona um campo 'read' para rastreamento
      });
    } catch (e) {
      print('Erro ao salvar notificação no Firestore: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tags', arrayContainsAny: tagProvider.selectedTags.toList())
          .orderBy('timestamp', descending: true)
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp timestamp = data['timestamp'] as Timestamp;
        return {
          ...data,
          'timestamp': timestamp.toDate().millisecondsSinceEpoch,
        };
      }).toList();

      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  Future<void> _scheduleNotification(String title, String message) async {
    await Workmanager().registerOneOffTask(
      'notificationTask',
      'notificationTask',
      inputData: {
        'title': title,
        'message': message,
      },
      initialDelay: Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _notifications.isNotEmpty;
    final highlightTags = !hasNotifications;

    return Scaffold(
      appBar: AppBarPrincipal(fetchNotifications: _fetchNotifications, highlightTags: highlightTags),
      backgroundColor: TColors.backgroundLight,
      body: SafeArea(
        child: hasNotifications
            ? Stack(
          children: [
            Positioned.fill(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return NotificationCard(
                    notification: notification,
                    icon: Icons.notifications,
                  );
                },
              ),
            ),
          ],
        )
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nenhuma notificação disponível.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final selectedTags = await Navigator.pushNamed(context, PageRoutes.tagSelection) as List<String>?;
                    if (selectedTags != null) {
                      Provider.of<TagProvider>(context, listen: false).setSelectedTags(selectedTags.toSet());
                      await _fetchNotifications();
                    }
                  },
                  child: Text(
                    'Verifique as tags às quais você está inscrito.',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
