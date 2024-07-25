import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Service/DeviceIdService.dart';
import 'utils/constants/routes.dart'; // Certifique-se de que isso está correto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String deviceId = await DeviceIdService.getDeviceId();
  print('ID do dispositivo: $deviceId'); // Para depuração, remova em produção

  runApp(MyApp(deviceId: deviceId));
}

class MyApp extends StatelessWidget {
  final String deviceId;

  MyApp({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nfty App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: PageRoutes.principal, // A tela login e cadastro não estão em uso
      onGenerateRoute: PageRoutes.generateRoute, // Use o método de geração de rotas
    );
  }
}

//XSoftware
//X123456