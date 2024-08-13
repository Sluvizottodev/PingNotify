import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
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
          notification['title'] ?? 'No Title',
          style: TextStyle(color: TColors.textPrimary),
        ),
        subtitle: Text(
          notification['message'] ?? 'No Message',
          style: TextStyle(color: Colors.black),
        ),
        trailing: Text(
          notification['timestamp'] ?? 'No Timestamp',
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
