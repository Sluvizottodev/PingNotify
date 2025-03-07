import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../Service/ntfy/ntfyService.dart';
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
  final NtfyService _ntfyService = NtfyService();

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
      print('Tags encontradas: $tags');
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

  void _toggleTagSelection(String tag) async {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
        _ntfyService.unsubscribeFromTag(tag);
      } else {
        _selectedTags.add(tag);
        _ntfyService.subscribeToTag(tag);
      }
    });
  }

  Future<void> _saveSelectedTags() async {
    try {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      tagProvider.setSelectedTags(_selectedTags);

      await FirebaseFirestore.instance.collection('users').doc(tagProvider.deviceId).set({
        'tags': _selectedTags.toList(),
      });

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

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      _ntfyService.unsubscribeFromTag(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de Tags', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        automaticallyImplyLeading: false,
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
            Text(
              'Tags selecionadas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: TColors.primaryColor.withOpacity(0.2),
                  deleteIconColor: TColors.primaryColor,
                );
              }).toList(),
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
