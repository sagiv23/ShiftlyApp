import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable performant animation extensions for Shiftly using `flutter_animate`.
extension ShiftlyAnimationExtensions on Widget {
  /// Subtle fade in + slide up entrance animation for cards, items, and headers.
  Widget animateEntrance({
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 180),
    Duration delay = Duration.zero,
    double slideOffsetY = 0.03,
    double slideOffsetX = 0.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (context != null && MediaQuery.of(context).disableAnimations) {
      return this;
    }

    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slide(
          begin: Offset(slideOffsetX, slideOffsetY),
          end: Offset.zero,
          duration: duration,
          curve: curve,
        );
  }

  /// Subtle fade + scale entrance for dialogs, modals, and primary action FABs.
  Widget animateScaleEntrance({
    BuildContext? context,
    Duration duration = const Duration(milliseconds: 180),
    Duration delay = Duration.zero,
    double beginScale = 0.96,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (context != null && MediaQuery.of(context).disableAnimations) {
      return this;
    }

    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: curve,
        );
  }

  /// Staggered entrance helper for list items based on their index.
  Widget animateListItem({
    required int index,
    BuildContext? context,
    int maxStaggerCount = 5,
    Duration duration = const Duration(milliseconds: 180),
    Duration baseDelay = Duration.zero,
    Duration itemInterval = const Duration(milliseconds: 25),
  }) {
    if (context != null && MediaQuery.of(context).disableAnimations) {
      return this;
    }

    final effectiveIndex = index.clamp(0, maxStaggerCount);
    final delay = baseDelay + (itemInterval * effectiveIndex);

    return animateEntrance(
      context: context,
      duration: duration,
      delay: delay,
      slideOffsetY: 0.03,
    );
  }

  /// Subtle tactile press animation feedback helper for interactive cards.
  Widget animateCardClick({bool isPressed = false}) {
    return AnimatedScale(
      scale: isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: this,
    );
  }
}

/// Helper class for staggered animation lists in Shiftly screens.
class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemInterval;
  final Duration duration;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.itemInterval = const Duration(milliseconds: 25),
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++)
          children[i].animateListItem(
            index: i,
            context: context,
            itemInterval: itemInterval,
            duration: duration,
          ),
      ],
    );
  }
}
