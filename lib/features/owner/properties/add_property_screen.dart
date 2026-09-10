import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../data/owner_repository.dart';

/// Property creation form (item 32, tenant-facing counterpart to
/// property_details_screen.dart). Deliberately minimal for now — no
/// image upload flow yet (Cloud Storage isn't wired up), so the owner
/// pastes an image URL directly.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key, required this.ownerId, required this.ownerName});
  final String ownerId;
  final String ownerName;

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _repo = OwnerRepository();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  final _amenitiesController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _descriptionController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final name = _nameController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final rooms = int.tryParse(_roomsController.text.trim());

    if (name.isEmpty || imageUrl.isEmpty || price == null || rooms == null) {
      setState(() => _error = 'Please fill in name, image URL, price, and available rooms with valid values.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _repo.createProperty(
        ownerId: widget.ownerId,
        ownerName: widget.ownerName,
        name: name,
        imageUrl: imageUrl,
        pricePerMonth: price,
        availableRooms: rooms,
        description: _descriptionController.text.trim(),
        amenities: _amenitiesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add property', style: AppTypography.headingM), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'PROPERTY NAME', hint: "e.g. Maria's Boarding House", controller: _nameController),
              const SizedBox(height: AppSpacing.l),
              AppTextField(label: 'IMAGE URL', hint: 'https://...', controller: _imageUrlController),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Paste a direct image link for now (photo upload isn\'t wired up yet).',
                style: AppTypography.bodyS.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'PRICE / MONTH',
                      hint: '2500',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppTextField(
                      label: 'AVAILABLE ROOMS',
                      hint: '3',
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'DESCRIPTION',
                hint: 'Tell tenants about the place...',
                controller: _descriptionController,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextField(
                label: 'AMENITIES (comma-separated)',
                hint: 'Wi-Fi, Kitchen, CR per room',
                controller: _amenitiesController,
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.l),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Text(_error!, style: AppTypography.bodyS.copyWith(color: AppColors.danger)),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Publish listing', onPressed: _saving ? null : _submit, loading: _saving, fullWidth: true),
            ],
          ),
        ),
      ),
    );
  }
}
