import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/tenant_repository.dart';
import '../models/tenant_models.dart';
import '../property_details/property_details_screen.dart';
import '../widgets/tenant_header_widgets.dart';
import '../widgets/tenant_property_widgets.dart';
import '../widgets/tenant_reservation_widgets.dart';

/// Home tab content — greeting, location, AI match hero, reservation +
/// rent side-by-side, nearby discovery row, map teaser.
///
/// Data comes from [TenantRepository] (Cloud Firestore). Favorites are
/// read/written straight to Firestore (users/{uid}/favorites) so the
/// heart state is consistent across Home, Explore, and the dedicated
/// Favorites screen — no more locally-scoped favorite sets per screen.
class TenantHomeTab extends StatelessWidget {
  const TenantHomeTab({
    super.key,
    required this.tenantId,
    required this.tenantFirstName,
    this.tenantBudget = 3000,
    this.onNotificationsTap,
    this.onSeeAllNearby,
    this.onExploreMap,

    // FIX:
    // Added missing callback.
    this.onViewStay,
  });

  final String tenantId;
  final String tenantFirstName;
  final int tenantBudget;

  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSeeAllNearby;
  final VoidCallback? onExploreMap;

  // FIX:
  // Callback for the "View stay" button.
  final VoidCallback? onViewStay;

  void _openDetails(
      BuildContext context,
      Property p,
      Set<String> favorites,
      TenantRepository repo,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsScreen(
          property: p,
          tenantId: tenantId,
          isFavorite:
          favorites.contains(p.id),
          onFavoriteTap: () =>
              repo.setFavorite(
                tenantId,
                p.id,
                !favorites.contains(p.id),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = TenantRepository();

    return RefreshIndicator(
      onRefresh: () async {},
      child: StreamBuilder<Set<String>>(
        stream:
        repo.watchFavoriteIds(tenantId),
        builder: (context, favSnap) {
          final favorites =
              favSnap.data ?? {};

          return ListView(
            padding:
            const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.xl,
            ),
            children: [
              StreamBuilder<
                  List<TenantNotification>>(
                stream:
                repo.watchNotifications(
                  tenantId,
                ),
                builder:
                    (context, snap) =>
                    GreetingHeader(
                      firstName:
                      tenantFirstName,
                      notificationCount:
                      snap.data?.length ?? 0,
                      onNotificationsTap:
                      onNotificationsTap,
                    ),
              ),

              const SizedBox(
                height: AppSpacing.l,
              ),

              const LocationSelector(
                currentLabel:
                'BISU Candijay',
                onTap: null,
              ),

              const SizedBox(
                height: AppSpacing.l,
              ),

              FutureBuilder<
                  MatchRecommendation?>(
                future:
                repo.fetchTopMatch(
                  tenantBudget:
                  tenantBudget,
                ),
                builder:
                    (context, snap) {
                  if (!snap.hasData ||
                      snap.data == null) {
                    return const SizedBox
                        .shrink();
                  }

                  final match =
                  snap.data!;

                  return StayEaseMatchHeroCard(
                    match: match,
                    isFavorite:
                    favorites.contains(
                      match.property.id,
                    ),
                    onFavoriteTap: () =>
                        repo.setFavorite(
                          tenantId,
                          match.property.id,
                          !favorites.contains(
                            match.property.id,
                          ),
                        ),
                    onTap: () =>
                        _openDetails(
                          context,
                          match.property,
                          favorites,
                          repo,
                        ),
                  );
                },
              ),

              const SizedBox(
                height: AppSpacing.l,
              ),

              StreamBuilder<
                  ActiveReservation?>(
                stream:
                repo.watchActiveReservation(
                  tenantId,
                ),
                builder:
                    (context, reservationSnap) {
                  return StreamBuilder<
                      RentStatus?>(
                    stream:
                    repo.watchRentStatus(
                      tenantId,
                    ),
                    builder:
                        (context, rentSnap) {
                      final reservation =
                          reservationSnap.data;

                      final rent =
                          rentSnap.data;

                      if (reservation ==
                          null &&
                          rent == null) {
                        return const SizedBox
                            .shrink();
                      }

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                          children: [
                            if (reservation !=
                                null)
                              Expanded(
                                child:
                                ReservationCard(
                                  reservation:
                                  reservation,

                                  // FIX:
                                  // Previously:
                                  // onViewStay: () {},
                                  //
                                  // Now it uses the callback
                                  // from TenantDashboardScreen.
                                  onViewStay:
                                  onViewStay,

                                  onNavigate: () {},
                                ),
                              ),

                            if (reservation !=
                                null &&
                                rent != null)
                              const SizedBox(
                                width:
                                AppSpacing.m,
                              ),

                            if (rent != null)
                              Expanded(
                                child:
                                PaymentSummary(
                                  rentStatus:
                                  rent,
                                  onTap: () {},
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              SectionHeader(
                title:
                'Places around you',
                actionLabel: 'See all',
                onActionTap:
                onSeeAllNearby,
              ),

              const SizedBox(
                height: AppSpacing.m,
              ),

              StreamBuilder<
                  List<Property>>(
                stream:
                repo.watchNearbyProperties(
                  limit: 5,
                ),
                builder:
                    (context, snap) {
                  if (snap.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 224,
                      child: Center(
                        child:
                        CircularProgressIndicator(),
                      ),
                    );
                  }

                  final properties =
                      snap.data ?? const [];

                  if (properties.isEmpty) {
                    return const TenantEmptyState(
                      icon: Icons
                          .home_work_outlined,
                      title:
                      'No places nearby yet.',
                      message:
                      'Widen your search area to see more boarding houses.',
                    );
                  }

                  return SizedBox(
                    height: 224,
                    child:
                    ListView.separated(
                      scrollDirection:
                      Axis.horizontal,
                      itemCount:
                      properties.length,
                      separatorBuilder:
                          (_, __) =>
                      const SizedBox(
                        width:
                        AppSpacing.m,
                      ),
                      itemBuilder:
                          (context, i) {
                        final p =
                        properties[i];

                        return PropertyCompactCard(
                          property: p,
                          isFavorite:
                          favorites.contains(
                            p.id,
                          ),
                          onFavoriteTap: () =>
                              repo.setFavorite(
                                tenantId,
                                p.id,
                                !favorites.contains(
                                  p.id,
                                ),
                              ),
                          onTap: () =>
                              _openDetails(
                                context,
                                p,
                                favorites,
                                repo,
                              ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              StreamBuilder<
                  List<Property>>(
                stream:
                repo.watchAllProperties(),
                builder:
                    (context, snap) =>
                    ExploreMapPreview(
                      nearbyCount:
                      snap.data?.length ?? 0,
                      onExploreTap:
                      onExploreMap,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}