import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai_preferences.dart';
import '../../../models/property_filters.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../services/ai_match_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/favorite_service.dart';
import '../../../services/property_service.dart';
import 'favorites_screen.dart';
import 'my_bookings_screen.dart';
import 'property_detail_screen.dart';
import 'widgets/ai_preferences_sheet.dart';
import 'widgets/property_browse_tile.dart';
import 'widgets/property_filter_sheet.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final _propertyService = PropertyService();
  final _favoriteService = FavoriteService();
  final _aiMatchService = AIMatchService();
  final _searchController = TextEditingController();

  String _query = '';
  PropertyFilters _filters = const PropertyFilters();
  AIPreferences? _aiPreferences; // null = AI recommendations off

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final result = await showPropertyFilterSheet(context, _filters);
    if (result != null) setState(() => _filters = result);
  }

  Future<void> _openAIPreferences() async {
    final result = await showAIPreferencesSheet(context, _aiPreferences ?? const AIPreferences());
    if (result != null) setState(() => _aiPreferences = result);
  }

  void _clearAI() => setState(() => _aiPreferences = null);

  List<PropertyModel> _applySearchAndFilters(List<PropertyModel> properties) {
    final query = _query.trim().toLowerCase();
    return properties.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.address.toLowerCase().contains(query);
      return matchesQuery && _filters.matches(p);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your stay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FavoritesScreen(user: widget.user)),
            ),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MyBookingsScreen(user: widget.user)),
            ),
            tooltip: 'My Bookings',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => AuthService().signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.s),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search by name or location',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _filters.isActive ? AppColors.navy800 : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: _filters.isActive ? AppColors.navy800 : AppColors.borderSubtle),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: _filters.isActive ? AppColors.textOnDark : AppColors.textSecondary,
                        ),
                        if (_filters.isActive)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle),
                              child: Text(
                                '${_filters.activeCount}',
                                style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.navy900, height: 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.s),
            child: _aiPreferences == null
                ? GestureDetector(
                    onTap: _openAIPreferences,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: AppColors.navy800,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.gold500, size: 20),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Text(
                              'Get AI-matched recommendations',
                              style: AppTypography.bodyM.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textOnDarkMuted),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.gold100,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gold200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppColors.gold600, size: 18),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            'Sorted by AI match',
                            style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600, color: AppColors.navy800),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openAIPreferences,
                          child: Text('Edit', style: AppTypography.bodyS.copyWith(color: AppColors.navy800, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        GestureDetector(
                          onTap: _clearAI,
                          child: Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: StreamBuilder<List<PropertyModel>>(
              stream: _propertyService.watchAllProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load properties.',
                      style: AppTypography.bodyM.copyWith(color: AppColors.danger),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                var results = _applySearchAndFilters(all);

                // Precompute scores once per build if AI mode is on, so
                // sorting and each tile's ring use the exact same numbers.
                final Map<String, MatchScoreResult> scores = {};
                if (_aiPreferences != null) {
                  for (final property in results) {
                    scores[property.id] = _aiMatchService.score(property, _aiPreferences!);
                  }
                  results = [...results]..sort((a, b) => scores[b.id]!.percent.compareTo(scores[a.id]!.percent));
                }

                return StreamBuilder<Set<String>>(
                  stream: _favoriteService.watchFavoritePropertyIds(widget.user.uid),
                  builder: (context, favSnapshot) {
                    final favoriteIds = favSnapshot.data ?? {};

                    if (results.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            all.isEmpty
                                ? 'No properties available yet.'
                                : 'No properties match your search/filters.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xxxl),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.l),
                      itemBuilder: (context, index) {
                        final property = results[index];
                        final isFavorited = favoriteIds.contains(property.id);
                        final matchResult = scores[property.id];
                        return PropertyBrowseTile(
                          property: property,
                          isFavorited: isFavorited,
                          matchPercent: matchResult?.percent,
                          onToggleFavorite: () => _favoriteService.toggleFavorite(
                            userId: widget.user.uid,
                            propertyId: property.id,
                            currentlyFavorited: isFavorited,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(
                                property: property,
                                user: widget.user,
                                aiPreferences: _aiPreferences,
                                matchResult: matchResult,
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
          ),
        ],
      ),
    );
  }
}
