import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final List<WebSocketChannel> _channels = [];
  final StreamController<String> _messageController = StreamController<String>();

  WebSocketService(List<String> urls) {
    for (final url in urls) {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels.add(channel);

      channel.stream.listen((message) {
        _messageController.add(message);
      }, onError: (error) {
        print('Erro no WebSocket: $error');
      });
    }
  }

  Stream<String> get messages => _messageController.stream;

  void dispose() {
    for (final channel in _channels) {
      channel.sink.close();
    }
    _messageController.close();
  }
}
