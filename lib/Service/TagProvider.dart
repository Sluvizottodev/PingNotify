import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeviceIdService.dart'; // Importe o DeviceIdService

class TagProvider with ChangeNotifier {
  Set<String> _selectedTags = {}; // Conjunto de tags selecionadas
  String _deviceId = ''; // ID do dispositivo

  Set<String> get selectedTags => _selectedTags; // Getter para as tags selecionadas
  String get deviceId => _deviceId; // Getter para o ID do dispositivo

  TagProvider() {
    _loadSelectedTags(); // Carrega as tags salvas nas preferências
    _initializeDeviceId(); // Inicializa o ID do dispositivo
  }

  // Atualiza as tags selecionadas e notifica os ouvintes
  void setSelectedTags(Set<String> tags) {
    _selectedTags = tags;
    _saveSelectedTags(); // Salva as tags nas preferências
    notifyListeners();
  }

  // Salva as tags selecionadas usando SharedPreferences
  Future<void> _saveSelectedTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_tags', _selectedTags.toList());
  }

  // Carrega as tags selecionadas do SharedPreferences
  Future<void> _loadSelectedTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tags = prefs.getStringList('selected_tags') ?? [];
    _selectedTags = tags.toSet();
    notifyListeners();
  }

  // Inicializa o ID do dispositivo usando o DeviceIdService
  Future<void> _initializeDeviceId() async {
    _deviceId = await DeviceIdService.getDeviceId();
    notifyListeners();
  }
}
