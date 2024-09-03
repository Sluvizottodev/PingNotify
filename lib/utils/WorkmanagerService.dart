import 'package:workmanager/workmanager.dart';

import 'LocalNotification.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String title = inputData?['title'] ?? 'Título Padrão'; // Fornecer um valor padrão
    String message = inputData?['message'] ?? 'Mensagem Padrão'; // Fornecer um valor padrão

    // Aqui você pode exibir a notificação local usando FlutterLocalNotificationsPlugin
    await LocalNotificationService().showNotification(title, message);

    return Future.value(true);
  });
}

