import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants/colors.dart';

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
          style: TextStyle( color: TColors.textWhite,
            fontSize: mediaQuery.size.width * 0.05, // Tamanho de fonte responsivo
          ),
        ),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(mediaQuery.size.width * 0.04), // Padding proporcional à largura da tela
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Sem título',
              style: TextStyle(
                fontSize: mediaQuery.size.width * 0.06, // Tamanho de fonte responsivo
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
          ],
        ),
      ),
    );
  }
}
