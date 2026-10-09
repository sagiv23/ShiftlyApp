import 'package:flutter/material.dart';

/// A reusable widget that provides smooth staggered fade + slide entrance animations.
class PageEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final double delayFraction;

  const PageEntranceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 650),
    this.beginOffset = const Offset(0, 0.08),
    this.delayFraction = 0.0,
  });

  @override
  State<PageEntranceAnimation> createState() => _PageEntranceAnimationState();
}

class _PageEntranceAnimationState extends State<PageEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final start = widget.delayFraction.clamp(0.0, 0.8);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curve);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
