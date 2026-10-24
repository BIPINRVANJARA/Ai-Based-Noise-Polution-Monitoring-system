import 'package:flutter/material.dart';
import 'package:noiseguard/core/theme/app_colors.dart';
import 'package:noiseguard/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.headlineMedium(AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTypography.bodyMedium(AppColors.textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(AppColors.textPrimary),
        displayMedium: AppTypography.displayMedium(AppColors.textPrimary),
        headlineLarge: AppTypography.headlineLarge(AppColors.textPrimary),
        headlineMedium: AppTypography.headlineMedium(AppColors.textPrimary),
        titleLarge: AppTypography.titleLarge(AppColors.textPrimary),
        titleMedium: AppTypography.titleMedium(AppColors.textPrimary),
        bodyLarge: AppTypography.bodyLarge(AppColors.textPrimary),
        bodyMedium: AppTypography.bodyMedium(AppColors.textPrimary),
        bodySmall: AppTypography.bodySmall(AppColors.textSecondary),
        labelLarge: AppTypography.labelLarge(AppColors.textPrimary),
        labelMedium: AppTypography.labelMedium(AppColors.textPrimary),
        labelSmall: AppTypography.labelSmall(AppColors.textSecondary),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
