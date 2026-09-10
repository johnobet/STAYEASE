import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../models/reservation_model.dart';
import '../../../models/user_model.dart';
import '../../../services/reservation_service.dart';
import 'payment_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final reservationService = ReservationService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<List<ReservationModel>>(
        stream: reservationService.watchTenantReservations(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load your bookings.',
                style: AppTypography.bodyM.copyWith(color: AppColors.danger),
              ),
            );
          }

          final reservations = snapshot.data ?? [];
          if (reservations.isEmpty) {
            return Center(
              child: Text(
                'No reservations yet.\nBrowse properties and hit Reserve to get started.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
            itemBuilder: (context, index) => _BookingCard(reservation: reservations[index], user: user),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.reservation, required this.user});
  final ReservationModel reservation;
  final UserModel user;

  Color get _statusColor {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return AppColors.warning;
      case ReservationStatus.approved:
      case ReservationStatus.reserved:
      case ReservationStatus.checkedIn:
      case ReservationStatus.completed:
        return AppColors.success;
      case ReservationStatus.rejected:
      case ReservationStatus.cancelled:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPay = reservation.status == ReservationStatus.approved;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.propertyName.isNotEmpty ? reservation.propertyName : 'Property',
                  style: AppTypography.headingS,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  reservation.status.label,
                  style: AppTypography.label.copyWith(fontSize: 10, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('Check-in ${_formatDate(reservation.checkInDate)}', style: AppTypography.bodyS),
              if (reservation.priceLabel.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.m),
                Text(reservation.priceLabel, style: AppTypography.mono),
              ],
            ],
          ),
          if (reservation.status == ReservationStatus.pending) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              'Waiting for the owner to approve your request.',
              style: AppTypography.bodyS.copyWith(color: AppColors.textTertiary),
            ),
          ],
          if (canPay) ...[
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: 'Pay now',
              icon: Icons.payments_rounded,
              fullWidth: true,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(reservation: reservation, user: user),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
