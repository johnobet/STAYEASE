import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';

/// Two quick-glance stat cards — "Active Bookings" and "Favorites" —
/// for the top of the Tenant Home tab. Purely presentational: counts
/// are computed by the caller from data it's already streaming
/// (TenantRepository.watchReservations / watchFavoriteIds), so this
/// widget makes no Firestore calls of its own.
class TenantStatsRow extends StatelessWidget {
  const TenantStatsRow({
    super.key,
    required this.activeBookings,
    required this.favoritesCount,
    this.onBookingsTap,
    this.onFavoritesTap,
  });

  final int activeBookings;
  final int favoritesCount;
  final VoidCallback? onBookingsTap;
  final VoidCallback? onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.event_available_rounded,
            iconBg: AppColors.sage100,
            iconColor: AppColors.sage800,
            value: '$activeBookings',
            label: activeBookings == 1 ? 'Active Booking' : 'Active Bookings',
            onTap: onBookingsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_rounded,
            iconBg: AppColors.terracottaBg,
            iconColor: AppColors.terracotta600,
            value: '$favoritesCount',
            label: favoritesCount == 1 ? 'Favorite' : 'Favorites',
            onTap: onFavoritesTap,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: AppTypography.headingM),
                  Text(
                    label,
                    style: AppTypography.bodyS,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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