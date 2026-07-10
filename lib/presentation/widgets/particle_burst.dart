import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One-shot particle burst at a world position. Removes itself via [onComplete].
class ParticleBurst extends StatefulWidget {
  final Offset center;
  final Color color;
  final bool big;
  final VoidCallback onComplete;

  const ParticleBurst({
    super.key,
    required this.center,
    required this.color,
    required this.onComplete,
    this.big = false,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Offset> _directions;

  @override
  void initState() {
    super.initState();
    final count = widget.big ? 16 : 8;
    final rand = math.Random();
    _directions = List.generate(count, (i) {
      final angle = (2 * math.pi / count) * i + rand.nextDouble() * 0.4;
      return Offset(math.cos(angle), math.sin(angle));
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            center: widget.center,
            directions: _directions,
            progress: _controller.value,
            color: widget.color,
            distance: widget.big ? 60 : 36,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final Offset center;
  final List<Offset> directions;
  final double progress;
  final Color color;
  final double distance;

  _ParticlePainter({
    required this.center,
    required this.directions,
    required this.progress,
    required this.color,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
    final radius = 3.0 * (1 - progress * 0.5);
    for (final dir in directions) {
      final pos = center + dir * (distance * progress);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
