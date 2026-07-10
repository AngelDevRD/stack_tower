import 'package:flutter/material.dart';

/// A single static block rendered at its world-space position.
class TowerBlockWidget extends StatelessWidget {
  final double left;
  final double width;
  final double top;
  final double blockHeight;
  final Color color;
  final bool highlight;

  const TowerBlockWidget({
    super.key,
    required this.left,
    required this.width,
    required this.top,
    required this.blockHeight,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: blockHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: highlight ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.8),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
