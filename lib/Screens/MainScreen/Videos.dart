import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Service/TagProvider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class CursosScreen extends StatelessWidget {
  final List<Curso> cursos = [
    Curso(
        titulo: 'Curso de Flutter',
        tag: 'flutter',
        link: 'https://link-para-curso-flutter.com'),
    Curso(
        titulo: 'Curso de Dart',
        tag: 'dart',
        link: 'https://link-para-curso-dart.com'),
    Curso(
        titulo: 'Curso de Firebase',
        tag: 'firebase',
        link: 'https://link-para-curso-firebase.com'),
    // Adicione mais cursos conforme necessário
  ];

  @override
  Widget build(BuildContext context) {
    final tagProvider = Provider.of<TagProvider>(context);
    final selectedTags = tagProvider.selectedTags;

    final filteredCursos =
        cursos.where((curso) => selectedTags.contains(curso.tag)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Vídeos dos Cursos',
            style: TextStyle(
              color: TColors.textWhite,
            )),
        backgroundColor: TColors.secondaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          filteredCursos.isEmpty
              ? Center(child: Text('Selecione as tags referente ao seu curso.'))
              : ListView.builder(
                  itemCount: filteredCursos.length,
                  itemBuilder: (context, index) {
                    final curso = filteredCursos[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(curso.titulo),
                        subtitle: Text('Tag: ${curso.tag}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () => _abrirLinkCurso(curso.link),
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, PageRoutes.principal);
              },
              child: Icon(Icons.home , color: Colors.white,),
              backgroundColor: TColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _abrirLinkCurso(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }
}

class Curso {
  final String titulo;
  final String tag;
  final String link;

  Curso({
    required this.titulo,
    required this.tag,
    required this.link,
  });
}
