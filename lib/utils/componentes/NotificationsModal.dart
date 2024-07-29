import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import 'NotificationCard.dart';

///Contém o widget para exibir todas as notificações em um modal.
void showNotificationsModal(BuildContext context, List<Map<String, dynamic>> notifications) {
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
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: notifications[index],
                    icon: Icons.notifications, // Use a default icon or customize based on priority
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
