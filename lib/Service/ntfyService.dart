import 'dart:convert';
import 'package:http/http.dart' as http;

class NtfyService {
  final String _ntfyServerUrl = 'http://seu-servidor-ntfy.com'; // Altere para o URL do seu servidor Ntfy

  Future<void> subscribeToTopic(String topic) async {
    final url = '$_ntfyServerUrl/subscribe/$topic';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Inscrito no tópico $topic');
    } else {
      print('Falha ao inscrever no tópico $topic: ${response.statusCode}');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final url = '$_ntfyServerUrl/unsubscribe/$topic';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Desinscrito do tópico $topic');
    } else {
      print('Falha ao desinscrever do tópico $topic: ${response.statusCode}');
    }
  }

  Future<void> sendNotification(String topic, String title, String message) async {
    final url = '$_ntfyServerUrl/$topic';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'message': message,
        'priority': 'normal',
      }),
    );

    if (response.statusCode == 200) {
      print('Notificação enviada para $topic');
    } else {
      print('Falha ao enviar notificação para $topic: ${response.statusCode}');
    }
  }
}
