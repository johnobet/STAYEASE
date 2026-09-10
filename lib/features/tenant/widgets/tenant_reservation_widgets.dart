import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../models/tenant_models.dart';

/// "YOUR NEXT STAY" — tinted sage card, sits side-by-side with rent.
class ReservationCard extends StatelessWidget {
  const ReservationCard({super.key, required this.reservation, this.onViewStay, this.onNavigate});

  final ActiveReservation reservation;
  final VoidCallback? onViewStay;
  final VoidCallback? onNavigate;

  String get _checkInLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = reservation.checkInDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(color: AppColors.sage100, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR NEXT STAY', style: AppTypography.label),
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeNetworkImage(
                url: reservation.propertyImageUrl,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reservation.propertyName, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(reservation.roomLabel, style: AppTypography.bodyS),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.sage600),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_checkInLabel, style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600)),
                    Text('Check-in', style: AppTypography.bodyS),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.l, color: AppColors.borderSubtle),
          Row(
            children: [
              Flexible(child: _CardLink(label: 'View stay', onTap: onViewStay)),
              const SizedBox(width: AppSpacing.s),
              Flexible(child: _CardLink(label: 'Navigate', icon: Icons.send_rounded, onTap: onNavigate)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "RENT" — tinted sage card with terracotta urgency text.
class PaymentSummary extends StatelessWidget {
  const PaymentSummary({super.key, required this.rentStatus, this.onTap});

  final RentStatus rentStatus;
  final VoidCallback? onTap;

  String get _dueLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = rentStatus.dueDate;
    return 'Due on ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(color: AppColors.sage100, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RENT', style: AppTypography.label),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.sage800),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(rentStatus.formattedAmount, style: AppTypography.displayL.copyWith(fontSize: 26)),
          const SizedBox(height: AppSpacing.xs),
          Text('Due in ${rentStatus.daysUntilDue} days', style: AppTypography.bodyM.copyWith(color: AppColors.terracotta600, fontWeight: FontWeight.w700)),
          Text(_dueLabel, style: AppTypography.bodyS),
          const Divider(height: AppSpacing.l, color: AppColors.borderSubtle),
          _CardLink(label: 'Pay rent', onTap: onTap),
        ],
      ),
    );
  }
}

class _CardLink extends StatelessWidget {
  const _CardLink({required this.label, this.icon, this.onTap});
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w700, color: AppColors.sage800)),
            const SizedBox(width: 2),
            Icon(icon ?? Icons.chevron_right_rounded, size: 15, color: AppColors.sage800),
          ],
        ),
      ),
    );
  }
}

enum TenantNavTab { home, explore, bookings, messages, profile }

/// Original bottom navigation — white surface, all labels always visible,
/// sage active state, terracotta badge on Messages (matches reference).
class TenantBottomNav extends StatelessWidget {
  const TenantBottomNav({super.key, required this.current, required this.onChanged, this.messageBadgeCount = 0});

  final TenantNavTab current;
  final ValueChanged<TenantNavTab> onChanged;
  final int messageBadgeCount;

  static const _items = [
    (TenantNavTab.home, Icons.home_rounded, 'Home'),
    (TenantNavTab.explore, Icons.explore_outlined, 'Explore'),
    (TenantNavTab.bookings, Icons.calendar_month_outlined, 'Bookings'),
    (TenantNavTab.messages, Icons.chat_bubble_outline_rounded, 'Messages'),
    (TenantNavTab.profile, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.map((item) {
            final (tab, icon, label) = item;
            final selected = tab == current;
            final showBadge = tab == TenantNavTab.messages && messageBadgeCount > 0;
            return GestureDetector(
              onTap: () => onChanged(tab),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(icon, size: 22, color: selected ? AppColors.sage800 : AppColors.textTertiary),
                        if (showBadge)
                          Positioned(
                            top: -3,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: const BoxDecoration(color: AppColors.terracotta600, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: Text('$messageBadgeCount', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: AppTypography.bodyS.copyWith(
                        fontSize: 11,
                        color: selected ? AppColors.sage800 : AppColors.textTertiary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
