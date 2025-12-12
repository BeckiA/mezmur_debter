import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontFamilyProvider extends ChangeNotifier {
  String _fontFamily = 'Nyala';

  String get fontFamily => _fontFamily;

  // Get display name for font family
  String getFontDisplayName(String fontFamily) {
    return _fontDisplayNames[fontFamily] ?? fontFamily;
  }

  // Available fonts with their display names
  static const Map<String, String> _fontDisplayNames = {
    'Nyala': 'Nyala',
    'Entoto': 'Entoto',
    'NotoSansEthiopic': 'Noto Sans',
    'NotoSerifEthiopic': 'Noto Serif',
    'Shiromeda': 'Shiromeda',
    'ShiromedaSerif': 'Shiromeda Serif',
    'MulatAbay': 'Mulat Abay',
    'MulatAddis': 'Mulat Addis',
    'MulatAhmed': 'Mulat Ahmed',
    'MulatAwash': 'Mulat Awash',
    'Niyala': 'Niyala',
    'Tera': 'Tera',
    'Washera': 'Washera',
    'Yebs': 'Yebs',
    'Zelan': 'Zelan',
    'Adwa': 'Adwa',
    'AdwaSansSerif': 'Adwa Sans Serif',
    'Abinet': 'Abinet',
    'ADDIS': 'ADDIS',
    'Arada': 'Arada',
    'DESTA': 'DESTA',
    'Fantuwa': 'Fantuwa',
    'Neteru': 'Neteru',
  };

  static List<String> get availableFonts => _fontDisplayNames.keys.toList();

  FontFamilyProvider() {
    _loadFontFamily();
  }

  void setFontFamily(String fontFamily) async {
    if (fontFamily != _fontFamily && _fontDisplayNames.containsKey(fontFamily)) {
      _fontFamily = fontFamily;
      notifyListeners();
      _saveFontFamily();
    }
  }

  void _saveFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fontFamily', _fontFamily);
  }

  void _loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedFontFamily = prefs.getString('fontFamily');
    if (savedFontFamily != null && _fontDisplayNames.containsKey(savedFontFamily)) {
      _fontFamily = savedFontFamily;
      notifyListeners();
    }
  }
}

