import 'package:flutter/material.dart';
import 'package:nfty/Screens/HomeScreen/Cadastro.dart';
import 'package:nfty/Screens/HomeScreen/Login.dart';
import 'package:nfty/Screens/MainScreen/Principal.dart';
import 'package:nfty/Screens/MainScreen/Videos.dart';

import '../../Screens/MainScreen/MessageDetail.dart';
import '../../Screens/MainScreen/TagSelection.dart';
import 'colors.dart'; // Atualize o caminho conforme necessário

class PageRoutes {
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String principal = '/principal';
  static const String tagSelection = '/tag-selection'; // Adicione a nova rota
  static const String messageDetail = '/message-detail'; // Adicione a nova rota
  static const String cursos = '/cursos';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case cadastro:
        return MaterialPageRoute(builder: (_) => CadastroScreen());
      case principal:
        return MaterialPageRoute(builder: (_) => PrincipalScreen());
      case cursos:
        return MaterialPageRoute(builder: (_) => CursosScreen());
      case tagSelection:
        return MaterialPageRoute(builder: (_) => TagSelectionScreen());
      case messageDetail:
        final notification = settings.arguments as Map<String, dynamic>? ?? {}; // Obtenha argumentos se houver
        return MaterialPageRoute(
          builder: (_) => MessageDetailScreen(notification: notification),
        );
      default:
        return MaterialPageRoute(builder: (_) => ErrorScreen());
    }
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Erro'),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
      ),
      body: Center(
        child: Text('Página não encontrada!'),
      ),
    );
  }
}
