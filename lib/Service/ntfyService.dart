import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class NtfyService {
  final String _topic = 'Info_alertas_nfty'; // Defina seu tópico aqui
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchTags() async {
    final url = Uri.parse('https://ntfy.sh/$_topic/tags');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => item.toString()).toList();
    } else {
      print('Failed to fetch tags: ${response.statusCode}');
      throw Exception('Failed to fetch tags');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final url = Uri.parse('https://ntfy.sh/$_topic/json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final notifications = data.map((item) => {
        'message': item['message'] as String,
        'timestamp': DateTime.now().toString(),
      }).toList();

      // Save notifications to Firestore
      for (var notification in notifications) {
        await _firestore.collection('notifications').add(notification);
      }

      return notifications;
    } else {
      print('Failed to load notifications: ${response.statusCode}');
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> subscribeToTag(String tag) async {
    final url = Uri.parse('https://ntfy.sh/$_topic/subscriptions');
    final payload = {
      'tag': tag,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Subscribed to tag successfully');
    } else {
      print('Failed to subscribe to tag: ${response.statusCode}');
      throw Exception('Failed to subscribe to tag');
    }
  }
}
