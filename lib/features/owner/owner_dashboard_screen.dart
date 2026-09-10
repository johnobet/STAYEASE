import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../messaging/threads/messages_screen.dart';
import 'properties/owner_properties_screen.dart';
import 'requests/owner_requests_screen.dart';

/// Owner Dashboard shell — 3-tab layout (My Properties, Reservation
/// Requests, Messages). Uses navy/gold, matching the design system's
/// split (sage/terracotta is tenant-only).
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key, required this.ownerId, required this.ownerName});
  final String ownerId;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('StayEase Owner', style: AppTypography.headingM.copyWith(color: AppColors.navy800)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.navy800),
              onPressed: () => AuthService().signOut(),
              tooltip: 'Sign out',
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.navy800,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.gold500,
            indicatorWeight: 3,
            labelStyle: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'My Properties'),
              Tab(text: 'Requests'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OwnerPropertiesScreen(ownerId: ownerId, ownerName: ownerName),
            OwnerRequestsScreen(ownerId: ownerId),
            MessagesScreen(currentUserId: ownerId),
          ],
        ),
      ),
    );
  }
}
