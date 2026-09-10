import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../models/reservation_model.dart';
import '../../../services/reservation_service.dart';

class ReservationRequestsScreen extends StatefulWidget {
  const ReservationRequestsScreen({
    super.key,
    required this.ownerId,
    this.propertyId,
    this.propertyName,
  });
  final String ownerId;

  /// When set, only reservations for this property are shown — used when
  /// navigating in from a specific property card. When null, shows every
  /// reservation across all of the owner's properties.
  final String? propertyId;
  final String? propertyName;

  @override
  State<ReservationRequestsScreen> createState() => _ReservationRequestsScreenState();
}

class _ReservationRequestsScreenState extends State<ReservationRequestsScreen>
    with SingleTickerProviderStateMixin {
  final _service = ReservationService();
  late final TabController _tabController;
  final Set<String> _actingOn = {}; // reservation IDs currently approve/reject-ing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _act(String reservationId, {required bool approve}) async {
    setState(() => _actingOn.add(reservationId));
    try {
      approve ? await _service.approve(reservationId) : await _service.reject(reservationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(approve ? 'Reservation approved' : 'Reservation rejected')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _actingOn.remove(reservationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propertyName != null ? widget.propertyName! : 'Reservation Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy800,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.gold500,
          indicatorWeight: 3,
          labelStyle: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Pending'), Tab(text: 'All')],
        ),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: _service.watchOwnerReservations(widget.ownerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load reservations.',
                style: AppTypography.bodyM.copyWith(color: AppColors.danger),
              ),
            );
          }

          final owned = snapshot.data ?? [];
          final all = widget.propertyId == null
              ? owned
              : owned.where((r) => r.propertyId == widget.propertyId).toList();
          final pending = all.where((r) => r.status == ReservationStatus.pending).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ReservationList(
                reservations: pending,
                actingOn: _actingOn,
                onApprove: (id) => _act(id, approve: true),
                onReject: (id) => _act(id, approve: false),
                emptyMessage: 'No pending requests right now.',
              ),
              _ReservationList(
                reservations: all,
                actingOn: _actingOn,
                onApprove: (id) => _act(id, approve: true),
                onReject: (id) => _act(id, approve: false),
                emptyMessage: 'No reservations yet.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList({
    required this.reservations,
    required this.actingOn,
    required this.onApprove,
    required this.onReject,
    required this.emptyMessage,
  });

  final List<ReservationModel> reservations;
  final Set<String> actingOn;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final r = reservations[index];
        return _ReservationCard(
          reservation: r,
          busy: actingOn.contains(r.id),
          onApprove: () => onApprove(r.id),
          onReject: () => onReject(r.id),
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final ReservationModel reservation;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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
    final isPending = reservation.status == ReservationStatus.pending;

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
                  reservation.tenantName.isNotEmpty ? reservation.tenantName : 'Tenant',
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            reservation.propertyName.isNotEmpty ? reservation.propertyName : 'Property',
            style: AppTypography.bodyS,
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Check-in ${_formatDate(reservation.checkInDate)}',
                style: AppTypography.bodyS,
              ),
              if (reservation.priceLabel.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.m),
                Text(reservation.priceLabel, style: AppTypography.mono),
              ],
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    onPressed: busy ? null : onApprove,
                    loading: busy,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: AppButton(
                    label: 'Reject',
                    variant: AppButtonVariant.danger,
                    onPressed: busy ? null : onReject,
                    fullWidth: true,
                  ),
                ),
              ],
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
