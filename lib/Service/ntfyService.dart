import 'dart:convert';
import 'package:http/http.dart' as http;

class NtfyService {
  final String _topic = 'Info_alertas_nfty'; // Defina seu tópico aqui

  Future<List<String>> fetchNotifications() async {
    final url = Uri.parse('https://ntfy.sh/$_topic/json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['message'] as String).toList();
    } else {
      print('Failed to load notifications: ${response.statusCode}');
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> sendMessage({
    required String title,
    required String message,
    String priority = 'normal',
    String? tag,
  }) async {
    final url = Uri.parse('https://ntfy.sh/$_topic');
    final payload = {
      'title': title,
      'message': message,
      'priority': priority,
      // Adiciona a tag apenas se não for null
      if (tag != null) 'tag': tag,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.statusCode}');
      throw Exception('Failed to send message');
    }
  }
}
