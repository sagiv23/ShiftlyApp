import 'package:flutter/material.dart';

/// A lightweight widget that provides subtle fade entrance when needed, respecting accessibility and route transitions.
class PageEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final double delayFraction;

  const PageEntranceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
    this.beginOffset = const Offset(0, 0.03),
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
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final start = widget.delayFraction.clamp(0.0, 0.5);
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
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
