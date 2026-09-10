import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../models/ai_preferences.dart';
import '../../../../models/property_filters.dart' show kAmenityOptions;

Future<AIPreferences?> showAIPreferencesSheet(BuildContext context, AIPreferences current) {
  return showModalBottomSheet<AIPreferences>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AIPreferencesSheet(initial: current),
  );
}

const _distanceOptions = [500, 1000, 2000, 5000];

class _AIPreferencesSheet extends StatefulWidget {
  const _AIPreferencesSheet({required this.initial});
  final AIPreferences initial;

  @override
  State<_AIPreferencesSheet> createState() => _AIPreferencesSheetState();
}

class _AIPreferencesSheetState extends State<_AIPreferencesSheet> {
  late num? _maxBudget = widget.initial.maxBudget;
  late int? _maxDistance = widget.initial.maxDistanceMeters;
  late Set<String> _amenities = {...widget.initial.preferredAmenities};

  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_maxBudget != null) _budgetController.text = _maxBudget!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
                    Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.gold600),
                    const SizedBox(width: AppSpacing.s),
                    Text('Tell us what you need', style: AppTypography.headingM),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xs, AppSpacing.l, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "We'll score every listing against this and explain each match.",
                    style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xl, AppSpacing.l, AppSpacing.xxxl),
                  children: [
                    Text('YOUR BUDGET (₱/MO)', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 2500'),
                      onChanged: (value) => _maxBudget = num.tryParse(value),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('PREFERRED DISTANCE', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.s),
                    Wrap(
                      spacing: AppSpacing.s,
                      children: [
                        _chip('No preference', selected: _maxDistance == null, onTap: () => setState(() => _maxDistance = null)),
                        ..._distanceOptions.map((d) {
                          final label = d >= 1000 ? 'Within ${d ~/ 1000}km' : 'Within ${d}m';
                          return _chip(label, selected: _maxDistance == d, onTap: () => setState(() => _maxDistance = d));
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text('MUST-HAVE AMENITIES', style: AppTypography.label),
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
                    label: 'Get recommendations',
                    icon: Icons.auto_awesome_rounded,
                    fullWidth: true,
                    onPressed: () => Navigator.of(context).pop(
                      AIPreferences(
                        maxBudget: _maxBudget,
                        maxDistanceMeters: _maxDistance,
                        preferredAmenities: _amenities,
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
