import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Semicircular tick gauge (as in the reference Speed screen).
/// Filled ticks up to [value]/[max]; a needle points at the value.
class SpeedGauge extends StatelessWidget {
  const SpeedGauge({
    super.key,
    required this.value,
    this.max = 100,
    this.unit = 'mbps',
  });

  final double value;
  final double max;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 168,
      child: CustomPaint(
        painter: _GaugePainter(value.clamp(0, max) / max),
        child: Align(
          alignment: const Alignment(0, 0.22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.fraction);
  final double fraction;

  static const int _tickCount = 44;
  static const double _startAngle = math.pi; // 180°
  static const double _sweep = math.pi; // half circle

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;

    final filledTicks = (fraction * _tickCount).round();

    for (int i = 0; i < _tickCount; i++) {
      final t = i / (_tickCount - 1);
      final angle = _startAngle + t * _sweep;
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 20) * math.cos(angle),
        center.dy + (radius - 20) * math.sin(angle),
      );
      final active = i <= filledTicks;
      tickPaint.color = active
          ? Color.lerp(AppColors.primary, AppColors.heroGlow, t)!
          : const Color(0xFFC9C9D6);
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Needle
    final needleAngle = _startAngle + fraction * _sweep;
    final needlePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final needleLen = radius - 92;
    final needleEnd = Offset(
      center.dx + needleLen * math.cos(needleAngle),
      center.dy + needleLen * math.sin(needleAngle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 7, Paint()..color = AppColors.textPrimary);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.fraction != fraction;
}
