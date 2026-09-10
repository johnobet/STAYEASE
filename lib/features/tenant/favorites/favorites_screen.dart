import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/tenant_repository.dart';
import '../models/tenant_models.dart';
import '../property_details/property_details_screen.dart';
import '../widgets/property_list_card.dart';
import '../widgets/tenant_property_widgets.dart';

/// Dedicated Favorites screen — pushed from Profile (item 37). Reads the
/// live set of favorited property ids, then resolves the matching
/// [Property] objects. Unfavoriting here updates Firestore immediately
/// and the list re-streams to drop it.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.tenantId});
  final String tenantId;

  @override
  Widget build(BuildContext context) {
    final repo = TenantRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: AppTypography.headingM),
        centerTitle: false,
        elevation: 0,
      ),
      body: StreamBuilder<Set<String>>(
        stream: repo.watchFavoriteIds(tenantId),
        builder: (context, idsSnap) {
          if (idsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = idsSnap.data ?? {};
          if (ids.isEmpty) {
            return const Center(
              child: TenantEmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'No saved places yet.',
                message: 'Save a boarding house you love and we\'ll keep it here.',
              ),
            );
          }
          return FutureBuilder<List<Property>>(
            future: repo.fetchFavoriteProperties(ids),
            builder: (context, propSnap) {
              if (!propSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final properties = propSnap.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: properties.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, i) {
                  final p = properties[i];
                  return PropertyListCard(
                    property: p,
                    isFavorite: true,
                    onFavoriteTap: () => repo.setFavorite(tenantId, p.id, false),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailsScreen(
                          property: p,
                          tenantId: tenantId,
                          isFavorite: true,
                          onFavoriteTap: () => repo.setFavorite(tenantId, p.id, false),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
