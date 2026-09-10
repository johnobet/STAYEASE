import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// Base button used everywhere in StayEase. Deliberately not
/// `ElevatedButton`/`OutlinedButton` defaults — presses scale down slightly
/// and shadows soften, giving a tactile "pressed into the surface" feel
/// instead of Material's flat ripple-only response.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  _ButtonPalette get _palette {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _ButtonPalette(
          background: AppColors.navy800,
          foreground: AppColors.textOnDark,
          border: null,
        );
      case AppButtonVariant.secondary:
        return _ButtonPalette(
          background: AppColors.surface,
          foreground: AppColors.navy800,
          border: AppColors.navy800,
        );
      case AppButtonVariant.ghost:
        return _ButtonPalette(
          background: Colors.transparent,
          foreground: AppColors.navy800,
          border: null,
        );
      case AppButtonVariant.danger:
        return _ButtonPalette(
          background: AppColors.dangerBg,
          foreground: AppColors.danger,
          border: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final opacity = _disabled ? 0.45 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: _disabled ? null : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _disabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: widget.fullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: palette.border != null ? Border.all(color: palette.border!, width: 1.5) : null,
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(palette.foreground),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: palette.foreground),
                  const SizedBox(width: AppSpacing.s),
                ],
                Text(widget.label, style: AppTypography.button.copyWith(color: palette.foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonPalette {
  _ButtonPalette({required this.background, required this.foreground, required this.border});
  final Color background;
  final Color foreground;
  final Color? border;
}
