import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum ConnectivityState { online, cached, offline, syncing }

/// A small recurring status pill that tells the tenant what kind of data
/// they're looking at: live, cached-for-offline-use, or unavailable.
///
/// This exists because StayEase's core promise is "keep working with weak
/// signal" — so the app should always be honest about connectivity state,
/// rather than failing silently. Used on the map, navigation screen, and
/// property details.
class ConnectivitySignal extends StatefulWidget {
  const ConnectivitySignal({super.key, required this.state, this.label});

  final ConnectivityState state;
  final String? label;

  @override
  State<ConnectivitySignal> createState() => _ConnectivitySignalState();
}

class _ConnectivitySignalState extends State<ConnectivitySignal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.state) {
      case ConnectivityState.online:
        return AppColors.signalOnline;
      case ConnectivityState.cached:
        return AppColors.signalCached;
      case ConnectivityState.offline:
        return AppColors.signalOffline;
      case ConnectivityState.syncing:
        return AppColors.navy700;
    }
  }

  String get _defaultLabel {
    switch (widget.state) {
      case ConnectivityState.online:
        return 'Live';
      case ConnectivityState.cached:
        return 'Saved offline';
      case ConnectivityState.offline:
        return 'No signal · using cache';
      case ConnectivityState.syncing:
        return 'Syncing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPulse = widget.state == ConnectivityState.online ||
        widget.state == ConnectivityState.syncing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final scale = showPulse ? 1.0 + (_pulse.value * 0.5) : 1.0;
              final opacity = showPulse ? 1.0 - (_pulse.value * 0.4) : 1.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (showPulse)
                    Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: AppSpacing.s),
          Text(widget.label ?? _defaultLabel, style: AppTypography.bodyS.copyWith(height: 1)),
        ],
      ),
    );
  }
}
