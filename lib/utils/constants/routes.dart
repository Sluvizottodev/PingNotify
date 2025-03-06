import 'package:flutter/material.dart';

import '../../Views/AuthScreen/Cadastro.dart';
import '../../Views/AuthScreen/Login.dart';
import '../../Views/MainScreen/MessageDetail.dart';
import '../../Views/MainScreen/Principal.dart';
import '../../Views/MainScreen/TagSelection.dart';
import '../../Views/MainScreen/Videos.dart';

class PageRoutes {
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String principal = '/principal';
  static const String tagSelection = '/tag-selection'; // Adicione a nova rota
  static const String messageDetail = '/message-detail'; // Adicione a nova rota
  static const String cursos = '/cursos';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
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
        final notification = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MessageDetailScreen(notification: notification),
        );
      default:
        return null; // Retorna null se a rota não for encontrada
    }
  }
}
