import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// StayEase type system.
///
/// Three roles, deliberately not one family doing everything:
/// - Display (Poppins): headings, hero copy — warm, confident geometric
///   sans that reads premium without feeling cold.
/// - Body (Inter): everything read at length — descriptions, labels, forms.
/// - Data (JetBrains Mono): reference numbers, match %, distances —
///   reinforces "this number is precise and verifiable."
class AppTypography {
  AppTypography._();

  static TextStyle get _displayBase => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        height: 1.15,
      );

  static TextStyle get _bodyBase => GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get _monoBase => GoogleFonts.jetBrainsMono(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  // Display — hero moments only, used sparingly
  static TextStyle get displayXL => _displayBase.copyWith(fontSize: 34, letterSpacing: -0.4, fontWeight: FontWeight.w700);
  static TextStyle get displayL => _displayBase.copyWith(fontSize: 28, letterSpacing: -0.3, fontWeight: FontWeight.w700);

  // Headings
  static TextStyle get headingL => _displayBase.copyWith(fontSize: 22, letterSpacing: -0.2);
  static TextStyle get headingM => _displayBase.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get headingS => _displayBase.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  // Body
  static TextStyle get bodyL => _bodyBase.copyWith(fontSize: 16);
  static TextStyle get bodyM => _bodyBase.copyWith(fontSize: 14);
  static TextStyle get bodyS => _bodyBase.copyWith(fontSize: 13, color: AppColors.textSecondary);

  // Labels / eyebrows — small caps-style uppercase tags
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
      );

  // Data / mono — match %, reference numbers, distances
  static TextStyle get mono => _monoBase.copyWith(fontSize: 13);
  static TextStyle get monoL => _monoBase.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  // Button label
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
}
