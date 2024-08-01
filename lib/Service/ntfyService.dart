import 'dart:convert';
import 'package:http/http.dart' as http;

class NtfyService {
  final String _ntfyServerUrl = 'https://ntfy.sh'; // Base URL do servidor Ntfy

  Future<void> subscribeToTag(String tag) async {
    final url = '$_ntfyServerUrl/$tag';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Inscrito na tag $tag');
    } else {
      print('Falha ao inscrever na tag $tag: ${response.statusCode}');
    }
  }

  Future<void> unsubscribeFromTag(String tag) async {
    final url = '$_ntfyServerUrl/$tag';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Desinscrito da tag $tag');
    } else {
      print('Falha ao desinscrever da tag $tag: ${response.statusCode}');
    }
  }

  Future<void> sendNotification(String tag, String title, String message) async {
    final url = '$_ntfyServerUrl/$tag';
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
      print('Notificação enviada para a tag $tag');
    } else {
      print('Falha ao enviar notificação para a tag $tag: ${response.statusCode}');
    }
  }
}
