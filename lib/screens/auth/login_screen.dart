import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthGate routes automatically on successful sign-in.
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
      // AuthGate routes automatically on successful sign-in.
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xxxl, AppSpacing.l, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back', style: AppTypography.displayL),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Log in to continue to StayEase.',
                style: AppTypography.bodyL.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                label: 'EMAIL',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'PASSWORD',
                controller: _passwordController,
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
                label: 'Log in',
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
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'New to StayEase? ',
                      style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Create an account',
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