import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';

class AnalyticsPayBreakdownSection extends StatelessWidget {
  final AppLocalizations l;
  final String symbol;
  final double totalRegularHours;
  final double totalRegularEarnings;
  final double totalTier1Hours;
  final double totalTier1Earnings;
  final double totalTier2Hours;
  final double totalTier2Earnings;
  final double totalShabbatHours;
  final double totalShabbatEarnings;
  final double totalHolidayHours;
  final double totalHolidayEarnings;

  const AnalyticsPayBreakdownSection({
    super.key,
    required this.l,
    required this.symbol,
    required this.totalRegularHours,
    required this.totalRegularEarnings,
    required this.totalTier1Hours,
    required this.totalTier1Earnings,
    required this.totalTier2Hours,
    required this.totalTier2Earnings,
    required this.totalShabbatHours,
    required this.totalShabbatEarnings,
    required this.totalHolidayHours,
    required this.totalHolidayEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalOvertimeHours = totalTier1Hours + totalTier2Hours;
    final totalOvertimeEarnings = totalTier1Earnings + totalTier2Earnings;

    final hasData =
        totalRegularHours > 0 ||
        totalOvertimeHours > 0 ||
        totalShabbatHours > 0 ||
        totalHolidayHours > 0;

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.electricCyan,
              ),
              const SizedBox(width: 8),
              Text(
                l.analytics_section_pay_breakdown,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // 1. Regular Hours
          if (totalRegularHours > 0)
            _BreakdownRow(
              icon: Icons.access_time_rounded,
              label: l.analytics_regular_hours,
              hours: totalRegularHours,
              earnings: totalRegularEarnings,
              badgeText: '100%',
              badgeColor: AppTheme.electricCyan,
              symbol: symbol,
              l: l,
            ),

          // 2. Overtime Tier 1 (125%)
          if (totalTier1Hours > 0) ...[
            const Divider(height: 16),
            _BreakdownRow(
              icon: Icons.more_time_rounded,
              label: l.overtime_tier1_label,
              hours: totalTier1Hours,
              earnings: totalTier1Earnings,
              badgeText: '125%',
              badgeColor: AppTheme.warmAmber,
              symbol: symbol,
              l: l,
            ),
          ],

          // 3. Overtime Tier 2 (150%)
          if (totalTier2Hours > 0) ...[
            const Divider(height: 16),
            _BreakdownRow(
              icon: Icons.more_time_rounded,
              label: l.overtime_tier2_label,
              hours: totalTier2Hours,
              earnings: totalTier2Earnings,
              badgeText: '150%',
              badgeColor: AppTheme.expenseSoft,
              symbol: symbol,
              l: l,
            ),
          ],

          // 4. Shabbat Hours
          if (totalShabbatHours > 0) ...[
            const Divider(height: 16),
            _BreakdownRow(
              icon: Icons.star_rounded,
              label: l.analytics_shabbat_hours,
              hours: totalShabbatHours,
              earnings: totalShabbatEarnings,
              badgeText: l.shabbat_tag_label,
              badgeColor: Colors.amber,
              symbol: symbol,
              l: l,
            ),
          ],

          // 5. Jewish Holiday Hours
          if (totalHolidayHours > 0) ...[
            const Divider(height: 16),
            _BreakdownRow(
              icon: Icons.celebration_rounded,
              label: l.analytics_holiday_hours,
              hours: totalHolidayHours,
              earnings: totalHolidayEarnings,
              badgeText: l.holiday_tag_label,
              badgeColor: AppTheme.neonViolet,
              symbol: symbol,
              l: l,
            ),
          ],

          // Total Summary Bar
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.electricCyan.withValues(
                alpha: isDark ? 0.12 : 0.06,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.electricCyan.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.analytics_base_salary,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  UIUtils.formatCurrency(
                    totalRegularEarnings +
                        totalOvertimeEarnings +
                        totalShabbatEarnings +
                        totalHolidayEarnings,
                    symbol: symbol,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppTheme.primaryDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double hours;
  final double earnings;
  final String badgeText;
  final Color badgeColor;
  final String symbol;
  final AppLocalizations l;

  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.hours,
    required this.earnings,
    required this.badgeText,
    required this.badgeColor,
    required this.symbol,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: badgeColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${hours.toStringAsFixed(1)} ${l.common_hours_suffix}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            UIUtils.formatCurrency(earnings, symbol: symbol),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
