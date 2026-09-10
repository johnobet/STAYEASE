import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// StayEase's signature component.
///
/// Every recommendation score in the product ("94% Match") is shown as a
/// radial gauge rather than a plain number or a generic Material
/// `CircularProgressIndicator` — this is the one visual element that should
/// be instantly recognizable as "StayEase AI" wherever it appears (property
/// cards, the AI assistant, owner insights).
///
/// The ring animates in from 0 → value on first build, and the arc is
/// slightly rounded and inset from a full circle (270° sweep) so it reads
/// as a dial, not a loading spinner.
class MatchRing extends StatefulWidget {
  const MatchRing({
    super.key,
    required this.percent,
    this.size = 84,
    this.label = 'MATCH',
    this.strokeWidth = 7,
  });

  /// 0–100
  final int percent;
  final double size;
  final String label;
  final double strokeWidth;

  @override
  State<MatchRing> createState() => _MatchRingState();
}

class _MatchRingState extends State<MatchRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0, end: widget.percent / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _MatchRingPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_animation.value * 100).round()}%',
                    style: AppTypography.headingM.copyWith(fontSize: widget.size * 0.24),
                  ),
                  Text(
                    widget.label,
                    style: AppTypography.label.copyWith(
                      fontSize: widget.size * 0.09,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MatchRingPainter extends CustomPainter {
  _MatchRingPainter({required this.progress, required this.strokeWidth});

  final double progress; // 0..1
  final double strokeWidth;

  static const double _startAngle = -math.pi / 2 - (math.pi * 0.15);
  static const double _sweepTotal = math.pi * 1.8; // ~324° dial, not a full circle

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = AppColors.navy100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: _sweepTotal,
        colors: const [AppColors.navy700, AppColors.gold500],
        transform: GradientRotation(_startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepTotal,
      false,
      track,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepTotal * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _MatchRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
