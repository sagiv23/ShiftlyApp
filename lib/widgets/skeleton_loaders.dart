import 'package:flutter/material.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shimmer/shimmer.dart';

/// A theme-aware shimmer wrapper that automatically adapts to light and dark themes.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Generic skeleton container with standard border radius.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.radiusSm,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton loader matching [ShiftTile]
class ShiftTileSkeleton extends StatelessWidget {
  const ShiftTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 48, height: 48, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 110, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: 160, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(width: 60, height: 20),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader matching [GrandTotalCard]
class GrandTotalCardSkeleton extends StatelessWidget {
  const GrandTotalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppTheme.spaceMd,
          top: AppTheme.spaceXs,
        ),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          children: const [
            SkeletonBox(width: 120, height: 14),
            SizedBox(height: 12),
            SkeletonBox(width: 180, height: 38, borderRadius: 8),
            SizedBox(height: 16),
            SkeletonBox(
              width: double.infinity,
              height: 50,
              borderRadius: AppTheme.radiusMd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader matching a single KPI Card
class KpiCardSkeleton extends StatelessWidget {
  const KpiCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 70, height: 12),
                SkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
            SkeletonBox(width: 90, height: 22),
            SkeletonBox(width: 100, height: 10),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid matching KPI cards layout
class KpiGridSkeleton extends StatelessWidget {
  const KpiGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spaceSm,
          crossAxisSpacing: AppTheme.spaceSm,
          childAspectRatio: constraints.maxWidth > 700 ? 1.5 : 1.15,
          children: const [
            KpiCardSkeleton(),
            KpiCardSkeleton(),
            KpiCardSkeleton(),
            KpiCardSkeleton(),
          ],
        );
      },
    );
  }
}

/// Skeleton loader matching [TableCalendar]
class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 24, height: 24, borderRadius: 12),
                SkeletonBox(width: 140, height: 20),
                SkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) => const SkeletonBox(width: 28, height: 12),
              ),
            ),
            const SizedBox(height: 16),
            for (int r = 0; r < 5; r++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) => const SkeletonBox(
                      width: 32,
                      height: 32,
                      borderRadius: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader matching [ExpenseTile]
class ExpenseTileSkeleton extends StatelessWidget {
  const ExpenseTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 40, height: 40, borderRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(width: 50, height: 18),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for chart card
class ChartSkeleton extends StatelessWidget {
  final double height;

  const ChartSkeleton({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 140, height: 16),
            const SizedBox(height: 6),
            const SkeletonBox(width: 200, height: 10),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                6,
                (index) => SkeletonBox(
                  width: 24,
                  height: 40.0 + (index * 15 % 70),
                  borderRadius: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full screen skeleton for HomeScreen
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 2,
      title: 'Shiftly',
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: AppTheme.spaceXs,
        ),
        children: const [
          GrandTotalCardSkeleton(),
          ShiftTileSkeleton(),
          ShiftTileSkeleton(),
          ShiftTileSkeleton(),
        ],
      ),
    );
  }
}

/// Full screen skeleton for AnalyticsScreen
class AnalyticsScreenSkeleton extends StatelessWidget {
  const AnalyticsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 1,
      title: '',
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: AppTheme.spaceXs,
        ),
        children: const [
          SkeletonBox(
            width: double.infinity,
            height: 50,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceSm),
          KpiGridSkeleton(),
          SizedBox(height: AppTheme.spaceMd),
          ChartSkeleton(height: 220),
          SizedBox(height: AppTheme.spaceSm),
          ChartSkeleton(height: 200),
        ],
      ),
    );
  }
}

/// Full screen skeleton for CalendarScreen
class CalendarScreenSkeleton extends StatelessWidget {
  const CalendarScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 0,
      title: '',
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        children: const [
          CalendarSkeleton(),
          SizedBox(height: AppTheme.spaceSm),
          ShiftTileSkeleton(),
          ShiftTileSkeleton(),
        ],
      ),
    );
  }
}

/// Full screen skeleton for ExpensesScreen
class ExpensesScreenSkeleton extends StatelessWidget {
  const ExpensesScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 3,
      title: '',
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        children: const [
          SkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceSm),
          ExpenseTileSkeleton(),
          ExpenseTileSkeleton(),
          ExpenseTileSkeleton(),
        ],
      ),
    );
  }
}

/// Full screen skeleton for ProfileScreen
class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        children: const [
          SkeletonBox(
            width: double.infinity,
            height: 120,
            borderRadius: AppTheme.radiusLg,
          ),
          SizedBox(height: AppTheme.spaceMd),
          SkeletonBox(
            width: double.infinity,
            height: 80,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceSm),
          SkeletonBox(
            width: double.infinity,
            height: 80,
            borderRadius: AppTheme.radiusMd,
          ),
        ],
      ),
    );
  }
}

/// Full screen skeleton for SettingsScreen
class SettingsScreenSkeleton extends StatelessWidget {
  const SettingsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 5,
      title: '',
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        children: const [
          SkeletonBox(
            width: double.infinity,
            height: 70,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceMd),
          SkeletonBox(
            width: double.infinity,
            height: 140,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceMd),
          SkeletonBox(
            width: double.infinity,
            height: 100,
            borderRadius: AppTheme.radiusMd,
          ),
        ],
      ),
    );
  }
}

/// Full screen skeleton for ShiftDescriptionsScreen
class ShiftDescriptionsScreenSkeleton extends StatelessWidget {
  const ShiftDescriptionsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: 4,
      title: '',
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        children: const [
          SkeletonBox(
            width: double.infinity,
            height: 50,
            borderRadius: AppTheme.radiusMd,
          ),
          SizedBox(height: AppTheme.spaceSm),
          ShiftTileSkeleton(),
          ShiftTileSkeleton(),
          ShiftTileSkeleton(),
        ],
      ),
    );
  }
}
