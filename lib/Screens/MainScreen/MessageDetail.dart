import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

class MessageDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const MessageDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Notificação'),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Sem título',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 8), // Reduzi o espaçamento entre o título e a mensagem
            Text(
              notification['message'] ?? 'Sem mensagem',
              style: TextStyle(
                fontSize: 16,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Recebido em: ${notification['timestamp'] ?? 'Desconhecido'}', // Adicione valor padrão
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8), // Reduzi o espaçamento para consistência
            Text(
              'Prioridade: ${notification['priority'] ?? 'Normal'}', // Adicione valor padrão
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
