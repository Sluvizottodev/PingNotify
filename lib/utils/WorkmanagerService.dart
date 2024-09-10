import 'package:workmanager/workmanager.dart';
import 'LocalNotification.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String title = inputData?['title'] ?? 'Título Padrão';
    String message = inputData?['message'] ?? 'Mensagem Padrão';

    // Verificar se o título e a mensagem são diferentes dos padrões
    if (title != 'Título Padrão' || message != 'Mensagem Padrão') {
      // Exibir a notificação local apenas se for diferente dos padrões
      await LocalNotificationService().showNotification(title, message);
    }

    return Future.value(true);
  });
}
//preciso que o websocket faça uma varredura nos links das tags para ver se ele não perdeu nenhuma informação e que caso contante que perdeu, recupere essa mensagem do notify e exiba no app