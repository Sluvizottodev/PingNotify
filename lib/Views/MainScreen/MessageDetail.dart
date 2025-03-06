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
    String title = notification['title'] ?? 'Sem título';
    List<String> tags = List<String>.from(notification['tags'] ?? []);

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

    String formattedDate = timestamp != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(timestamp)
        : 'Data desconhecida';

    // Usar a primeira tag como título, ou "Detalhes da Notificação" se não houver tags
    String appBarTitle = tags.isNotEmpty ? tags.first : 'Detalhes da Notificação';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: TColors.textWhite,
            fontSize: mediaQuery.size.width * 0.05,
          ),
        ),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: mediaQuery.size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.01),
              Container(
                padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildMessageParagraphs(displayMessage, mediaQuery),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              // Exibir as tags apenas se houver
              if (tags.isNotEmpty) ...[
                Text(
                  'Tags: ${tags.join(', ')}',
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.04,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.02),
              ],
              Row(
                children: [
                  Icon(Icons.access_time, color: TColors.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    '$formattedDate',
                    style: TextStyle(
                      fontSize: mediaQuery.size.width * 0.04,
                      color: TColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessageParagraphs(String message, MediaQueryData mediaQuery) {
    List<String> paragraphs = message.split('\n');
    return paragraphs.map((paragraph) {
      return Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.size.height * 0.01),
        child: Text(
          paragraph,
          style: TextStyle(
            fontSize: mediaQuery.size.width * 0.04,
            color: TColors.textPrimary,
          ),
        ),
      );
    }).toList();
  }
}
