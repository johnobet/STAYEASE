import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/media/safe_network_image.dart';
import '../../messaging/chat/chat_screen.dart';
import '../../messaging/data/messaging_repository.dart';
import '../data/tenant_repository.dart';
import '../models/tenant_models.dart';
import '../widgets/tenant_property_widgets.dart' show VerificationBadge;

/// Full property page — opened from any property card across the app
/// (Home hero, nearby row, Explore list). Gallery up top, sticky
/// Reserve action at the bottom so it's always reachable while scrolling.
class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.tenantId,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final Property property;
  final String tenantId;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _pageController = PageController();
  final _repo = TenantRepository();
  final _messagingRepo = MessagingRepository();
  int _photoIndex = 0;
  late bool _favorite = widget.isFavorite;
  bool _reserving = false;
  bool _reserved = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openChat(Property p) async {
    if (p.ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This listing has no owner account to message yet.')),
      );
      return;
    }
    try {
      final threadId = await _messagingRepo.getOrCreateThread(
        tenantId: widget.tenantId,
        ownerId: p.ownerId,
        propertyName: p.name,
        propertyImageUrl: p.imageUrl,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(threadId: threadId, currentUserId: widget.tenantId, title: 'Owner · ${p.name}'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: $e'), duration: const Duration(seconds: 6)),
        );
      }
    }
  }

  Future<void> _startReservation() async {
    final roomLabel = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (sheetContext) => _ReserveSheet(propertyName: widget.property.name),
    );
    if (roomLabel == null || roomLabel.isEmpty) return; // sheet dismissed

    setState(() => _reserving = true);
    try {
      await _repo.createReservation(
        tenantId: widget.tenantId,
        property: widget.property,
        roomLabel: roomLabel,
        checkInDate: DateTime.now().add(const Duration(days: 3)),
      );
      if (mounted) {
        setState(() => _reserved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation request sent. The owner will confirm shortly.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reserve: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final photos = p.allPhotos;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: photos.length,
                        onPageChanged: (i) => setState(() => _photoIndex = i),
                        itemBuilder: (context, i) => SafeNetworkImage(url: photos[i], fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: AppSpacing.m,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(photos.length, (i) {
                            final active = i == _photoIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: active ? 16 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(p.name, style: AppTypography.headingL)),
                          if (p.isVerified) const VerificationBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 15, color: AppColors.textTertiary),
                          Text(p.formattedDistance, style: AppTypography.bodyS),
                          const SizedBox(width: AppSpacing.m),
                          const Icon(Icons.star_rounded, color: AppColors.gold500, size: 15),
                          Text(' ${p.rating}', style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600)),
                          Text(' (${p.reviewCount} reviews)', style: AppTypography.bodyS),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(p.formattedPrice, style: AppTypography.displayL.copyWith(fontSize: 26, color: AppColors.terracotta600)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(' / month', style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
                          ),
                          const Spacer(),
                          Text(
                            p.availableRooms > 0 ? '${p.availableRooms} room${p.availableRooms > 1 ? 's' : ''} available' : 'Fully booked',
                            style: AppTypography.bodyS.copyWith(
                              color: p.availableRooms > 0 ? AppColors.sage600 : AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xxl, color: AppColors.borderSubtle),

                      Text('ABOUT THIS PLACE', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.s),
                      Text(p.description.isNotEmpty ? p.description : 'No description provided yet.', style: AppTypography.bodyM),
                      const SizedBox(height: AppSpacing.xl),

                      if (p.amenities.isNotEmpty) ...[
                        Text('AMENITIES', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: p.amenities.map((a) => _AmenityChip(label: a)).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      if (p.ownerName.isNotEmpty) ...[
                        Text('HOSTED BY', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.sage100,
                              child: Text(
                                p.ownerName.isNotEmpty ? p.ownerName[0].toUpperCase() : '?',
                                style: AppTypography.headingS.copyWith(color: AppColors.sage800),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.ownerName, style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700)),
                                  Text('Property owner', style: AppTypography.bodyS),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => _openChat(p),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.borderStrong),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                              ),
                              child: Text('Message', style: AppTypography.bodyS.copyWith(color: AppColors.sage800, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top bar over the gallery — back + favorite, floating.
          Positioned(
            top: AppSpacing.m,
            left: AppSpacing.l,
            right: AppSpacing.l,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop()),
                  _CircleIconButton(
                    icon: _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _favorite ? AppColors.terracotta600 : AppColors.sage800,
                    onTap: () {
                      setState(() => _favorite = !_favorite);
                      widget.onFavoriteTap?.call();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sticky reserve bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: AppShadows.raised,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.formattedPrice, style: AppTypography.headingM.copyWith(color: AppColors.terracotta600)),
                          Text('/ month', style: AppTypography.bodyS),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: AppButton(
                        label: _reserved
                            ? 'Requested'
                            : (p.availableRooms > 0 ? 'Reserve' : 'Join waitlist'),
                        onPressed: (_reserved || p.availableRooms == 0) ? null : _startReservation,
                        loading: _reserving,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(color: AppColors.sage100, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: AppTypography.bodyS.copyWith(color: AppColors.sage800, fontWeight: FontWeight.w600)),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.card),
        child: Icon(icon, color: iconColor ?? AppColors.sage800, size: 20),
      ),
    );
  }
}

/// Minimal reservation intake — just enough to create the Firestore
/// reservation doc. Owner approval flow (item 44) is what turns this
/// from "pending" into "active"; this sheet doesn't need to collect
/// more than a room preference for now.
class _ReserveSheet extends StatefulWidget {
  const _ReserveSheet({required this.propertyName});
  final String propertyName;

  @override
  State<_ReserveSheet> createState() => _ReserveSheetState();
}

class _ReserveSheetState extends State<_ReserveSheet> {
  final _controller = TextEditingController(text: 'Any available room');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserve at ${widget.propertyName}', style: AppTypography.headingM),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This sends a reservation request to the owner. They\'ll confirm your room and move-in date.',
            style: AppTypography.bodyS,
          ),
          const SizedBox(height: AppSpacing.l),
          Text('ROOM PREFERENCE', style: AppTypography.label),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _controller,
            style: AppTypography.bodyM,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceSunken,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: 'Send request',
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(_controller.text.trim().isEmpty ? 'Any available room' : _controller.text.trim()),
          ),
        ],
      ),
    );
  }
}
