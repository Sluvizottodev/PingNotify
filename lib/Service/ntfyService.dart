import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NtfyService {
  final String _baseUrl = 'https://ntfy.sh/';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> fetchTags(String topic) async {
    final url = Uri.parse('$_baseUrl$topic/tags');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => item.toString()).toList();
    } else {
      print('Failed to fetch tags: ${response.statusCode}');
      throw Exception('Failed to fetch tags');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications(List<String> tags, {DateTime? since}) async {
    List<Map<String, dynamic>> allNotifications = [];
    for (var tag in tags) {
      final url = Uri.parse('$_baseUrl$tag/json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final notifications = data.map((item) {
          final timestamp = DateTime.parse(item['timestamp']);
          if (since != null && timestamp.isBefore(since)) {
            return null;
          }
          return {
            'message': item['message'] as String,
            'timestamp': timestamp.toString(),
            'tag': tag,
          };
        }).where((item) => item != null).cast<Map<String, dynamic>>().toList();

        allNotifications.addAll(notifications);
      } else {
        print('Failed to load notifications for tag $tag: ${response.statusCode}');
        throw Exception('Failed to load notifications for tag $tag');
      }
    }

    // Save notifications to Firestore
    for (var notification in allNotifications) {
      await _saveNotificationToFirestore(notification);
    }

    return allNotifications;
  }

  Future<void> subscribeToTags(List<String> tags) async {
    final url = Uri.parse('$_baseUrl/subscriptions');
    final payload = {
      'tags': tags,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Subscribed to tags successfully');
    } else {
      print('Failed to subscribe to tags: ${response.statusCode}');
      throw Exception('Failed to subscribe to tags');
    }
  }

  Future<void> _saveNotificationToFirestore(Map<String, dynamic> notification) async {
    final user = _auth.currentUser;
    if (user != null) {
      final notificationWithUserId = {
        ...notification,
        'userId': user.uid,
      };
      await _firestore.collection('notifications').add(notificationWithUserId);
    } else {
      print('User not authenticated');
      throw Exception('User not authenticated');
    }
  }
}
