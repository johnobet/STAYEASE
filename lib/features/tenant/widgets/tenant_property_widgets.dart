import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../models/tenant_models.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onActionTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: AppTypography.label),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              children: [
                Text(actionLabel!, style: AppTypography.bodyS.copyWith(color: AppColors.sage800, fontWeight: FontWeight.w700)),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.sage800),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Places around you" horizontal card — distance badge top-left over the
/// photo, heart top-right, name/distance/price/rating below.
class PropertyCompactCard extends StatelessWidget {
  const PropertyCompactCard({super.key, required this.property, this.onTap, this.onFavoriteTap, this.isFavorite = false});

  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 176,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(url: property.imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.sage800, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text(property.formattedDistance.replaceAll(' away', ''), style: AppTypography.bodyS.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: _CompactFavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(property.formattedDistance, style: AppTypography.bodyS),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(property.formattedPrice, style: AppTypography.bodyM.copyWith(color: AppColors.terracotta600, fontWeight: FontWeight.w700)),
                      Text(' /month', style: AppTypography.bodyS),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: AppColors.gold500, size: 13),
                      Text(' ${property.rating}', style: AppTypography.bodyS),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactFavoriteButton extends StatefulWidget {
  const _CompactFavoriteButton({required this.isFavorite, this.onTap});
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  State<_CompactFavoriteButton> createState() => _CompactFavoriteButtonState();
}

class _CompactFavoriteButtonState extends State<_CompactFavoriteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 180), lowerBound: 0.85, upperBound: 1.0)..value = 1.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.85);
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.isFavorite ? AppColors.terracotta600 : AppColors.sage800,
            size: 14,
          ),
        ),
      ),
    );
  }
}

/// "EXPLORE ON MAP" — sage card with a lightweight painted map preview
/// (no live Mapbox tiles needed for the dashboard teaser; the real map
/// lives on the Explore tab / navigation flow).
class ExploreMapPreview extends StatelessWidget {
  const ExploreMapPreview({super.key, required this.nearbyCount, this.onExploreTap});

  final int nearbyCount;
  final VoidCallback? onExploreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.sage100, borderRadius: BorderRadius.circular(AppRadius.xl)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EXPLORE ON MAP', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                Text('$nearbyCount places nearby', style: AppTypography.headingM),
                const SizedBox(height: 2),
                Text('Find great boarding houses near your campus.', style: AppTypography.bodyS),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _MapPreviewPainter()),
                const Center(child: _MapPin(size: 34, filled: true)),
                const Positioned(left: 40, top: 20, child: _MapPin(size: 18)),
                const Positioned(right: 30, top: 14, child: _MapPin(size: 18)),
                const Positioned(left: 55, bottom: 12, child: _MapPin(size: 18)),
                const Positioned(right: 45, bottom: 18, child: _MapPin(size: 18)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: GestureDetector(
              onTap: onExploreTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                decoration: BoxDecoration(color: AppColors.sage800, borderRadius: BorderRadius.circular(AppRadius.md)),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Explore map', style: AppTypography.button.copyWith(color: Colors.white)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.size, this.filled = false});
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on_rounded,
      size: size,
      color: filled ? AppColors.terracotta600 : AppColors.sage600,
    );
  }
}

/// Lightweight abstract map texture — soft roads on a tinted field.
/// Placeholder until the real Mapbox view is wired into Explore/Navigate.
class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.sage200;
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final river = Paint()
      ..color = AppColors.sage300.withOpacity(0.6)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width, size.height * 0.25);
    canvas.drawPath(path1, road);

    final path2 = Path()
      ..moveTo(size.width * 0.15, 0)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.3, size.height);
    canvas.drawPath(path2, road);

    final riverPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.95, size.width, size.height * 0.7);
    canvas.drawPath(riverPath, river);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : AppSpacing.s, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: AppColors.sage800, size: compact ? 12 : 14),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text('Verified', style: AppTypography.label.copyWith(color: AppColors.sage800, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class TenantEmptyState extends StatelessWidget {
  const TenantEmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: AppColors.sage100, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.sage600, size: 24),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(title, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: AppTypography.bodyS),
        ],
      ),
    );
  }
}

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.signalOffline, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'Offline mode  ', style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  TextSpan(text: 'Your saved stays and downloaded routes are still available.', style: AppTypography.bodyS),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
