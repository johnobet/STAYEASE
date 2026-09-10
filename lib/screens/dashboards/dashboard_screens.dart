import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

/// Shared shell for the three placeholder dashboards below. Each one gets
/// replaced by its real feature build in later phases (Tenant Discovery,
/// Owner Dashboard, Admin Dashboard).
class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold({required this.title, required this.user});

  final String title;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name.split(' ').first}', style: AppTypography.headingL),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Signed in as ${user.email} · ${user.role.value}',
              style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            AppButton(
              label: 'Sign out',
              variant: AppButtonVariant.secondary,
              onPressed: () => AuthService().signOut(),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) =>
      _DashboardScaffold(title: 'Admin Dashboard', user: user);
}
