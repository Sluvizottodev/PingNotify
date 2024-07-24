import 'package:flutter/material.dart';
import 'package:nfty/Screens/HomeScreen/Cadastro.dart';
import 'package:nfty/Screens/HomeScreen/Login.dart';
import 'package:nfty/Screens/MainScreen/Principal.dart';

class PageRoutes {
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String principal = '/principal';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case cadastro:
        return MaterialPageRoute(builder: (_) => CadastroScreen());
      case principal:
        return MaterialPageRoute(builder: (_) => PrincipalScreen());
      default:
        return MaterialPageRoute(builder: (_) => ErrorScreen());
    }
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Página não encontrada!'),
      ),
    );
  }
}
