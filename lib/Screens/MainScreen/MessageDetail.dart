import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class MessageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const MessageDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    String displayMessage = notification['message'] ?? 'Sem mensagem';

    DateTime? timestamp;
    if (notification['timestamp'] is String) {
      try {
        timestamp = DateTime.parse(notification['timestamp']);
      } catch (e) {
        timestamp = null;
      }
    } else if (notification['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(notification['timestamp']);
    }

    String formattedDate = timestamp != null ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp) : 'Data desconhecida';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes da Notificação',
          style: TextStyle(
            color: TColors.textWhite,
            fontSize: mediaQuery.size.width * 0.05,
          ),
        ),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView( // Adicione o SingleChildScrollView aqui
            padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] ?? 'Sem título',
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.01),
                Text(
                  displayMessage,
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.04,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.02),
                Text(
                  'Recebido em: $formattedDate',
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.03,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.01),
                Text(
                  'Prioridade: ${notification['priority'] ?? 'Normal'}',
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.03,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.1), // Adicione espaço antes do botão
              ],
            ),
          ),
          Positioned(
            left: mediaQuery.size.width * 0.03,
            bottom: mediaQuery.size.height * 0.02,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, PageRoutes.principal);
              },
              child: Icon(Icons.home, color: Colors.white),
              backgroundColor: TColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
