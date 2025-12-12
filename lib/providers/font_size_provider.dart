import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  String _fontSize = 'medium';

  String get fontSize => _fontSize;

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
    _loadFontSize();
  }

  void setFontSize(String size) async {
    if (size != _fontSize && ['small', 'medium', 'large'].contains(size)) {
      _fontSize = size;
      notifyListeners();
      _saveFontSize();
    }
  }

  void _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fontSize', _fontSize);
  }

  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedFontSize = prefs.getString('fontSize');
    if (savedFontSize != null && ['small', 'medium', 'large'].contains(savedFontSize)) {
      _fontSize = savedFontSize;
      notifyListeners();
    }
  }
}

