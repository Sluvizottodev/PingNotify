import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../Service/ntfyService.dart';
import '../../utils/constants/colors.dart';
import 'Messages.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NtfyService _ntfyService = NtfyService();
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchNotifications(); // Buscar notificações iniciais quando a tela é carregada
  }

  void _initializeNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nova notificação recebida: ${message.notification?.title}');
      setState(() {
        // Adiciona as notificações mais recentes no início da lista
        _notifications.insert(0, message.notification?.title ?? 'Sem título');
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, '/notificacaoDetalhes', arguments: message);
    });
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await _ntfyService.fetchNotifications();
      print('Notificações recebidas do servidor: $notifications');
      setState(() {
        // Adiciona as notificações recebidas do servidor no início da lista
        _notifications.insertAll(0, notifications);
      });
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
            color: TColors.textPrimary,
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
                        title: Text(
                          _notifications[index],
                          style: TextStyle(color: TColors.textPrimary),
                        ),
                        tileColor: TColors.neutralColor,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/notificacaoDetalhes',
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
                        title: Text(
                          _notifications[index],
                          style: TextStyle(color: TColors.textPrimary),
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
