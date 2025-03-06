import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

///UTILIZADOS EM LOGIN E CADASTRO
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;

  CustomAppBar({required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.only(left: 0.0, right: 10.0), // Ajuste de margem esquerda e direita da logo
          //   child: Image.asset(
          //     'assets/logo/logo-white.png', // Substitua pelo caminho da sua logo
          //     height: 30, // Altura desejada da logo
          //   ),
          // ),
          Text(
            pageTitle,
            style: TextStyle(
              color: Colors.white, // Cor do texto do título
            ),
          ),
        ],
      ),
      centerTitle: true, // Centraliza o título
      backgroundColor: TColors.primaryColor, // Cor de fundo da AppBar
      automaticallyImplyLeading: false, // Remove a seta de retorno
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Altura padrão da AppBar
}
