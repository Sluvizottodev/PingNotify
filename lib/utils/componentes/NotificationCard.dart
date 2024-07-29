import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../constants/routes.dart';

///Contém o widget para exibir notificações individuais.
class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final IconData icon;

  const NotificationCard({
    required this.notification,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          notification['title'],
          style: TextStyle(color: TColors.textPrimary),
        ),
        subtitle: Text(
          notification['message'],
          style: TextStyle(color: Colors.black),
        ),
        trailing: Text(
          notification['timestamp'],
          style: TextStyle(color: Colors.black),
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
