import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/kpi_card.dart';

class AnalyticsOverviewSection extends StatelessWidget {
  final AppLocalizations l;
  final String symbol;
  final double totalNet;
  final double totalBaseSalary;
  final double totalTips;
  final double totalIncomes;
  final double totalExpenses;
  final double totalHours;
  final double avgRate;
  final int shiftCount;
  final double projectedEom;
  final double retentionPct;
  final double rateBoost;
  final bool isMonthly;

  const AnalyticsOverviewSection({
    super.key,
    required this.l,
    required this.symbol,
    required this.totalNet,
    required this.totalBaseSalary,
    required this.totalTips,
    required this.totalIncomes,
    required this.totalExpenses,
    required this.totalHours,
    required this.avgRate,
    required this.shiftCount,
    required this.projectedEom,
    required this.retentionPct,
    required this.rateBoost,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of essential stats
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final crossAxisCount = isWide ? 4 : 2;
            final spacing = AppTheme.spaceSm;
            final itemWidth = (constraints.maxWidth -
                (crossAxisCount - 1) * spacing) / crossAxisCount;

            final kpiCards = [
              KpiCard(
                title: l.analytics_stat_total_net,
                value: '',
                numericValue: totalNet,
                formatter: (v) => UIUtils.formatCurrency(v, symbol: symbol),
                isCurrency: true,
                subtitle: isMonthly
                    ? '${l.analytics_kpi_projected}: ${UIUtils.formatCurrency(
                    projectedEom, symbol: symbol, decimals: 0)}'
                    : '$shiftCount ${l.common_shifts_count}',
                icon: Icons.account_balance_wallet_rounded,
                gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                isDark: isDark,
              ),
              KpiCard(
                title: l.analytics_base_salary,
                value: '',
                numericValue: totalBaseSalary,
                formatter: (v) => UIUtils.formatCurrency(v, symbol: symbol),
                isCurrency: true,
                subtitle: l.home_total_card_base,
                icon: Icons.work_rounded,
                gradientColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                isDark: isDark,
              ),
              KpiCard(
                title: l.analytics_stat_total_hours,
                value: '',
                numericValue: totalHours,
                formatter: (v) =>
                    l.analytics_hours_suffix_format(v.toStringAsFixed(1)),
                subtitle: '$shiftCount ${l.common_shifts_count}',
                icon: Icons.schedule_rounded,
                gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                isDark: isDark,
              ),
              KpiCard(
                title: l.analytics_stat_avg_rate,
                value: '',
                numericValue: avgRate,
                formatter: (v) =>
                '${UIUtils.formatCurrency(v, symbol: symbol)}/${l
                    .common_hours_suffix}',
                isCurrency: true,
                subtitle: rateBoost > 0
                    ? l.analytics_rate_boost_subtitle(
                  UIUtils.formatCurrency(rateBoost, symbol: symbol),
                )
                    : l.analytics_stat_avg_rate,
                icon: Icons.speed_rounded,
                gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                isDark: isDark,
              ),
              if (totalTips > 0)
                KpiCard(
                  title: l.home_total_card_tips,
                  value: '',
                  numericValue: totalTips,
                  formatter: (v) => UIUtils.formatCurrency(v, symbol: symbol),
                  isCurrency: true,
                  subtitle: l.home_total_card_tips,
                  icon: Icons.local_activity_rounded,
                  gradientColors: const [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                  isDark: isDark,
                ),
              if (totalIncomes > 0)
                KpiCard(
                  title: l.expenses_tab_incomes,
                  value: '',
                  numericValue: totalIncomes,
                  formatter: (v) => UIUtils.formatCurrency(v, symbol: symbol),
                  isCurrency: true,
                  subtitle: l.expenses_tab_incomes,
                  icon: Icons.arrow_downward_rounded,
                  gradientColors: const [
                    Color(0xFF6EE7B7),
                    Color(0xFF34D399),
                  ],
                  isDark: isDark,
                ),
              if (totalExpenses > 0)
                KpiCard(
                  title: l.home_total_card_expenses,
                  value: '',
                  numericValue: totalExpenses,
                  formatter: (v) => UIUtils.formatCurrency(v, symbol: symbol),
                  isCurrency: true,
                  isExpense: true,
                  subtitle: l.home_total_card_expenses,
                  icon: Icons.arrow_upward_rounded,
                  gradientColors: const [
                    Color(0xFFEF4444),
                    Color(0xFFDC2626),
                  ],
                  isDark: isDark,
                ),
              KpiCard(
                title: l.analytics_kpi_retention,
                value: '',
                numericValue: retentionPct,
                formatter: (v) => '${v.toStringAsFixed(1)}%',
                subtitle: l.analytics_retention_subtitle,
                icon: Icons.savings_rounded,
                gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                isDark: isDark,
              ),
            ];

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: kpiCards.map((card) {
                return SizedBox(
                  width: itemWidth,
                  child: card,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
