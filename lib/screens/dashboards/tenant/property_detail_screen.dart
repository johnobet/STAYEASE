import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/match/match_ring.dart';
import '../../../models/ai_preferences.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../services/ai_match_service.dart';
import '../../../services/reservation_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    super.key,
    required this.property,
    required this.user,
    this.aiPreferences,
    this.matchResult,
  });
  final PropertyModel property;
  final UserModel user;
  final AIPreferences? aiPreferences;
  final MatchScoreResult? matchResult;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _reservationService = ReservationService();
  final _aiMatchService = AIMatchService();
  bool _reserving = false;

  Future<void> _reserve() async {
    final property = widget.property;

    if (property.availableRooms <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This property has no rooms available right now.')),
      );
      return;
    }

    final alreadyReserved = await _reservationService.hasActiveReservation(
      tenantId: widget.user.uid,
      propertyId: property.id,
    );
    if (!mounted) return;
    if (alreadyReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have an active reservation for this property.')),
      );
      return;
    }

    final checkInDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      helpText: 'Select move-in date',
    );
    if (checkInDate == null || !mounted) return;

    setState(() => _reserving = true);
    try {
      await _reservationService.createReservation(
        tenantId: widget.user.uid,
        tenantName: widget.user.name,
        property: property,
        checkInDate: checkInDate,
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.s),
              const Text('Request sent'),
            ],
          ),
          content: Text(
            'Your reservation request for ${property.name} has been sent to the owner. '
                "You'll be notified once it's approved.",
            style: AppTypography.bodyM,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Reservation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send your reservation. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.navy100,
      alignment: Alignment.center,
      child: Icon(Icons.home_rounded, color: AppColors.navy500.withOpacity(0.35), size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final imageUrl = property.gallery.isNotEmpty ? property.gallery.first : property.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _imageFallback(),
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(property.name, style: AppTypography.headingL)),
                        if (property.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navy100,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 13, color: AppColors.navy800),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.navy800),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold600),
                        const SizedBox(width: 4),
                        Text(
                          '${property.rating.toStringAsFixed(1)} (${property.reviewCount} reviews)',
                          style: AppTypography.bodyM,
                        ),
                        if (property.distanceMeters != null) ...[
                          const SizedBox(width: AppSpacing.m),
                          Icon(Icons.route_rounded, size: 15, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text('${property.distanceMeters}m away', style: AppTypography.bodyM),
                        ],
                      ],
                    ),
                    if (property.ownerName.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text('Hosted by ${property.ownerName}', style: AppTypography.bodyS),
                    ],
                    if (widget.matchResult != null && widget.aiPreferences != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _AIMatchCard(
                        property: property,
                        result: widget.matchResult!,
                        explanation:
                        _aiMatchService.explain(property, widget.aiPreferences!, widget.matchResult!),
                      ),
                    ],
                    const Divider(height: AppSpacing.xxl),
                    Text('About this place', style: AppTypography.headingS),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      property.description.isNotEmpty ? property.description : 'No description provided yet.',
                      style: AppTypography.bodyL,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (property.address.isNotEmpty) ...[
                      Text('Location', style: AppTypography.headingS),
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          Icon(Icons.place_rounded, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(child: Text(property.address, style: AppTypography.bodyM)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (property.amenities.isNotEmpty) ...[
                      Text('Amenities', style: AppTypography.headingS),
                      const SizedBox(height: AppSpacing.m),
                      Wrap(
                        spacing: AppSpacing.s,
                        runSpacing: AppSpacing.s,
                        children: property.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(amenity, style: AppTypography.bodyS),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    Row(
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          property.availableRooms > 0
                              ? '${property.availableRooms} room(s) available'
                              : 'No rooms available right now',
                          style: AppTypography.bodyM.copyWith(
                            color: property.availableRooms > 0 ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₱${property.pricePerMonth.toStringAsFixed(0)}',
                          style: AppTypography.monoL.copyWith(color: AppColors.navy800),
                        ),
                        const SizedBox(width: 4),
                        Text('/mo', style: AppTypography.bodyS),
                      ],
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Reserve',
                onPressed: _reserving ? null : _reserve,
                loading: _reserving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AIMatchCard extends StatelessWidget {
  const _AIMatchCard({required this.property, required this.result, required this.explanation});
  final PropertyModel property;
  final MatchScoreResult result;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.gold100,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gold200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatchRing(percent: result.percent, size: 72, label: 'MATCH'),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.gold600),
                        const SizedBox(width: AppSpacing.xs),
                        Text('AI RECOMMENDATION', style: AppTypography.label.copyWith(color: AppColors.gold600)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _breakdownRow('Budget', result.budgetScore),
                    _breakdownRow('Distance', result.distanceScore),
                    _breakdownRow('Amenities', result.amenitiesScore),
                    _breakdownRow('Rating', result.ratingScore),
                    _breakdownRow('Availability', result.availabilityScore),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(explanation, style: AppTypography.bodyS.copyWith(color: AppColors.navy800)),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(width: 78, child: Text(label, style: AppTypography.bodyS)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 5,
                backgroundColor: AppColors.gold200,
                valueColor: const AlwaysStoppedAnimation(AppColors.navy800),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          SizedBox(
            width: 30,
            child: Text('$value%', style: AppTypography.mono.copyWith(fontSize: 11), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}