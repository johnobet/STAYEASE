import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../services/favorite_service.dart';
import '../../../services/property_service.dart';
import 'property_detail_screen.dart';
import 'widgets/property_browse_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final favoriteService = FavoriteService();
    final propertyService = PropertyService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<Set<String>>(
        stream: favoriteService.watchFavoritePropertyIds(user.uid),
        builder: (context, favSnapshot) {
          final favoriteIds = favSnapshot.data ?? {};

          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favoriteIds.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet.\nTap the heart on a property to save it here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return StreamBuilder<List<PropertyModel>>(
            stream: propertyService.watchAllProperties(),
            builder: (context, propSnapshot) {
              if (propSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final favorited = (propSnapshot.data ?? [])
                  .where((p) => favoriteIds.contains(p.id))
                  .toList();

              if (favorited.isEmpty) {
                return Center(
                  child: Text(
                    'No favorites yet.',
                    style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: favorited.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.l),
                itemBuilder: (context, index) {
                  final property = favorited[index];
                  return PropertyBrowseTile(
                    property: property,
                    isFavorited: true,
                    onToggleFavorite: () => favoriteService.toggleFavorite(
                      userId: user.uid,
                      propertyId: property.id,
                      currentlyFavorited: true,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(property: property, user: user),
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
