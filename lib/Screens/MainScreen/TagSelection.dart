import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Service/TagProvider.dart';
import '../../Service/ntfyService.dart';
import '../../utils/constants/colors.dart';

class TagSelectionScreen extends StatefulWidget {
  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  final NtfyService _ntfyService = NtfyService();
  List<String> _availableTags = []; // Tags disponíveis para seleção
  Set<String> _selectedTags = {}; // Tags selecionadas pelo usuário
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableTags();
    _loadSelectedTags();
  }

  Future<void> _fetchAvailableTags() async {
    try {
      // Exemplo de como passar um tópico, ajuste conforme necessário
      final tags = await _ntfyService.fetchTags('Info_alertas_nfty');
      setState(() {
        _availableTags = tags;
      });
    } catch (e) {
      print('Erro ao buscar tags: $e');
    }
  }

  void _loadSelectedTags() {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    setState(() {
      _selectedTags = tagProvider.selectedTags.toSet();
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _saveAndReturn() async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    // Atualize o `TagProvider` com as tags selecionadas
    tagProvider.setSelectedTags(_selectedTags);

    // Inscreva-se nas tags selecionadas
    try {
      await _ntfyService.subscribeToTags(_selectedTags.toList());
      Navigator.pop(context, _selectedTags.toList()); // Retorna para a tela principal com as tags selecionadas
    } catch (e) {
      print('Erro ao inscrever-se nas tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de Tags', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.secondaryColor,
        elevation: 4,
        automaticallyImplyLeading: false, // Remove a seta de voltar
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
              itemCount: _availableTags.length,
              itemBuilder: (context, index) {
                final tag = _availableTags[index];
                return ListTile(
                  title: Text(tag),
                  trailing: Checkbox(
                    value: _selectedTags.contains(tag),
                    onChanged: (bool? selected) {
                      if (selected == true) {
                        _addTag(tag);
                      } else {
                        _removeTag(tag);
                      }
                    },
                  ),
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
}
