import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
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
  List<Map<String, dynamic>> _notifications = []; // Lista para armazenar as notificações
  late NtfyService _ntfyService; // Instância do serviço Ntfy para gerenciamento de notificações

  @override
  void initState() {
    super.initState();
    _ntfyService = NtfyService(); // Inicializa o serviço Ntfy
    _initializeApp(); // Chama a função para inicializar o app
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Configura o handler para mensagens recebidas em segundo plano
  }

  // Função para inicializar o aplicativo, configurando Firebase, buscando tags e notificações
  Future<void> _initializeApp() async {
    await Firebase.initializeApp();
    await _fetchUserTags();
    await _subscribeToTags();
    await _fetchNotifications();
  }

  // Função para buscar as tags do usuário no Firestore e atualizar o TagProvider
  Future<void> _fetchUserTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(tagProvider.deviceId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final tags = List<String>.from(userData?['tags'] ?? []);
        tagProvider.setSelectedTags(tags.toSet()); // Atualiza as tags selecionadas no TagProvider
      }
    } catch (e) {
      print('Erro ao buscar tags do usuário: $e');
    }
  }

  // Função para inscrever-se nas tags armazenadas no TagProvider usando o serviço Ntfy
  Future<void> _subscribeToTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      for (final tag in tagProvider.selectedTags) {
        await _ntfyService.subscribeToTag(tag);
      }
    } catch (e) {
      print('Erro ao inscrever-se nas tags: $e');
    }
  }

  // Função para buscar notificações no Firestore baseadas nas tags do usuário
  Future<void> _fetchNotifications() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tags', arrayContainsAny: tagProvider.selectedTags.toList())
          .orderBy('timestamp', descending: true)
          .get();
      final notifications = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print ('Notificações encontradas $notifications');
      setState(() {
        _notifications = notifications; // Atualiza a lista de notificações
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  // Handler para mensagens recebidas em segundo plano
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Mensagem recebida em segundo plano: ${message.messageId}');
  }

  // Função para exibir o modal de notificações
  void _showNotificationsModal() {
    showNotificationsModal(context, _notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPrincipal(fetchNotifications: _fetchNotifications), // Barra de aplicação personalizada
      backgroundColor: TColors.backgroundLight, // Cor de fundo da tela
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length, // Número de notificações na lista
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return NotificationCard(
                  notification: notification,
                  icon: Icons.notifications, // Ícone de notificação
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNotificationsModal,
        backgroundColor: TColors.primaryColor, // Cor do botão de ação flutuante
        child: Icon(Icons.notifications, color: Colors.white),
      ),
    );
  }
}
