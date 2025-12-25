import 'package:flutter/material.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

extension TextStyleExtension on TextStyle {
  TextStyle withAppFont(BuildContext context, {bool isBold = false, bool useAppFontSize = false}) {
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context, listen: false);
    String fontFamily = fontFamilyProvider.fontFamily;
    
    double? fontSizeToUse = fontSize;
    if (useAppFontSize) {
      final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
      fontSizeToUse = fontSizeProvider.fontSizeValue;
    }
    
    // For bold text, we'll use fontWeight instead of font family suffix
    // since different fonts handle bold differently
    if (isBold) {
      return copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: fontSizeToUse,
      );
    }
    
    return copyWith(
      fontFamily: fontFamily,
      fontSize: fontSizeToUse,
    );
  }
}

// Helper function to get text style with app font
TextStyle getAppTextStyle(
  BuildContext context, {
  TextStyle? baseStyle,
  bool isBold = false,
  double? fontSize,
  Color? color,
  bool useAppFontSize = false,
}) {
  final fontFamilyProvider = Provider.of<FontFamilyProvider>(context, listen: false);
  String fontFamily = fontFamilyProvider.fontFamily;
  
  double? fontSizeToUse = fontSize;
  if (useAppFontSize) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
    fontSizeToUse = fontSizeProvider.fontSizeValue;
  }
  
  return (baseStyle ?? const TextStyle()).copyWith(
    fontFamily: fontFamily,
    fontWeight: isBold ? FontWeight.bold : null,
    fontSize: fontSizeToUse,
    color: color,
  );
}

