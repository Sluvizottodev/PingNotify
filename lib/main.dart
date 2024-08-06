import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Service/DeviceIdService.dart';
import 'Service/TagProvider.dart';
import 'utils/constants/routes.dart';

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
    return ChangeNotifierProvider(
      create: (_) => TagProvider(),
      child: MaterialApp(
        title: 'Nfty App',
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
