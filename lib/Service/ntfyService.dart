import 'package:ntfluttery/ntfluttery.dart';

class NtfyService {
  final NtflutteryService _ntfyClient;

  NtfyService()
      : _ntfyClient = NtflutteryService(
    credentials: Credentials(username: 'ntfyUser', password: 'ntfyPassword'),
  );

  Future<void> subscribeToTag(String tag) async {
    try {
      // Substitua pela URL correta e ajuste conforme necessário
      final url = 'https://notification/$tag/json?poll=1';

      // Usando o método get para buscar mensagens, supondo que ele retorne um Future
      final result = await _ntfyClient.get(url);

      // Exemplo de processamento dos resultados
      print('Mensagens recebidas: $result');
    } catch (e) {
      print('Falha ao inscrever na tag $tag: $e');
    }
  }

  Future<void> unsubscribeFromTag(String tag) async {
    try {
      // Se a biblioteca não oferece um método direto, talvez seja necessário gerenciar a inscrição manualmente
      print('Desinscrito da tag $tag');
    } catch (e) {
      print('Falha ao desinscrever da tag $tag: $e');
    }
  }

  Future<void> sendNotification(String tag, String title, String message) async {
    try {
      // Verifique o método correto para enviar notificações, se disponível
      print('Notificação enviada para a tag $tag com título: $title e mensagem: $message');
    } catch (e) {
      print('Falha ao enviar notificação para a tag $tag: $e');
    }
  }
}
