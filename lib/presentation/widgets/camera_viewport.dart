import 'package:flutter/material.dart';

/// Smoothly animates its child's vertical world offset so the active stacking
/// position stays in view as the tower grows past the visible screen height.
class CameraViewport extends StatefulWidget {
  final double targetOffset;
  final Widget child;

  const CameraViewport({
    super.key,
    required this.targetOffset,
    required this.child,
  });

  @override
  State<CameraViewport> createState() => _CameraViewportState();
}

class _CameraViewportState extends State<CameraViewport>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = AlwaysStoppedAnimation(_current);
  }

  @override
  void didUpdateWidget(covariant CameraViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetOffset != widget.targetOffset) {
      _animateTo(widget.targetOffset);
    }
  }

  void _animateTo(double target) {
    _animation =
        Tween<double>(begin: _current, end: target).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        )..addListener(() {
          setState(() => _current = _animation.value);
        });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, _current),
        child: widget.child,
      ),
    );
  }
}
