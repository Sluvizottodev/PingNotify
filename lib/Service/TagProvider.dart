import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeviceIdService.dart'; // Importe o DeviceIdService

class TagProvider with ChangeNotifier {
  Set<String> _selectedTags = {};
  String _deviceId = '';

  Set<String> get selectedTags => _selectedTags;
  String get deviceId => _deviceId;

  TagProvider() {
    _loadSelectedTags();
    _initializeDeviceId();
  }

  void setSelectedTags(Set<String> tags) {
    _selectedTags = tags;
    _saveSelectedTags();
    notifyListeners();
  }

  Future<void> _saveSelectedTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_tags', _selectedTags.toList());
  }

  Future<void> _loadSelectedTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tags = prefs.getStringList('selected_tags') ?? [];
    _selectedTags = tags.toSet();
    notifyListeners();
  }

  Future<void> _initializeDeviceId() async {
    _deviceId = await DeviceIdService.getDeviceId();
    notifyListeners();
  }
}
