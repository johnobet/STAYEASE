import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../data/owner_repository.dart';
import '../models/owner_models.dart';

/// "Reservation Requests" — completes item 43/44's loop from the owner
/// side. Approving flips a reservation to `active`, which is what makes
/// it show as "Active" (not "Pending") on the tenant's Bookings tab.
class OwnerRequestsScreen extends StatelessWidget {
  const OwnerRequestsScreen({super.key, required this.ownerId});
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final repo = OwnerRepository();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<ReservationRequest>>(
          stream: repo.watchPendingRequests(ownerId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                Text('Reservation Requests', style: AppTypography.displayL.copyWith(fontSize: 24)),
                const SizedBox(height: AppSpacing.xs),
                Text('${requests.length} pending', style: AppTypography.bodyS),
                const SizedBox(height: AppSpacing.xl),
                if (requests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.m),
                        Text('No pending requests.', style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('New reservation requests will show up here.', style: AppTypography.bodyS),
                      ],
                    ),
                  )
                else
                  ...requests.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: _RequestCard(request: r, repo: repo),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({required this.request, required this.repo});
  final ReservationRequest request;
  final OwnerRepository repo;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _busy = false;

  String get _checkInLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = widget.request.checkInDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _act(Future<void> Function(ReservationRequest) action) async {
    setState(() => _busy = true);
    try {
      await action(widget.request);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SafeNetworkImage(
                url: r.propertyImageUrl,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.propertyName, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(r.roomLabel, style: AppTypography.bodyS),
                    Text('Check-in: $_checkInLabel', style: AppTypography.bodyS),
                    Text('Tenant: ${r.tenantShortId}...', style: AppTypography.bodyS.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.l, color: AppColors.borderSubtle),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reject',
                  variant: AppButtonVariant.secondary,
                  onPressed: _busy ? null : () => _act(widget.repo.rejectRequest),
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: AppButton(
                  label: 'Approve',
                  onPressed: _busy ? null : () => _act(widget.repo.approveRequest),
                  loading: _busy,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
