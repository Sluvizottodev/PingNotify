import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

class MessageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const MessageDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes da Notificação',
          style: TextStyle(
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
            SizedBox(height: mediaQuery.size.height * 0.01), // Espaçamento proporcional à altura da tela
            Text(
              notification['message'] ?? 'Sem mensagem',
              style: TextStyle(
                fontSize: mediaQuery.size.width * 0.04, // Tamanho de fonte responsivo
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: mediaQuery.size.height * 0.02), // Espaçamento proporcional à altura da tela
            Text(
              'Recebido em: ${notification['timestamp'] ?? 'Desconhecido'}',
              style: TextStyle(
                fontSize: mediaQuery.size.width * 0.03, // Tamanho de fonte responsivo
                color: Colors.black54,
              ),
            ),
            SizedBox(height: mediaQuery.size.height * 0.01), // Espaçamento proporcional à altura da tela
            Text(
              'Prioridade: ${notification['priority'] ?? 'Normal'}',
              style: TextStyle(
                fontSize: mediaQuery.size.width * 0.03, // Tamanho de fonte responsivo
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
