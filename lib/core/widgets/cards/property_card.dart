import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../match/match_ring.dart';

/// Property preview card used on Home, Search results, and Favorites.
///
/// Layout note: the match ring sits as an overlay on the image corner
/// rather than as a separate row — this keeps the AI score visually
/// attached to the property it's scoring, so it reads as "this property is
/// 94% right for you," not a detached stat.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.name,
    required this.priceLabel,
    required this.distanceLabel,
    required this.rating,
    this.matchPercent,
    this.verified = false,
    this.imageColor = AppColors.navy100,
    this.onTap,
  });

  final String name;
  final String priceLabel;
  final String distanceLabel;
  final double rating;
  final int? matchPercent;
  final bool verified;
  final Color imageColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: imageColor,
                    alignment: Alignment.center,
                    child: Icon(Icons.home_rounded, color: AppColors.navy500.withOpacity(0.35), size: 40),
                  ),
                ),
                if (verified)
                  Positioned(
                    top: AppSpacing.m,
                    left: AppSpacing.m,
                    child: _Chip(
                      icon: Icons.verified_rounded,
                      label: 'Verified',
                      background: AppColors.navy800,
                      foreground: AppColors.textOnDark,
                    ),
                  ),
                if (matchPercent != null)
                  Positioned(
                    bottom: -28,
                    right: AppSpacing.m,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: MatchRing(percent: matchPercent!, size: 56, strokeWidth: 5),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.headingS, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppColors.gold600),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1), style: AppTypography.bodyS),
                      const SizedBox(width: AppSpacing.s),
                      Text('·', style: AppTypography.bodyS),
                      const SizedBox(width: AppSpacing.s),
                      Icon(Icons.route_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Text(distanceLabel, style: AppTypography.bodyS),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(priceLabel, style: AppTypography.monoL.copyWith(color: AppColors.navy800)),
                      const SizedBox(width: 4),
                      Text('/mo', style: AppTypography.bodyS),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.label.copyWith(color: foreground, fontSize: 10)),
        ],
      ),
    );
  }
}
