import 'dart:async';
import 'dart:convert';
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
    for (String url in urls) {
      _connect(url);
    }
  }

  void _connect(String url) {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    _channels.add(channel);

    channel.stream.listen(
          (message) {
        _reconnectAttempts = 0; // Reset de tentativas na primeira mensagem
        _messageStreamController.add(message);
      },
      onError: (error) {
        print('Erro na conexão do WebSocket ($url): $error');
        _reconnectWithBackoff(url);
      },
      onDone: () {
        print('Conexão fechada ($url)');
        _reconnectWithBackoff(url);
      },
    );
  }

  void _reconnectWithBackoff(String url) {
    final backoffTime = _calculateBackoffTime();
    _reconnectAttempts += 1;
    print('Tentando reconectar em $backoffTime segundos...');

    Future.delayed(Duration(seconds: backoffTime), () => _connect(url));
  }

  int _calculateBackoffTime() {
    return (_reconnectAttempts > 5) ? 60 : (2 ^ _reconnectAttempts) - 1;
  }

  void dispose() {
    for (final channel in _channels) {
      channel.sink.close();
    }
    _messageStreamController.close();
  }
}
