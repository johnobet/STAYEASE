import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../data/owner_repository.dart';
import '../models/owner_models.dart';
import 'add_property_screen.dart';

/// "My Properties" — the owner's own listings, plus the entry point for
/// creating a new one (item 32). Uses navy/gold, consistent with the
/// rest of the Owner/Admin side per the design system doc.
class OwnerPropertiesScreen extends StatelessWidget {
  const OwnerPropertiesScreen({super.key, required this.ownerId, required this.ownerName});
  final String ownerId;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final repo = OwnerRepository();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<OwnerProperty>>(
          stream: repo.watchMyProperties(ownerId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final properties = snap.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                Text('My Properties', style: AppTypography.displayL.copyWith(fontSize: 26)),
                const SizedBox(height: AppSpacing.xs),
                Text('${properties.length} listing${properties.length == 1 ? '' : 's'}', style: AppTypography.bodyS),
                const SizedBox(height: AppSpacing.xl),
                if (properties.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Column(
                      children: [
                        const Icon(Icons.home_work_outlined, size: 40, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.m),
                        Text('No listings yet.', style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Tap the + button to publish your first property.', style: AppTypography.bodyS, textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ...properties.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: _OwnerPropertyCard(property: p),
                      )),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy800,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add property', style: AppTypography.button.copyWith(color: Colors.white)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddPropertyScreen(ownerId: ownerId, ownerName: ownerName)),
        ),
      ),
    );
  }
}

class _OwnerPropertyCard extends StatelessWidget {
  const _OwnerPropertyCard({required this.property});
  final OwnerProperty property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.card),
      child: Row(
        children: [
          SafeNetworkImage(
            url: property.imageUrl,
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.name, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${property.formattedPrice} / month · ${property.availableRooms} rooms available', style: AppTypography.bodyS),
              ],
            ),
          ),
          if (!property.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text('Unverified', style: AppTypography.bodyS.copyWith(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
