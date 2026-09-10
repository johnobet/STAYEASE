import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboards/dashboard_screens.dart';
import '../dashboards/owner/owner_dashboard_screen.dart';
import '../dashboards/tenant/tenant_home_screen.dart';

/// Single source of truth for "what should the person see right now."
///
/// Two nested streams:
/// 1. FirebaseAuth authStateChanges — are they logged in at all.
/// 2. Firestore watchUserProfile(uid) — what's their role, so a promoted/
///    demoted role reflects without forcing a logout.
///
/// This is the whole answer to spec item 28, "Role-based navigation."
class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb.User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoading();
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return StreamBuilder<UserModel?>(
          stream: _authService.watchUserProfile(firebaseUser.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoading();
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              // Auth account exists but no Firestore profile — either the
              // register write failed after account creation, or the
              // document was removed. Don't guess a role; let them retry.
              return _ProfileMissing(onSignOut: _authService.signOut);
            }

            switch (profile.role) {
              case UserRole.tenant:
                return TenantHomeScreen(user: profile);
              case UserRole.owner:
                return OwnerDashboardScreen(user: profile);
              case UserRole.admin:
                return AdminDashboardScreen(user: profile);
            }
          },
        );
      },
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy800,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('StayEase', style: AppTypography.displayL.copyWith(color: AppColors.textOnDark)),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMissing extends StatelessWidget {
  const _ProfileMissing({required this.onSignOut});
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('We couldn\'t load your profile', style: AppTypography.headingM, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Please sign in again.',
                style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Sign out', onPressed: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}
