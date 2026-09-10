import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../models/property_model.dart';
import '../../../models/reservation_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/property_service.dart';
import '../../../services/reservation_service.dart';
import 'add_property_screen.dart';
import 'reservation_requests_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final propertyService = PropertyService();
    final reservationService = ReservationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReservationRequestsScreen(ownerId: user.uid)),
            ),
            tooltip: 'Reservation requests',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => AuthService().signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy800,
        foregroundColor: AppColors.textOnDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add property'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddPropertyScreen(ownerId: user.uid, ownerName: user.name)),
        ),
      ),
      body: Column(
        children: [
          // Pending-reservations banner — the whole point of building this
          // side now is to unblock reservations stuck on "Pending".
          StreamBuilder<List<ReservationModel>>(
            stream: reservationService.watchOwnerReservations(user.uid),
            builder: (context, snapshot) {
              final pendingCount = (snapshot.data ?? [])
                  .where((r) => r.status == ReservationStatus.pending)
                  .length;
              if (pendingCount == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ReservationRequestsScreen(ownerId: user.uid)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.gold100,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.gold200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            '$pendingCount',
                            style: AppTypography.headingS.copyWith(color: AppColors.navy900, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            pendingCount == 1
                                ? '1 reservation request needs your review'
                                : '$pendingCount reservation requests need your review',
                            style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.navy800),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: StreamBuilder<List<PropertyModel>>(
              stream: propertyService.watchOwnerProperties(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load your properties.',
                      style: AppTypography.bodyM.copyWith(color: AppColors.danger),
                    ),
                  );
                }

                final properties = snapshot.data ?? [];
                if (properties.isEmpty) {
                  return _EmptyState(ownerId: user.uid, ownerName: user.name);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.xxxl * 2,
                  ),
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) => _OwnerPropertyTile(
                    property: properties[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.ownerId, required this.ownerName});
  final String ownerId;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.l),
            Text('No properties yet', style: AppTypography.headingM),
            const SizedBox(height: AppSpacing.s),
            Text(
              'List your first boarding house to start receiving reservations.',
              style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Add your first property',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddPropertyScreen(ownerId: ownerId, ownerName: ownerName)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerPropertyTile extends StatelessWidget {
  const _OwnerPropertyTile({required this.property});
  final PropertyModel property;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property.name, style: AppTypography.headingM),
              const SizedBox(height: AppSpacing.xs),
              Text(property.address, style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.s),
                  Text('${property.availableRooms} room(s) available', style: AppTypography.bodyM),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.s),
                  Text('₱${property.pricePerMonth.toStringAsFixed(0)}/mo', style: AppTypography.bodyM),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'View reservation requests',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReservationRequestsScreen(
                        ownerId: property.ownerId,
                        propertyId: property.id,
                        propertyName: property.name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = property.status == 'active';

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppColors.navy100, borderRadius: BorderRadius.circular(AppRadius.md)),
            alignment: Alignment.center,
            child: Icon(Icons.home_rounded, color: AppColors.navy500),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.name, style: AppTypography.headingS, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  property.address,
                  style: AppTypography.bodyS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.successBg : AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              active ? 'Active' : 'Inactive',
              style: AppTypography.label.copyWith(
                fontSize: 10,
                color: active ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
