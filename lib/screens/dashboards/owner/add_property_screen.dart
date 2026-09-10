import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../models/property_model.dart';
import '../../../services/property_service.dart';

const _amenityOptions = [
  'Wi-Fi', 'Private bathroom', 'Shared bathroom', 'Kitchen', 'Laundry',
  'Parking', 'Air conditioning', 'Fan', 'Study area', 'Water supply',
  'Electricity inclusion',
];

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key, required this.ownerId, required this.ownerName});
  final String ownerId;
  final String ownerName;

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _service = PropertyService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController(text: '1');

  final Set<String> _selectedAmenities = {};
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      setState(() => _error = 'Property name and address are required.');
      return;
    }
    final price = num.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a valid monthly price.');
      return;
    }
    final rooms = int.tryParse(_roomsController.text.trim()) ?? 1;

    setState(() => _loading = true);
    try {
      await _service.createProperty(
        PropertyModel(
          id: '',
          ownerId: widget.ownerId,
          ownerName: widget.ownerName,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          amenities: _selectedAmenities.toList(),
          pricePerMonth: price,
          availableRooms: rooms,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Could not save this property. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add property')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('PROPERTY INFO'),
              const SizedBox(height: AppSpacing.m),
              AppTextField(label: 'NAME', hint: "e.g. Maria's Boarding House", controller: _nameController),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'ADDRESS',
                hint: 'Street, barangay, municipality',
                controller: _addressController,
                prefixIcon: Icons.place_rounded,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'DESCRIPTION',
                hint: 'What makes this place a good stay?',
                controller: _descriptionController,
              ),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel('AMENITIES'),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: _amenityOptions.map((amenity) {
                  final selected = _selectedAmenities.contains(amenity);
                  return GestureDetector(
                    onTap: () => setState(() {
                      selected ? _selectedAmenities.remove(amenity) : _selectedAmenities.add(amenity);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.navy800 : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: selected ? AppColors.navy800 : AppColors.borderSubtle),
                      ),
                      child: Text(
                        amenity,
                        style: AppTypography.bodyS.copyWith(
                          color: selected ? AppColors.textOnDark : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel('PRICING & AVAILABILITY'),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'MONTHLY PRICE (₱)',
                      hint: '2500',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppTextField(
                      label: 'AVAILABLE ROOMS',
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.l),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(_error!, style: AppTypography.bodyS.copyWith(color: AppColors.danger)),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Save property',
                onPressed: _loading ? null : _submit,
                loading: _loading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppColors.gold500),
        const SizedBox(width: AppSpacing.s),
        Text(text, style: AppTypography.label),
      ],
    );
  }
}
