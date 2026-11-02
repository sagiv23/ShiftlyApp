import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/analytics_charts.dart';

class AnalyticsSmartInsights extends StatelessWidget {
  final AppLocalizations l;
  final String symbol;
  final double retentionPct;
  final double rateBoost;
  final double totalTips;
  final double totalNet;
  final List<ShiftDurationCategory> durationCategories;
  final List<TimeOfDaySegment> todSegments;

  const AnalyticsSmartInsights({
    super.key,
    required this.l,
    required this.symbol,
    required this.retentionPct,
    required this.rateBoost,
    required this.totalTips,
    required this.totalNet,
    required this.durationCategories,
    required this.todSegments,
  });

  @override
  Widget build(BuildContext context) {
    final insights = <String>[];

    // Insight 1: Off-peak / Evening & Night hours ratio
    double totalTodHours = 0;
    for (var s in todSegments) {
      totalTodHours += s.hours;
    }
    if (totalTodHours > 0) {
      final offPeakHours = todSegments
          .where(
            (s) =>
                s.timeRange == '04:00-06:00' ||
                s.timeRange == '18:00-22:00' ||
                s.timeRange == '22:00-04:00' ||
                s.timeRange == '22:00-06:00',
          )
          .fold<double>(0, (sum, s) => sum + s.hours);
      final offPeakPct = (offPeakHours / totalTodHours * 100).round();
      if (offPeakPct > 20) {
        insights.add(
          l.analytics_insight_night_boost.replaceFirst(
            '[[percent]]',
            '$offPeakPct',
          ),
        );
      }
    }

    // Insight 2: Retention
    if (retentionPct < 100 && retentionPct > 0) {
      insights.add(
        l.analytics_insight_retention.replaceFirst(
          '[[percent]]',
          retentionPct.toStringAsFixed(1),
        ),
      );
    }

    // Insight 3: Long shift fatigue
    final longCategory = durationCategories.firstWhere(
      (c) => c.icon == Icons.warning_amber_rounded,
      orElse: () => const ShiftDurationCategory(
        label: '',
        durationRange: '',
        count: 0,
        hours: 0,
        avgEarnings: 0,
        color: Colors.transparent,
        icon: Icons.timer,
      ),
    );
    int totalCount = 0;
    for (var c in durationCategories) {
      totalCount += c.count;
    }
    if (totalCount > 0 && longCategory.count > 0) {
      final longPct = (longCategory.count / totalCount * 100).round();
      if (longPct >= 15) {
        insights.add(
          l.analytics_insight_fatigue.replaceFirst('[[percent]]', '$longPct'),
        );
      }
    }

    // Insight 4: Tips ratio
    if (totalNet > 0 && totalTips > 0) {
      final tipsPct = ((totalTips / totalNet) * 100).round();
      if (tipsPct > 5) {
        insights.add(
          l.analytics_insight_tips_ratio.replaceFirst(
            '[[percent]]',
            '$tipsPct',
          ),
        );
      }
    }

    if (insights.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(
          color: AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l.analytics_insights_title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppTheme.primaryText : AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...insights.map((text) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
