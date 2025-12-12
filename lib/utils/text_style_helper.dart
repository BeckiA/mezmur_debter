import 'package:flutter/material.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:provider/provider.dart';

extension TextStyleExtension on TextStyle {
  TextStyle withAppFont(BuildContext context, {bool isBold = false}) {
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context, listen: false);
    String fontFamily = fontFamilyProvider.fontFamily;
    
    // For bold text, we'll use fontWeight instead of font family suffix
    // since different fonts handle bold differently
    if (isBold) {
      return copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
      );
    }
    
    return copyWith(fontFamily: fontFamily);
  }
}

// Helper function to get text style with app font
TextStyle getAppTextStyle(
  BuildContext context, {
  TextStyle? baseStyle,
  bool isBold = false,
  double? fontSize,
  Color? color,
}) {
  final fontFamilyProvider = Provider.of<FontFamilyProvider>(context, listen: false);
  String fontFamily = fontFamilyProvider.fontFamily;
  
  return (baseStyle ?? const TextStyle()).copyWith(
    fontFamily: fontFamily,
    fontWeight: isBold ? FontWeight.bold : null,
    fontSize: fontSize,
    color: color,
  );
}

