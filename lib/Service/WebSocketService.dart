import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final List<String> urls;
  late final List<WebSocketChannel> _channels = [];
  late StreamController<String> _messageStreamController;
  int _reconnectAttempts = 0;

  WebSocketService(this.urls) {
    _messageStreamController = StreamController<String>.broadcast();
    _initializeChannels();
  }

  Stream<String> get messages => _messageStreamController.stream;

  void _initializeChannels() {
    for (final url in urls) {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels.add(channel);
      channel.stream.listen((message) {
        _messageStreamController.add(message);
      }, onDone: () {
        _attemptReconnect(url);
      }, onError: (error) {
        print('Erro no canal WebSocket: $error');
      });
    }
  }

  void _attemptReconnect(String url) {
    if (_reconnectAttempts < 5) {
      _reconnectAttempts++;
      Future.delayed(Duration(seconds: 2), () {
        print('Reconectando ao WebSocket: $url');
        final channel = WebSocketChannel.connect(Uri.parse(url));
        _channels.add(channel);
        channel.stream.listen((message) {
          _messageStreamController.add(message);
        });
      });
    } else {
      print('Número máximo de tentativas de reconexão atingido para: $url');
    }
  }

  void dispose() {
    _messageStreamController.close();
    for (final channel in _channels) {
      channel.sink.close();
    }
  }
}
