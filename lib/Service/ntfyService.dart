import 'package:ntfluttery/ntfluttery.dart';

class NtfyService {
  final NtflutteryService _ntfyClient;

  NtfyService()
      : _ntfyClient = NtflutteryService(
    credentials: Credentials(username: 'Luvidev', password: '123456'),
  );

  Future<void> subscribeToTag(String tag) async {
    try {
      final url = 'https://ntfy.sh/$tag/json?poll=1';

      final result = await _ntfyClient.get(url);

      print('Mensagens recebidas: $result');
    } catch (e) {
      print('Falha ao inscrever na tag $tag: $e');
    }
  }

  Future<void> subscribeToTags(List<String> tags) async {
    for (String tag in tags) {
      await subscribeToTag(tag); // Inscreve-se em várias tags
    }
  }

  Future<void> unsubscribeFromTag(String tag) async {
    try {
      print('Desinscrito da tag $tag'); // Desinscreve-se de uma tag
    } catch (e) {
      print('Falha ao desinscrever da tag $tag: $e'); // Trata erros ao desinscrever
    }
  }

  Future<void> sendNotification(String tag, String title, String message) async {
    try {
      print('Notificação enviada para a tag $tag com título: $title e mensagem: $message'); // Envia uma notificação para uma tag específica
    } catch (e) {
      print('Falha ao enviar notificação para a tag $tag: $e'); // Trata erros ao enviar a notificação
    }
  }
}
