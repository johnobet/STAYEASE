import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserRole _role = UserRole.tenant;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in every field.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords don\'t match.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.registerWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _role,
      );
      // AuthGate listens to authStateChanges and will route automatically —
      // no manual navigation needed here.
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() => _error = null);
    setState(() => _googleLoading = true);
    try {
      await _authService.signInWithGoogle();
      // Returns null if the person cancelled the picker — nothing to do.
      // New accounts default to UserRole.tenant; AuthGate routes
      // automatically once the profile exists.
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xxl, AppSpacing.l, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your account', style: AppTypography.displayL),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Find your next stay, or list your property.',
                style: AppTypography.bodyL.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              _RoleToggle(role: _role, onChanged: (r) => setState(() => _role = r)),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(label: 'FULL NAME', hint: 'Juan Dela Cruz', controller: _nameController),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'EMAIL',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'PHONE',
                hint: '09XX XXX XXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.call_outlined,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'PASSWORD',
                hint: 'At least 6 characters',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'CONFIRM PASSWORD',
                controller: _confirmController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.l),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(_error!, style: AppTypography.bodyS.copyWith(color: AppColors.danger)),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Create account',
                onPressed: _loading || _googleLoading ? null : _submit,
                loading: _loading,
                fullWidth: true,
              ),

              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.borderSubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                    child: Text('or', style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider(color: AppColors.borderSubtle)),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              AppButton(
                label: 'Continue with Google',
                onPressed: _loading || _googleLoading ? null : _submitGoogle,
                loading: _googleLoading,
                variant: AppButtonVariant.secondary,
                icon: Icons.g_mobiledata_rounded,
                fullWidth: true,
              ),

              const SizedBox(height: AppSpacing.l),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.navy800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.role, required this.onChanged});
  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, 'I need a place', UserRole.tenant)),
          Expanded(child: _segment(context, 'I list a property', UserRole.owner)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, UserRole value) {
    final selected = role == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy800 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.bodyM.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}