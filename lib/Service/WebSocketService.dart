import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel _channel;
  final StreamController<String> _messageController = StreamController<String>();

  WebSocketService(String url) : _channel = WebSocketChannel.connect(Uri.parse(url)) {
    _channel.stream.listen((message) {
      _messageController.add(message);
    }, onError: (error) {
      print('Erro no WebSocket: $error');
    });
  }

  Stream<String> get messages => _messageController.stream;

  void dispose() {
    _channel.sink.close();
    _messageController.close();
  }
}
