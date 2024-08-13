import 'package:ntfluttery/ntfluttery.dart';

class NtfyService {
  final NtflutteryService _ntfyClient;

  NtfyService()
      : _ntfyClient = NtflutteryService(
    credentials: Credentials(username: 'XSoftware', password: 'X123456'),
  );

  Future<void> subscribeToTag(String tag) async {
    try {
      final url = 'https://ntfy.sh/$tag/json?poll=1'; // URL ajustada para Ntfy

      final result = await _ntfyClient.get(url);

      print('Mensagens recebidas: $result');
    } catch (e) {
      print('Falha ao inscrever na tag $tag: $e');
    }
  }

  Future<void> unsubscribeFromTag(String tag) async {
    try {
      print('Desinscrito da tag $tag');
    } catch (e) {
      print('Falha ao desinscrever da tag $tag: $e');
    }
  }

  Future<void> sendNotification(String tag, String title, String message) async {
    try {
      print('Notificação enviada para a tag $tag com título: $title e mensagem: $message');
    } catch (e) {
      print('Falha ao enviar notificação para a tag $tag: $e');
    }
  }
}
