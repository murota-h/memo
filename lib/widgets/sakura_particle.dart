import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Particle {
  final double x;
  final double startOffset;
  final double size;
  final double speed;
  final double phase;
  final double sway;

  const _Particle({
    required this.x,
    required this.startOffset,
    required this.size,
    required this.speed,
    required this.phase,
    required this.sway,
  });
}

class SakuraParticlePainter extends CustomPainter {
  final double progress;

  static final _random = Random(42);
  static final _particles = List<_Particle>.generate(14, (i) {
    final r = _random;
    return _Particle(
      x: r.nextDouble(),
      startOffset: r.nextDouble(),
      size: r.nextDouble() * 9 + 4,
      speed: r.nextDouble() * 0.25 + 0.12,
      phase: r.nextDouble() * pi * 2,
      sway: r.nextDouble() * 0.06 + 0.02,
    );
  });

  SakuraParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.startOffset) % 1.0;
      final x =
          (p.x + sin(t * pi * 4 + p.phase) * p.sway) * size.width;
      final y = t * (size.height + p.size * 2) - p.size;

      _drawPetal(canvas, Offset(x, y), p.size, t * pi * 6 + p.phase);
    }
  }

  void _drawPetal(
      Canvas canvas, Offset center, double size, double rotation) {
    final paint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path();
    path.moveTo(0, -size);
    path.cubicTo(size * 0.7, -size * 0.8, size * 0.9, -size * 0.1, 0, 0);
    path.cubicTo(-size * 0.9, -size * 0.1, -size * 0.7, -size * 0.8, 0, -size);

    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SakuraParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
