import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../data/tenant_repository.dart';
import '../models/tenant_models.dart';
import '../widgets/tenant_property_widgets.dart' show TenantEmptyState;

/// Bookings tab — full reservation history for the tenant, grouped into
/// Upcoming (pending/active) and Past (completed/cancelled). Pending
/// reservations can be cancelled here; approval (item 44) happens on
/// the owner side and isn't built yet, so everything the tenant creates
/// stays "Pending" until that flow exists.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key, required this.tenantId});
  final String tenantId;

  @override
  Widget build(BuildContext context) {
    final repo = TenantRepository();
    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<TenantReservation>>(
        stream: repo.watchReservations(tenantId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data ?? const [];
          if (all.isEmpty) {
            return const Center(
              child: TenantEmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'No bookings yet.',
                message: 'Reserve a boarding house and it will show up here.',
              ),
            );
          }

          final upcoming = all.where((r) => r.status.isUpcoming).toList();
          final past = all.where((r) => !r.status.isUpcoming).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text('Bookings', style: AppTypography.displayL.copyWith(fontSize: 26)),
              const SizedBox(height: AppSpacing.xl),
              if (upcoming.isNotEmpty) ...[
                Text('UPCOMING', style: AppTypography.label),
                const SizedBox(height: AppSpacing.m),
                ...upcoming.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: _BookingCard(reservation: r, repo: repo),
                    )),
                const SizedBox(height: AppSpacing.l),
              ],
              if (past.isNotEmpty) ...[
                Text('PAST', style: AppTypography.label),
                const SizedBox(height: AppSpacing.m),
                ...past.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: _BookingCard(reservation: r, repo: repo),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.reservation, required this.repo});
  final TenantReservation reservation;
  final TenantRepository repo;

  String get _checkInLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = reservation.checkInDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel this reservation?', style: AppTypography.headingS),
        content: Text('This will cancel your request at ${reservation.propertyName}.', style: AppTypography.bodyM),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              repo.cancelReservation(reservation.id);
              Navigator.of(dialogContext).pop();
            },
            child: Text('Cancel booking', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeNetworkImage(
                url: reservation.propertyImageUrl,
                width: 56,
                height: 56,
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
                    const SizedBox(height: 2),
                    Text('Check-in: $_checkInLabel', style: AppTypography.bodyS),
                  ],
                ),
              ),
              _StatusBadge(status: reservation.status),
            ],
          ),
          if (reservation.status == ReservationStatus.pending) ...[
            const Divider(height: AppSpacing.l, color: AppColors.borderSubtle),
            GestureDetector(
              onTap: () => _confirmCancel(context),
              child: Text('Cancel request', style: AppTypography.bodyS.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ReservationStatus status;

  Color get _bg => switch (status) {
        ReservationStatus.pending => AppColors.warningBg,
        ReservationStatus.active => AppColors.sage100,
        ReservationStatus.completed => AppColors.surfaceSunken,
        ReservationStatus.cancelled => AppColors.dangerBg,
      };

  Color get _fg => switch (status) {
        ReservationStatus.pending => AppColors.warning,
        ReservationStatus.active => AppColors.sage800,
        ReservationStatus.completed => AppColors.textTertiary,
        ReservationStatus.cancelled => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(status.label, style: AppTypography.bodyS.copyWith(color: _fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
