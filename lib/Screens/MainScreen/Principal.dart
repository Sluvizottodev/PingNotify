import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Service/WebSocketService.dart';
import '../../Service/TagProvider.dart';
import '../../Service/NtfyService.dart';
import '../../utils/componentes/AppBarPrincipal.dart';
import '../../utils/componentes/NotificationCard.dart';
import '../../utils/componentes/NotificationsModal.dart';
import '../../utils/constants/colors.dart';

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
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _fetchUserTags();
    await _subscribeToTags();
    await _fetchNotifications(); // Chamada para buscar notificações antigas
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
        final eventType = decodedMessage['event'] ?? ''; // Verifique o tipo de evento
        final timestamp = DateTime.now().toUtc().add(Duration(hours: -3)); // Ajuste para horário de Brasília

        // Apenas adicionar mensagens que não sejam do tipo "open"
        if (eventType != 'open') {
          setState(() {
            _notifications.insert(0, { // Inserindo no topo da lista
              'title': 'Nova Notificação',
              'message': extractedMessage,
              'timestamp': timestamp.millisecondsSinceEpoch,
            });
          });

          // Salvar a notificação no Firestore
          _saveNotificationToFirestore('Nova Notificação', extractedMessage, timestamp);
        }
      } catch (e) {
        print('Erro ao decodificar a mensagem: $e');
      }
    });
  }

  Future<void> _saveNotificationToFirestore(String title, String message, DateTime timestamp) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'tags': Provider.of<TagProvider>(context, listen: false).selectedTags.toList(), // Adicionando tags
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

  void _showNotificationsModal() {
    showNotificationsModal(context, _notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPrincipal(fetchNotifications: _fetchNotifications),
      backgroundColor: TColors.backgroundLight,
      body: SafeArea(
        child: Stack(
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
        ),
      ),
    );
  }
}
