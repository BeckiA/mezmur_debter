import 'package:flutter/material.dart';
import 'package:hymn_app/constants/app_colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  dividerColor: AppColors.border,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.card,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.textLight),
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
  ),
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all(AppColors.switchTrack),
    thumbColor: MaterialStateProperty.all(AppColors.switchThumb),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  dividerColor: AppColors.darkBorder,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCard,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkText),
    bodyMedium: TextStyle(color: AppColors.darkTextLight),
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    error: AppColors.darkError,
  ),
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all(AppColors.darkSwitchTrack),
    thumbColor: MaterialStateProperty.all(AppColors.darkSwitchThumb),
  ),
);
