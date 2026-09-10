import 'package:flutter/material.dart';

/// StayEase color tokens.
///
/// Two palettes coexist deliberately:
/// - Navy/Gold — used by auth screens (login/register) and placeholder
///   dashboards, from the original brand pass.
/// - Sage/Terracotta — used by the Tenant Dashboard feature, matching
///   the approved reference design (warm, organic, editorial-travel feel
///   vs. the navy set's fintech-trust feel). Both read as "premium
///   StayEase," applied to different contexts.
class AppColors {
  AppColors._();

  // Brand — Navy (auth screens, placeholder dashboards)
  static const Color navy900 = Color(0xFF0B1729);
  static const Color navy800 = Color(0xFF10233F);
  static const Color navy700 = Color(0xFF1B3358);
  static const Color navy500 = Color(0xFF35507D);
  static const Color navy100 = Color(0xFFE8ECF3);

  // Brand — Gold (auth screens accent)
  static const Color gold600 = Color(0xFFC98423);
  static const Color gold500 = Color(0xFFE3A438);
  static const Color gold200 = Color(0xFFF3D9A6);
  static const Color gold100 = Color(0xFFFBEDD3);

  // Brand — Sage (Tenant Dashboard primary)
  static const Color sage900 = Color(0xFF16261E); // near-black text
  static const Color sage800 = Color(0xFF1F3A2E); // primary — buttons, nav, badges
  static const Color sage600 = Color(0xFF3B5D48);
  static const Color sage300 = Color(0xFF9CB5A4);
  static const Color sage200 = Color(0xFFDCE5DC); // tinted card backgrounds
  static const Color sage100 = Color(0xFFEDF1EA);

  // Brand — Terracotta (Tenant Dashboard signal color: price, urgency)
  static const Color terracotta700 = Color(0xFFB8501F);
  static const Color terracotta600 = Color(0xFFD9622B); // price, "due in" text
  static const Color terracottaBg = Color(0xFFFBE7DA);

  // Surfaces
  static const Color background = Color(0xFFF7F5F1); // warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSunken = Color(0xFFF1EEE7);
  static const Color borderSubtle = Color(0xFFE7E2D8);
  static const Color borderStrong = Color(0xFFD5CFC0);

  // Text
  static const Color textPrimary = Color(0xFF10192B);
  static const Color textSecondary = Color(0xFF5B6472);
  static const Color textTertiary = Color(0xFF8B93A1);
  static const Color textOnDark = Color(0xFFF7F5F1);
  static const Color textOnDarkMuted = Color(0xFFAEB8C9);

  // Semantic states
  static const Color success = Color(0xFF2F9E68);
  static const Color successBg = Color(0xFFE4F3EA);
  static const Color warning = Color(0xFFB76E1B);
  static const Color warningBg = Color(0xFFF6EADB);
  static const Color danger = Color(0xFFD64550);
  static const Color dangerBg = Color(0xFFFBEAEC);
  static const Color info = navy700;
  static const Color infoBg = navy100;

  // Connectivity signal (offline-first motif)
  static const Color signalOnline = success;
  static const Color signalCached = gold500;
  static const Color signalOffline = Color(0xFF9AA2AF);
}
