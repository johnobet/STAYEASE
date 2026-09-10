import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/badges/connectivity_signal.dart';
import 'core/widgets/buttons/app_button.dart';
import 'core/widgets/cards/property_card.dart';
import 'core/widgets/inputs/app_text_field.dart';
import 'core/widgets/match/match_ring.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StayEaseApp());
}

class StayEaseApp extends StatelessWidget {
  const StayEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(),
      routes: {
        // Dev-only reference screen — not part of the real navigation flow.
        '/design-system': (context) => const DesignSystemScreen(),
      },
    );
  }
}

/// Temporary home screen — a living style guide. Once real screens exist
/// (Phase 4 onward), this becomes a dev-only route rather than the app's
/// entry screen.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StayEase — Design System')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.xxxl),
        children: [
          _SectionLabel('IDENTITY'),
          Text('StayEase', style: AppTypography.displayXL),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Find it. Decide with confidence. Book it. Pay it. Get there.',
            style: AppTypography.bodyL.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('COLOR'),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.m,
            runSpacing: AppSpacing.m,
            children: const [
              _Swatch('Navy 800', AppColors.navy800, dark: true),
              _Swatch('Navy 500', AppColors.navy500, dark: true),
              _Swatch('Gold 500', AppColors.gold500),
              _Swatch('Background', AppColors.background),
              _Swatch('Success', AppColors.success, dark: true),
              _Swatch('Warning', AppColors.warning, dark: true),
              _Swatch('Danger', AppColors.danger, dark: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('TYPE — SPACE GROTESK / INTER / JETBRAINS MONO'),
          const SizedBox(height: AppSpacing.m),
          Text('Heading L · Property title', style: AppTypography.headingL),
          Text('Heading M · Section header', style: AppTypography.headingM),
          Text('Body L · Primary reading text for descriptions', style: AppTypography.bodyL),
          Text('Body S · Secondary / metadata text', style: AppTypography.bodyS),
          Text('₱2,500 · ST-284719', style: AppTypography.monoL),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('SIGNATURE — MATCH RING'),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              MatchRing(percent: 94),
              MatchRing(percent: 72),
              MatchRing(percent: 38),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('CONNECTIVITY SIGNAL'),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: const [
              ConnectivitySignal(state: ConnectivityState.online),
              ConnectivitySignal(state: ConnectivityState.cached),
              ConnectivitySignal(state: ConnectivityState.offline),
              ConnectivitySignal(state: ConnectivityState.syncing),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('BUTTONS'),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.m,
            runSpacing: AppSpacing.m,
            children: [
              AppButton(label: 'Reserve room', onPressed: () {}, icon: Icons.bolt_rounded),
              AppButton(label: 'View details', onPressed: () {}, variant: AppButtonVariant.secondary),
              AppButton(label: 'Cancel', onPressed: () {}, variant: AppButtonVariant.ghost),
              AppButton(label: 'Remove listing', onPressed: () {}, variant: AppButtonVariant.danger),
              const AppButton(label: 'Disabled', onPressed: null),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('INPUT'),
          const SizedBox(height: AppSpacing.m),
          const AppTextField(
            label: 'LOCATION',
            hint: 'Near BISU Candijay',
            prefixIcon: Icons.place_rounded,
          ),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('PROPERTY CARD'),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                PropertyCard(
                  name: "Maria's Boarding House",
                  priceLabel: '₱2,500',
                  distanceLabel: '650m · BISU',
                  rating: 4.8,
                  matchPercent: 94,
                  verified: true,
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.l),
                PropertyCard(
                  name: 'Casa Verde Dorm',
                  priceLabel: '₱1,900',
                  distanceLabel: '1.2km · City center',
                  rating: 4.3,
                  matchPercent: 78,
                  imageColor: AppColors.gold100,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
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

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, {this.dark = false});
  final String name;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 64,
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        name,
        style: AppTypography.bodyS.copyWith(
          color: dark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 11,
        ),
      ),
    );
  }
}