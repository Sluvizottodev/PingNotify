import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../Service/NtfyService.dart'; // Importar o serviço Ntfy
import '../../utils/constants/colors.dart';
import '../../utils/constants/routes.dart';

class TagSelectionScreen extends StatefulWidget {
  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  List<String> _allTags = [];
  Set<String> _selectedTags = {};
  TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _initializeSelectedTags();
  }

  Future<void> _fetchTags() async {
    try {
      final tagsSnapshot = await FirebaseFirestore.instance.collection('tags').get();
      final tags = tagsSnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _allTags = tags;
      });
    } catch (e) {
      print('Erro ao buscar tags: $e');
    }
  }

  void _initializeSelectedTags() {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    setState(() {
      _selectedTags = tagProvider.selectedTags;
    });
  }

  void _toggleTagSelection(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _saveSelectedTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      tagProvider.setSelectedTags(_selectedTags);

      // Salvar tags selecionadas no Firestore
      await FirebaseFirestore.instance.collection('users').doc(tagProvider.deviceId).set({
        'tags': _selectedTags.toList(),
      });

      // Obter e enviar notificações
      await _handleNotifications();

      // Substituir a tela atual pela tela principal
      Navigator.pushReplacementNamed(context, PageRoutes.principal);
    } catch (e) {
      print('Erro ao salvar tags selecionadas: $e');
    }
  }

  void _addNewTag() {
    final newTag = _newTagController.text.trim();
    if (newTag.isNotEmpty && !_allTags.contains(newTag)) {
      setState(() {
        _allTags.add(newTag);
        _selectedTags.add(newTag);
      });
      _newTagController.clear();
    }
  }

  Future<void> _handleNotifications() async {
    final ntfyService = NtfyService();
    final threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));

    for (final tag in _selectedTags) {
      // Enviar notificação para a nova tag
      await ntfyService.sendNotification(tag, 'Nova Tag Selecionada', 'Você selecionou a tag $tag');

      // Recuperar notificações passadas relacionadas à tag
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('tag', isEqualTo: tag)
          .where('timestamp', isGreaterThanOrEqualTo: threeMonthsAgo)
          .get();

      for (final doc in notificationsSnapshot.docs) {
        final notification = doc.data();
        final title = notification['title'];
        final message = notification['message'];

        // Enviar notificação para o usuário sobre notificações passadas
        await ntfyService.sendNotification(tag, title, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de Tags', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
      ),
      body: Container(
        color: TColors.backgroundLight,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecione suas tags de interesse:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newTagController,
              decoration: InputDecoration(
                labelText: 'Adicionar nova tag',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNewTag,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _allTags.length,
                itemBuilder: (context, index) {
                  final tag = _allTags[index];
                  return CheckboxListTile(
                    title: Text(tag, style: TextStyle(color: TColors.textPrimary)),
                    value: _selectedTags.contains(tag),
                    onChanged: (bool? value) {
                      _toggleTagSelection(tag);
                    },
                    activeColor: TColors.primaryColor,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveSelectedTags,
              child: Text('Salvar Tags'),
              style: ElevatedButton.styleFrom(
                foregroundColor: TColors.textWhite,
                backgroundColor: TColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
