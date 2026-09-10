import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../models/tenant_models.dart';
import 'tenant_property_widgets.dart' show VerificationBadge;

/// Wide horizontal card for vertical list contexts (Explore results,
/// Favorites) — image left, details right, unlike the taller
/// [PropertyCompactCard] used in horizontal-scroll rows.
class PropertyListCard extends StatelessWidget {
  const PropertyListCard({super.key, required this.property, this.onTap, this.onFavoriteTap, this.isFavorite = false});

  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SafeNetworkImage(url: property.imageUrl, width: 96, height: 96),
                ),
                if (property.isVerified) const Positioned(top: 6, left: 6, child: VerificationBadge(compact: true)),
              ],
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(property.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700))),
                        _FavoriteDot(isFavorite: isFavorite, onTap: onFavoriteTap),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textTertiary),
                        Text(property.formattedDistance, style: AppTypography.bodyS),
                        const SizedBox(width: AppSpacing.s),
                        const Icon(Icons.star_rounded, color: AppColors.gold500, size: 13),
                        Text(' ${property.rating}', style: AppTypography.bodyS),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(property.formattedPrice, style: AppTypography.bodyM.copyWith(color: AppColors.terracotta600, fontWeight: FontWeight.w700)),
                        Text(' /month', style: AppTypography.bodyS),
                        const Spacer(),
                        Text(
                          property.availableRooms > 0 ? '${property.availableRooms} room${property.availableRooms > 1 ? 's' : ''} left' : 'Full',
                          style: AppTypography.bodyS.copyWith(
                            color: property.availableRooms > 0 ? AppColors.sage600 : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteDot extends StatelessWidget {
  const _FavoriteDot({required this.isFavorite, this.onTap});
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 18,
        color: isFavorite ? AppColors.terracotta600 : AppColors.textTertiary,
      ),
    );
  }
}
