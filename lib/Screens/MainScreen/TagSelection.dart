import 'package:flutter/material.dart';
import '../../Service/ntfyService.dart';
import '../../utils/constants/colors.dart';

class TagSelectionScreen extends StatefulWidget {
  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  final NtfyService _ntfyService = NtfyService();
  List<String> _tags = [];
  Set<String> _selectedTags = Set<String>();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    try {
      final tags = await _ntfyService.fetchTags();
      setState(() {
        _tags = tags;
      });
    } catch (e) {
      print('Erro ao buscar tags: $e');
    }
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de Tags', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        automaticallyImplyLeading: false, // Remove a seta de retorno
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Digite uma tag',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final tag = _tagController.text.trim();
                    if (tag.isNotEmpty) {
                      _addTag(tag);
                      _tagController.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_tags[index]),
                  value: _selectedTags.contains(_tags[index]),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedTags.add(_tags[index]);
                      } else {
                        _selectedTags.remove(_tags[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAndReturn,
        child: Icon(Icons.check),
        backgroundColor: TColors.primaryColor,
      ),
    );
  }

  void _saveAndReturn() async {
    for (var tag in _selectedTags) {
      await _ntfyService.subscribeToTag(tag);
    }
    Navigator.pop(context, _selectedTags.toList()); // Retorna para a tela principal com as tags selecionadas
  }
}
