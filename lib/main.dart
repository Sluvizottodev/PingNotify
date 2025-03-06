import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'Service/WebSocketService.dart';
import 'utils/LocalNotification.dart';
import 'Service/DeviceIdService.dart';
import 'Service/NotificationFireSevice.dart';
import 'Service/TagProvider.dart';
import 'utils/constants/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    final urls = ["wss://example.com/websocket"];
    final webSocketService = WebSocketService(urls);

    LocalNotificationService notificationService = LocalNotificationService();
    await notificationService.initialize();

    webSocketService.messages.listen((message) {
      // Ignorar mensagens padrão de conexão, reconexão ou irrelevantes
      if (!message.contains('result: success, dartTask:') &&
          !message.contains('event: open') &&
          !message.contains('reconnecting') &&  // Filtro de mensagens de reconexão
          !message.contains('connection closed')) {  // Filtro de desconexões
        // Apenas mensagens relevantes geram notificação
        notificationService.showNotification(
          "Mensagem Recebida",
          message,
        );
      }
    });

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa o WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  String deviceId = await DeviceIdService.getDeviceId();
  print('ID do dispositivo: $deviceId'); // Para depuração, remova em produção

  // Inicializa o serviço de notificação
  NotificationService notificationService = NotificationService();
  await notificationService.initialize().catchError((error) {
    print('Erro ao inicializar o serviço de notificação: $error');
  });

  // Solicitar permissão para notificações
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permissão para notificações: ${settings.authorizationStatus}');

  // Agendar uma tarefa em segundo plano para reconectar ao WebSocket
  Workmanager().registerOneOffTask(
    "webSocketReconnectTask",
    "webSocketReconnect",
    initialDelay: Duration(minutes: 15),
    inputData: <String, dynamic>{
      "dataKey": "dataValue",
    },
  );

  runApp(MyApp(deviceId: deviceId));
}

class MyApp extends StatelessWidget {
  final String deviceId;

  MyApp({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagProvider(),
      child: MaterialApp(
        title: 'Ping Notify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: PageRoutes.principal,
        onGenerateRoute: PageRoutes.generateRoute,
      ),
    );
  }
}