import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../dev/seed_firestore.dart';

import 'bookings/bookings_screen.dart';
import 'data/tenant_repository.dart';
import 'explore/explore_screen.dart';
import 'favorites/favorites_screen.dart';
import 'home/tenant_home_tab.dart';
import '../messaging/threads/messages_screen.dart';

import 'widgets/tenant_property_widgets.dart';
import 'widgets/tenant_reservation_widgets.dart';

/// StayEase Tenant Dashboard shell.
///
/// Hosts the five tenant tabs:
/// Home, Explore, Bookings, Messages, Profile.
class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<TenantDashboardScreen> createState() =>
      _TenantDashboardScreenState();
}

class _TenantDashboardScreenState
    extends State<TenantDashboardScreen> {
  TenantNavTab _tab = TenantNavTab.home;

  final _repo = TenantRepository();

  void _goToExplore() {
    setState(() {
      _tab = TenantNavTab.explore;
    });
  }

  // FIX:
  // This is the callback used by the Home tab's
  // "View stay" button.
  void _goToBookings() {
    setState(() {
      _tab = TenantNavTab.bookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab.index,
          children: [
            TenantHomeTab(
              tenantId: widget.user.uid,
              tenantFirstName:
              widget.user.name.split(' ').first,

              onSeeAllNearby: _goToExplore,
              onExploreMap: _goToExplore,

              // FIX:
              // View Stay -> Bookings tab
              onViewStay: _goToBookings,
            ),

            ExploreScreen(
              tenantId: widget.user.uid,
            ),

            BookingsScreen(
              tenantId: widget.user.uid,
            ),

            MessagesScreen(
              currentUserId: widget.user.uid,
            ),

            _ProfileTab(
              user: widget.user,
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      StreamBuilder<List<dynamic>>(
        stream: _repo.watchNotifications(
          widget.user.uid,
        ),
        builder: (context, snap) {
          return TenantBottomNav(
            current: _tab,
            onChanged: (tab) {
              setState(() {
                _tab = tab;
              });
            },
            messageBadgeCount:
            snap.data?.length ?? 0,
          );
        },
      ),
    );
  }
}

// ============================================================================
// PROFILE TAB
// ============================================================================

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({
    required this.user,
  });

  final UserModel user;

  @override
  State<_ProfileTab> createState() =>
      _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _seeding = false;

  Future<void> _runSeed() async {
    setState(() {
      _seeding = true;
    });

    try {
      await seedSampleProperties();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sample properties added to Firestore.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Seed failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _seeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Padding(
      padding: const EdgeInsets.all(
        AppSpacing.l,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: AppTypography.displayL.copyWith(
              fontSize: 26,
            ),
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                AppColors.sage100,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style:
                  AppTypography.headingL.copyWith(
                    color: AppColors.sage800,
                  ),
                ),
              ),

              const SizedBox(
                width: AppSpacing.m,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style:
                      AppTypography.headingS,
                    ),
                    Text(
                      user.email,
                      style:
                      AppTypography.bodyS,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          _ProfileListTile(
            icon:
            Icons.favorite_border_rounded,
            label: 'Saved places',
            onTap: () =>
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FavoritesScreen(
                          tenantId: user.uid,
                        ),
                  ),
                ),
          ),

          const SizedBox(
            height: AppSpacing.xxl,
          ),

          if (kDebugMode) ...[
            AppButton(
              label: _seeding
                  ? 'Seeding...'
                  : 'Seed sample properties (dev)',
              variant:
              AppButtonVariant.secondary,
              onPressed:
              _seeding ? null : _runSeed,
              fullWidth: true,
            ),

            const SizedBox(
              height: AppSpacing.s,
            ),

            Text(
              'Debug-only — populates Firestore with '
                  '8 sample listings. Remove before release.',
              style:
              AppTypography.bodyS.copyWith(
                color:
                AppColors.textTertiary,
              ),
            ),
          ],

          const SizedBox(height: 12),

          const Spacer(),

          AppButton(
            label: 'Sign out',
            variant:
            AppButtonVariant.secondary,
            onPressed: () =>
                AuthService().signOut(),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROFILE LIST TILE
// ============================================================================

class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.circular(
            AppRadius.md,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.sage800,
            ),

            const SizedBox(
              width: AppSpacing.m,
            ),

            Expanded(
              child: Text(
                label,
                style:
                AppTypography.bodyM.copyWith(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color:
              AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}