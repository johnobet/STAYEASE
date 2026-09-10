import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart'; // exports both AppSpacing and AppRadius
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.navy800,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.gold500,
        onSecondary: AppColors.navy900,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textOnDark,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTypography.displayXL,
        displayMedium: AppTypography.displayL,
        headlineLarge: AppTypography.headingL,
        headlineMedium: AppTypography.headingM,
        headlineSmall: AppTypography.headingS,
        bodyLarge: AppTypography.bodyL,
        bodyMedium: AppTypography.bodyM,
        bodySmall: AppTypography.bodyS,
        labelLarge: AppTypography.button,
        labelSmall: AppTypography.label,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.headingS,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkRipple.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.navy800, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        labelStyle: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.bodyM.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
