import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';
import '../constants/routes.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final IconData icon;

  const NotificationCard({
    required this.notification,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    DateTime? timestamp;

    if (notification['timestamp'] is String) {
      try {
        timestamp = DateTime.parse(notification['timestamp']);
      } catch (e) {
        timestamp = DateTime.now(); // Fallback para a data atual se o parse falhar
      }
    } else if (notification['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(notification['timestamp']);
    }

    String formattedDate = timestamp != null ? formatter.format(timestamp) : 'Data desconhecida';

    final String message = notification['message'] ?? 'Sem Mensagem';
    final String? url = notification['url'];
    final String displayMessage = message.length > 50 ? '${message.substring(0, 50)}...' : message;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(
          icon,
          color: TColors.textPrimary,
        ),
        title: Text(
          notification['title'] ?? 'Sem Título',
          style: TextStyle(
            color: TColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayMessage,
              style: TextStyle(color: Colors.black),
            ),
            if (url != null) // Exibe a URL, se existir
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  url,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            if (message.length > 50 || url != null) // Exibe o botão "Ver Detalhes" se a mensagem foi cortada ou há uma URL
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    PageRoutes.messageDetail,
                    arguments: notification,
                  );
                },
                child: Text('Ver Detalhes'),
              ),
          ],
        ),
        tileColor: TColors.neutralColor,
        onTap: () {
          Navigator.pushNamed(
            context,
            PageRoutes.messageDetail,
            arguments: notification,
          );
        },
      ),
    );
  }
}
