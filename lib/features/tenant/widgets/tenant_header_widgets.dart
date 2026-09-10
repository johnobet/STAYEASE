import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../models/tenant_models.dart';

/// "Good morning, John. 👋 / Find a place that feels right."
/// The last word is set in terracotta as the one accent moment.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.firstName, this.onNotificationsTap, this.notificationCount = 0});

  final String firstName;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting, $firstName. 👋', style: AppTypography.bodyL.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              RichText(
                text: TextSpan(
                  style: AppTypography.displayL,
                  children: [
                    const TextSpan(text: 'Find a place\nthat feels '),
                    TextSpan(text: 'right.', style: TextStyle(color: AppColors.terracotta600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _NotificationBell(count: notificationCount, onTap: onNotificationsTap),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.card),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_outlined, color: AppColors.sage800, size: 22),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: const BoxDecoration(color: AppColors.terracotta600, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "STAYING NEAR / 📍 BISU Candijay · Change >" — quiet inline selector,
/// not a heavy pill, so it sits calmly under the hero headline.
class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key, required this.currentLabel, this.onTap});

  final String currentLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STAYING NEAR', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.sage800, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(currentLabel, style: AppTypography.headingS),
              const SizedBox(width: AppSpacing.m),
              Text('Change', style: AppTypography.bodyM.copyWith(color: AppColors.sage600, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sage600, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-bleed hero card carrying the AI match. Carousel dots signal more
/// photos; the match badge + heart sit over the image; price/rating/
/// distance and the "View details" action anchor the bottom.
class StayEaseMatchHeroCard extends StatefulWidget {
  const StayEaseMatchHeroCard({super.key, required this.match, this.onTap, this.onFavoriteTap, this.isFavorite = false, this.photoCount = 6});

  final MatchRecommendation match;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final int photoCount;

  @override
  State<StayEaseMatchHeroCard> createState() => _StayEaseMatchHeroCardState();
}

class _StayEaseMatchHeroCardState extends State<StayEaseMatchHeroCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 340,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeNetworkImage(url: m.property.imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.sage900.withOpacity(0.85)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.m,
              left: AppSpacing.m,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  decoration: BoxDecoration(color: AppColors.sage800, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text('${m.matchScore}% match', style: AppTypography.bodyS.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: AppSpacing.m, right: AppSpacing.m, child: _HeroFavoriteButton(isFavorite: widget.isFavorite, onTap: widget.onFavoriteTap)),
            Positioned(
              left: AppSpacing.l,
              right: AppSpacing.l,
              bottom: AppSpacing.l,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.property.name, style: AppTypography.headingL.copyWith(color: Colors.white)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(m.property.formattedPrice, style: AppTypography.headingS.copyWith(color: AppColors.terracotta600.withOpacity(0.95))),
                      Text(' / month', style: AppTypography.bodyS.copyWith(color: Colors.white70)),
                      const SizedBox(width: AppSpacing.m),
                      Text('•  ${m.property.formattedDistance}', style: AppTypography.bodyS.copyWith(color: Colors.white70)),
                      const SizedBox(width: AppSpacing.m),
                      const Icon(Icons.star_rounded, color: AppColors.gold500, size: 14),
                      Text(' ${m.property.rating}', style: AppTypography.bodyS.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text(m.reason, style: AppTypography.bodyS.copyWith(color: Colors.white70))),
                      const SizedBox(width: AppSpacing.m),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                        decoration: BoxDecoration(color: AppColors.sage800, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View details', style: AppTypography.bodyS.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.photoCount, (i) {
                      final active = i == _activeDot;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: active ? 16 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
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

class _HeroFavoriteButton extends StatefulWidget {
  const _HeroFavoriteButton({required this.isFavorite, this.onTap});
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  State<_HeroFavoriteButton> createState() => _HeroFavoriteButtonState();
}

class _HeroFavoriteButtonState extends State<_HeroFavoriteButton> with SingleTickerProviderStateMixin {
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
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.isFavorite ? AppColors.terracotta600 : AppColors.sage800,
            size: 18,
          ),
        ),
      ),
    );
  }
}
