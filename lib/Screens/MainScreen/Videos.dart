import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Service/TagProvider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class CursosScreen extends StatefulWidget {
  @override
  _CursosScreenState createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  late Future<List<Curso>> _cursos;
  late Future<Map<String, String>> _tagLinks;

  @override
  void initState() {
    super.initState();
    _cursos = _fetchCursos();
    _tagLinks = _fetchTagLinks();
  }

  Future<List<Curso>> _fetchCursos() async {
    try {
      final cursosSnapshot = await FirebaseFirestore.instance.collection('cursos').get();
      return cursosSnapshot.docs.map((doc) {
        final data = doc.data();
        return Curso(
          titulo: data['titulo'] as String,
          tag: data['tag'] as String,
          link: data['link'] as String,
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar cursos: $e');
      return [];
    }
  }

  Future<Map<String, String>> _fetchTagLinks() async {
    try {
      final tagLinksSnapshot = await FirebaseFirestore.instance.collection('tagLinks').get();
      final tagLinksMap = <String, String>{};

      for (var doc in tagLinksSnapshot.docs) {
        final tag = doc['tag'] as String;
        final link = doc['link'] as String;
        tagLinksMap[tag] = link;
      }

      return tagLinksMap;
    } catch (e) {
      print('Erro ao buscar links de tags: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagProvider = Provider.of<TagProvider>(context);
    final selectedTags = tagProvider.selectedTags;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vídeos dos Cursos',
          style: TextStyle(
            color: TColors.textWhite,
          ),
        ),
        backgroundColor: TColors.secondaryColor,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Curso>>(
        future: _cursos,
        builder: (context, cursosSnapshot) {
          if (cursosSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (cursosSnapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados.'));
          }

          final cursos = cursosSnapshot.data ?? [];

          return FutureBuilder<Map<String, String>>(
            future: _tagLinks,
            builder: (context, tagLinksSnapshot) {
              if (tagLinksSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (tagLinksSnapshot.hasError) {
                return Center(child: Text('Erro ao carregar links de tags.'));
              }

              final tagLinks = tagLinksSnapshot.data ?? {};

              final filteredCursos = cursos
                  .where((curso) => selectedTags.contains(curso.tag))
                  .toList();

              return Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.03, vertical: mediaQuery.size.height * 0.02),
                    children: [
                      if (selectedTags.any((tag) => tagLinks.containsKey(tag)))
                        Card(
                          margin: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.02),
                          child: ListTile(
                            title: Text('Vídeo Especial'),
                            subtitle: Text('Clique para assistir um vídeo especial.'),
                            trailing: Icon(Icons.video_library),
                            onTap: () => _abrirLinkCurso(tagLinks[selectedTags.firstWhere((tag) => tagLinks.containsKey(tag))]!),
                          ),
                        ),
                      if (filteredCursos.isEmpty)
                        Center(child: Text('Selecione as tags referente ao seu curso.'))
                      else
                        Column(
                          children: filteredCursos.map((curso) {
                            return Card(
                              margin: EdgeInsets.all(mediaQuery.size.width * 0.03),
                              child: ListTile(
                                title: Text(curso.titulo),
                                subtitle: Text('Tag: ${curso.tag}'),
                                trailing: Icon(Icons.arrow_forward),
                                onTap: () => _abrirLinkCurso(curso.link),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                  Positioned(
                    bottom: mediaQuery.size.height * 0.02,
                    left: mediaQuery.size.width * 0.03,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, PageRoutes.principal);
                      },
                      child: Icon(Icons.home , color: Colors.white,),
                      backgroundColor: TColors.primaryColor,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _abrirLinkCurso(String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Não foi possível abrir o link $link';
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
