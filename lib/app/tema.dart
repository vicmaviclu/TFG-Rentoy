import 'package:flutter/material.dart';
import '../core/constantes/colores.dart';
import '../core/constantes/textos.dart';

class TemaApp {
  static final ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, surface: AppColors.background, brightness: Brightness.dark),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    // Reuse AppTextStyles so typography is consistent across the app
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading,
      titleLarge: AppTextStyles.subheading,
      bodyLarge: AppTextStyles.body,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0x22000000)),
      ),
    ),
  );
}
