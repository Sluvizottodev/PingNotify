import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  final WebSocketChannel channel;
  final Function onMessage;

  WebSocketService(String url, this.onMessage)
      : channel = WebSocketChannel.connect(Uri.parse(url));

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void listen() {
    channel.stream.listen((message) {
      onMessage(jsonDecode(message));
    });
  }

  void dispose() {
    channel.sink.close();
  }
}
