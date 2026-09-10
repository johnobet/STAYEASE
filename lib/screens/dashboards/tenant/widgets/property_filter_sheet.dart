import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../models/property_filters.dart';

/// Opens the filter sheet and returns the selected [PropertyFilters], or
/// null if the person dismissed it without applying.
Future<PropertyFilters?> showPropertyFilterSheet(BuildContext context, PropertyFilters current) {
  return showModalBottomSheet<PropertyFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FilterSheet(initial: current),
  );
}

const _distanceOptions = [500, 1000, 2000, 5000];
const _ratingOptions = [4.5, 4.0];

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final PropertyFilters initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late num? _maxPrice = widget.initial.maxPrice;
  late double _minRating = widget.initial.minRating;
  late int? _maxDistance = widget.initial.maxDistanceMeters;
  late bool _verifiedOnly = widget.initial.verifiedOnly;
  late Set<String> _amenities = {...widget.initial.amenities};

  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_maxPrice != null) _priceController.text = _maxPrice!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _maxPrice = null;
      _minRating = 0;
      _maxDistance = null;
      _verifiedOnly = false;
      _amenities = {};
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderStrong, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                child: Row(
                  children: [
                    Text('Filters', style: AppTypography.headingM),
                    const Spacer(),
                    TextButton(onPressed: _reset, child: const Text('Reset')),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.xxxl),
                  children: [
                    Text('MAX BUDGET (₱/MO)', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 3000'),
                      onChanged: (value) => _maxPrice = num.tryParse(value),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('DISTANCE', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children: [
                        _chip('Any', selected: _maxDistance == null, onTap: () => setState(() => _maxDistance = null)),
                        ..._distanceOptions.map((d) {
                          final label = d >= 1000 ? 'Within ${d ~/ 1000}km' : 'Within ${d}m';
                          return _chip(label, selected: _maxDistance == d, onTap: () => setState(() => _maxDistance = d));
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('RATING', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children: [
                        _chip('Any', selected: _minRating == 0, onTap: () => setState(() => _minRating = 0)),
                        ..._ratingOptions.map((r) {
                          return _chip('${r.toStringAsFixed(1)}+', selected: _minRating == r, onTap: () => setState(() => _minRating = r));
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VERIFIED ONLY', style: AppTypography.label),
                        Switch(
                          value: _verifiedOnly,
                          activeColor: AppColors.navy800,
                          onChanged: (value) => setState(() => _verifiedOnly = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('AMENITIES', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.s,
                      children: kAmenityOptions.map((amenity) {
                        final selected = _amenities.contains(amenity);
                        return _chip(
                          amenity,
                          selected: selected,
                          onTap: () => setState(() {
                            selected ? _amenities.remove(amenity) : _amenities.add(amenity);
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: AppButton(
                    label: 'Show results',
                    fullWidth: true,
                    onPressed: () => Navigator.of(context).pop(
                      PropertyFilters(
                        maxPrice: _maxPrice,
                        minRating: _minRating,
                        maxDistanceMeters: _maxDistance,
                        verifiedOnly: _verifiedOnly,
                        amenities: _amenities,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy800 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.navy800 : AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: AppTypography.bodyS.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
