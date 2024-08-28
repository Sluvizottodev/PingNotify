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
        _reconnect(channel, url);
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

  void _reconnect(WebSocketChannel channel, String url) async {
    await Future.delayed(Duration(seconds: 5)); // Aguardar antes de tentar reconectar
    _channels.remove(channel);
    final newChannel = WebSocketChannel.connect(Uri.parse(url));
    _channels.add(newChannel);
    newChannel.stream.listen((message) {
      _messageController.add(message);
    }, onError: (error) {
      print('Erro na reconexão do WebSocket: $error');
      _reconnect(newChannel, url);
    });
  }
}
