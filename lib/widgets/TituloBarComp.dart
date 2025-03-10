import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

///UTILIZADOS EM LOGIN E CADASTRO
class TituloPadrao extends StatelessWidget {
  final String titulo;
  final double distanciaDoTopo;
  //final String logoPath;

  const TituloPadrao({
    Key? key,
    required this.titulo,
    this.distanciaDoTopo = 0.0,
    //this.logoPath = 'assets/logo/medicine-logo.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: distanciaDoTopo),
      child: Column(
        children: [
          // Image.asset(
          //   logoPath, // Caminho da logo
          //   height: 60.0,
          //   width: 60.0,
          // ),
          SizedBox(height: 20.0), // Espaço entre a logo e o título
          Container(
            margin: EdgeInsets.zero,
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            color: TColors.primaryColor,
            child: Text(
              titulo,
              style: TextStyle(
                color: Colors.white,
                fontSize: 44.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40.0), // Espaço de 10.0 abaixo do componente
        ],
      ),
    );
  }
}
