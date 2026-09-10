import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadows are tinted with navy rather than pure black — on the warm
/// off-white background, black shadows read muddy; a navy tint keeps
/// elevated cards feeling clean.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.navy900.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.navy900.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get raised => [
        BoxShadow(
          color: AppColors.navy900.withOpacity(0.14),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get none => const [];
}
