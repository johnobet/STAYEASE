import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../data/tenant_repository.dart';
import '../models/tenant_models.dart';
import '../property_details/property_details_screen.dart';
import '../widgets/property_list_card.dart';
import '../widgets/tenant_property_widgets.dart';

enum _PriceFilter { any, under2000, from2000to2800, above2800 }

enum _DistanceFilter { any, under1km, under2km }

/// Explore tab — search + filters over the full property catalog.
/// Live Firestore stream via [TenantRepository.watchAllProperties];
/// filtering runs client-side. Favorites read/write straight to
/// Firestore so the heart state stays in sync with Home and Favorites.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.tenantId});
  final String tenantId;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _repo = TenantRepository();
  final _searchController = TextEditingController();
  String _query = '';
  _PriceFilter _price = _PriceFilter.any;
  _DistanceFilter _distance = _DistanceFilter.any;
  bool _verifiedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Property> _applyFilters(List<Property> all) {
    return all.where((p) {
      if (_query.isNotEmpty && !p.name.toLowerCase().contains(_query.toLowerCase())) return false;
      if (_verifiedOnly && !p.isVerified) return false;
      switch (_price) {
        case _PriceFilter.under2000:
          if (p.pricePerMonth >= 2000) return false;
        case _PriceFilter.from2000to2800:
          if (p.pricePerMonth < 2000 || p.pricePerMonth > 2800) return false;
        case _PriceFilter.above2800:
          if (p.pricePerMonth <= 2800) return false;
        case _PriceFilter.any:
          break;
      }
      switch (_distance) {
        case _DistanceFilter.under1km:
          if (p.distanceMeters >= 1000) return false;
        case _DistanceFilter.under2km:
          if (p.distanceMeters >= 2000) return false;
        case _DistanceFilter.any:
          break;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<Set<String>>(
        stream: _repo.watchFavoriteIds(widget.tenantId),
        builder: (context, favSnap) {
          final favorites = favSnap.data ?? {};
          return StreamBuilder<List<Property>>(
            stream: _repo.watchAllProperties(),
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final all = snap.data ?? const [];
              final results = _applyFilters(all);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore', style: AppTypography.displayL.copyWith(fontSize: 26)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${all.length} boarding houses near BISU Candijay', style: AppTypography.bodyS),
                        const SizedBox(height: AppSpacing.l),
                        _SearchField(controller: _searchController, onChanged: (v) => setState(() => _query = v)),
                        const SizedBox(height: AppSpacing.m),
                        _FilterRow(
                          price: _price,
                          distance: _distance,
                          verifiedOnly: _verifiedOnly,
                          onPriceChanged: (v) => setState(() => _price = v),
                          onDistanceChanged: (v) => setState(() => _distance = v),
                          onVerifiedChanged: (v) => setState(() => _verifiedOnly = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : results.isEmpty
                            ? const Center(
                                child: TenantEmptyState(
                                  icon: Icons.search_off_rounded,
                                  title: 'No matches for these filters.',
                                  message: 'Try widening your price range or distance.',
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.xl),
                                itemCount: results.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                                itemBuilder: (context, i) {
                                  final p = results[i];
                                  final isFav = favorites.contains(p.id);
                                  return PropertyListCard(
                                    property: p,
                                    isFavorite: isFav,
                                    onFavoriteTap: () => _repo.setFavorite(widget.tenantId, p.id, !isFav),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PropertyDetailsScreen(
                                          property: p,
                                          tenantId: widget.tenantId,
                                          isFavorite: isFav,
                                          onFavoriteTap: () => _repo.setFavorite(widget.tenantId, p.id, !isFav),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), boxShadow: AppShadows.card),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyM,
        decoration: InputDecoration(
          hintText: 'Search by name or area',
          hintStyle: AppTypography.bodyM.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.sage800),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.price,
    required this.distance,
    required this.verifiedOnly,
    required this.onPriceChanged,
    required this.onDistanceChanged,
    required this.onVerifiedChanged,
  });

  final _PriceFilter price;
  final _DistanceFilter distance;
  final bool verifiedOnly;
  final ValueChanged<_PriceFilter> onPriceChanged;
  final ValueChanged<_DistanceFilter> onDistanceChanged;
  final ValueChanged<bool> onVerifiedChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: price == _PriceFilter.any ? 'Price' : _priceLabel(price),
            active: price != _PriceFilter.any,
            onTap: () => _showPriceSheet(context),
          ),
          const SizedBox(width: AppSpacing.s),
          _FilterChip(
            label: distance == _DistanceFilter.any ? 'Distance' : _distanceLabel(distance),
            active: distance != _DistanceFilter.any,
            onTap: () => _showDistanceSheet(context),
          ),
          const SizedBox(width: AppSpacing.s),
          _FilterChip(label: 'Verified only', active: verifiedOnly, icon: Icons.verified_rounded, onTap: () => onVerifiedChanged(!verifiedOnly)),
        ],
      ),
    );
  }

  String _priceLabel(_PriceFilter p) => switch (p) {
        _PriceFilter.under2000 => 'Under ₱2,000',
        _PriceFilter.from2000to2800 => '₱2,000–2,800',
        _PriceFilter.above2800 => 'Above ₱2,800',
        _PriceFilter.any => 'Price',
      };

  String _distanceLabel(_DistanceFilter d) => switch (d) {
        _DistanceFilter.under1km => 'Under 1km',
        _DistanceFilter.under2km => 'Under 2km',
        _DistanceFilter.any => 'Distance',
      };

  void _showPriceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (sheetContext) => _FilterSheet<_PriceFilter>(
        title: 'Price range',
        current: price,
        options: const {
          _PriceFilter.any: 'Any price',
          _PriceFilter.under2000: 'Under ₱2,000',
          _PriceFilter.from2000to2800: '₱2,000 – ₱2,800',
          _PriceFilter.above2800: 'Above ₱2,800',
        },
        onSelected: onPriceChanged,
      ),
    );
  }

  void _showDistanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (sheetContext) => _FilterSheet<_DistanceFilter>(
        title: 'Distance from campus',
        current: distance,
        options: const {
          _DistanceFilter.any: 'Any distance',
          _DistanceFilter.under1km: 'Under 1km',
          _DistanceFilter.under2km: 'Under 2km',
        },
        onSelected: onDistanceChanged,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active, this.icon, this.onTap});
  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: active ? AppColors.sage800 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: active ? null : Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: active ? Colors.white : AppColors.sage800),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTypography.bodyS.copyWith(color: active ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: active ? Colors.white : AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet<T> extends StatelessWidget {
  const _FilterSheet({required this.title, required this.current, required this.options, required this.onSelected});
  final String title;
  final T current;
  final Map<T, String> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headingM),
            const SizedBox(height: AppSpacing.m),
            ...options.entries.map((e) {
              final selected = e.key == current;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.value, style: AppTypography.bodyM.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.sage800) : null,
                onTap: () {
                  onSelected(e.key);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
