import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NotificationExample {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleNotifications() async {
    final uuid = Uuid();

    final notifications = [
      {
        'title': 'Notificação de Teste 1',
        'message': 'Esta é uma mensagem de teste para a notificação 1.',
        'timestamp': DateTime.now().toString(),
        'priority': 'high',
        'tag': 'test',
      },
      {
        'title': 'Notificação de Teste 2',
        'message': 'Esta é uma mensagem de teste para a notificação 2.',
        'timestamp': DateTime.now().toString(),
        'priority': 'normal',
        'tag': 'test',
      },
    ];

    for (var notification in notifications) {
      await _firestore.collection('notifications').add(notification);
    }
  }
}
