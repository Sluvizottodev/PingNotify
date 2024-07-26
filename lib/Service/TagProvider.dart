import 'package:flutter/material.dart';

class TagProvider with ChangeNotifier {
  Set<String> _selectedTags = Set<String>();

  Set<String> get selectedTags => _selectedTags;

  void addTag(String tag) {
    _selectedTags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _selectedTags.remove(tag);
    notifyListeners();
  }

  void setSelectedTags(Set<String> tags) {
    _selectedTags = tags;
    notifyListeners();
  }
}
