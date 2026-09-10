import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match/match_ring.dart';
import '../../../../models/property_model.dart';

class PropertyBrowseTile extends StatelessWidget {
  const PropertyBrowseTile({
    super.key,
    required this.property,
    required this.onTap,
    required this.isFavorited,
    required this.onToggleFavorite,
    this.matchPercent,
  });

  final PropertyModel property;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;

  /// When set (AI recommendations mode is on), shows the signature Match
  /// Ring in the image corner — the same component used everywhere else
  /// AI scoring appears in the app.
  final int? matchPercent;

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.gallery.isNotEmpty ? property.gallery.first : property.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _imageFallback(),
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : _imageFallback(),
                        )
                      : _imageFallback(),
                ),
                if (property.isVerified)
                  Positioned(
                    top: AppSpacing.m,
                    left: AppSpacing.m,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.navy800,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 12, color: AppColors.textOnDark),
                          const SizedBox(width: 4),
                          Text('Verified', style: AppTypography.label.copyWith(color: AppColors.textOnDark, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: AppSpacing.m,
                  right: AppSpacing.m,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: Icon(
                        isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorited ? AppColors.danger : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (matchPercent != null)
                  Positioned(
                    bottom: -26,
                    left: AppSpacing.m,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: MatchRing(percent: matchPercent!, size: 52, strokeWidth: 5),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.l,
                matchPercent != null ? AppSpacing.xl : AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.name, style: AppTypography.headingS),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppColors.gold600),
                      const SizedBox(width: 2),
                      Text(property.rating.toStringAsFixed(1), style: AppTypography.bodyS),
                      if (property.distanceMeters != null) ...[
                        const SizedBox(width: AppSpacing.s),
                        Text('·', style: AppTypography.bodyS),
                        const SizedBox(width: AppSpacing.s),
                        Icon(Icons.route_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Text('${property.distanceMeters}m', style: AppTypography.bodyS),
                      ],
                      const SizedBox(width: AppSpacing.s),
                      Text('·', style: AppTypography.bodyS),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        property.availableRooms > 0 ? '${property.availableRooms} rooms left' : 'Fully booked',
                        style: AppTypography.bodyS.copyWith(
                          color: property.availableRooms > 0 ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₱${property.pricePerMonth.toStringAsFixed(0)}', style: AppTypography.monoL.copyWith(color: AppColors.navy800)),
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

  Widget _imageFallback() {
    return Container(
      color: AppColors.navy100,
      alignment: Alignment.center,
      child: Icon(Icons.home_rounded, color: AppColors.navy500.withOpacity(0.35), size: 40),
    );
  }
}
