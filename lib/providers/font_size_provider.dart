import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  String _fontSize = 'medium';
  bool _isInitialized = false;

  String get fontSize => _fontSize;
  bool get isInitialized => _isInitialized;

  // Map font size preference to actual font size values
  double get fontSizeValue {
    switch (_fontSize) {
      case 'small':
        return 18.0;
      case 'medium':
        return 24.0;
      case 'large':
        return 30.0;
      default:
        return 24.0;
    }
  }

  FontSizeProvider() {
    // Start initialization in background
    _initialize();
  }

  /// Initialize the provider by loading preferences
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadFontSize();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    await _loadFontSize();
    _isInitialized = true;
    notifyListeners();
  }

  void setFontSize(String size) async {
    if (size != _fontSize && ['small', 'medium', 'large'].contains(size)) {
      _fontSize = size;
      notifyListeners();
      await _saveFontSize();
    }
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', _fontSize);
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedFontSize = prefs.getString('fontSize');
    if (savedFontSize != null && ['small', 'medium', 'large'].contains(savedFontSize)) {
      _fontSize = savedFontSize;
    }
  }
}

