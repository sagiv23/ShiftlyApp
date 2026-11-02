import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/analytics_charts.dart';

class AnalyticsEarningsSection extends StatelessWidget {
  final AppLocalizations l;
  final String symbol;
  final List<BarDataPoint> dataPoints;
  final int? selectedBarIndex;
  final ValueChanged<int?> onBarSelected;
  final List<CumulativeGrowthData> cumulativeData;
  final bool isWideScreen;
  final bool isMonthMode;

  const AnalyticsEarningsSection({
    super.key,
    required this.l,
    required this.symbol,
    required this.dataPoints,
    required this.selectedBarIndex,
    required this.onBarSelected,
    required this.cumulativeData,
    required this.isWideScreen,
    required this.isMonthMode,
  });

  @override
  Widget build(BuildContext context) {
    BarDataPoint? selectedPoint;
    if (selectedBarIndex != null &&
        selectedBarIndex! >= 0 &&
        selectedBarIndex! < dataPoints.length) {
      selectedPoint = dataPoints[selectedBarIndex!];
    }

    final barCard = _buildEarningsChartCard(context, selectedPoint);
    final cumulativeCard = _buildCumulativeGrowthCard(context);

    if (isWideScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: barCard),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(child: cumulativeCard),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        barCard,
        const SizedBox(height: AppTheme.spaceSm),
        cumulativeCard,
      ],
    );
  }

  Widget _buildEarningsChartCard(
    BuildContext context,
    BarDataPoint? selectedPoint,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.analytics_chart_earnings_title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l.analytics_chart_earnings_subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Legend
                Row(
                  children: [
                    _LegendDot(
                      color: AppTheme.primary,
                      label: l.analytics_base_salary,
                    ),
                    const SizedBox(width: 8),
                    _LegendDot(
                      color: AppTheme.profit,
                      label: l.analytics_tips_and_extra,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),

            EarningsBarChartWidget(
              data: dataPoints,
              selectedIndex: selectedBarIndex,
              onSelected: onBarSelected,
              currencySymbol: symbol,
              height: 200,
            ),

            if (selectedPoint != null) ...[
              const Divider(height: AppTheme.spaceMd),
              _SelectedPointDetailsCard(
                point: selectedPoint,
                symbol: symbol,
                l: l,
                isMonthMode: isMonthMode,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCumulativeGrowthCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.analytics_chart_cumulative_title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l.analytics_chart_cumulative_subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _LegendDot(
                      color: AppTheme.neonViolet,
                      label: l.analytics_gross_pay,
                    ),
                    const SizedBox(width: 8),
                    _LegendDot(
                      color: AppTheme.electricCyan,
                      label: l.analytics_net_pay,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),

            CumulativeEarningsLineChartWidget(
              data: cumulativeData,
              currencySymbol: symbol,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPointDetailsCard extends StatelessWidget {
  final BarDataPoint point;
  final String symbol;
  final AppLocalizations l;
  final bool isMonthMode;

  const _SelectedPointDetailsCard({
    required this.point,
    required this.symbol,
    required this.l,
    this.isMonthMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = isMonthMode
        ? l.analytics_selected_month_breakdown
        : l.analytics_selected_breakdown;

    final dateStr = isMonthMode
        ? DateFormat.yMMMM(l.localeName).format(point.date)
        : AppConstants.formatDate(point.date);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$label: $dateStr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l.analytics_hours_suffix_format(
                  point.netHours.toStringAsFixed(1),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DetailSubItem(
                label: l.analytics_base_salary,
                value: UIUtils.formatCurrency(point.basePay, symbol: symbol),
                amount: point.basePay,
              ),
              if (point.tips > 0)
                _DetailSubItem(
                  label: l.home_total_card_tips,
                  value: UIUtils.formatCurrency(point.tips, symbol: symbol),
                  amount: point.tips,
                  positiveColor: AppTheme.profit,
                ),
              _DetailSubItem(
                label: l.analytics_stat_avg_rate,
                value: UIUtils.formatCurrency(
                  point.effectiveHourlyRate,
                  symbol: symbol,
                ),
                amount: point.effectiveHourlyRate,
                isBold: true,
              ),
              _DetailSubItem(
                label: l.common_net,
                value: UIUtils.formatCurrency(point.totalNet, symbol: symbol),
                amount: point.totalNet,
                isBold: true,
                positiveColor: AppTheme.primaryDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSubItem extends StatelessWidget {
  final String label;
  final String value;
  final double amount;
  final bool isBold;
  final Color? positiveColor;

  const _DetailSubItem({
    required this.label,
    required this.value,
    required this.amount,
    this.isBold = false,
    this.positiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: UIUtils.getCurrencyStyle(
            context,
            amount,
            baseStyle: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            positiveColor:
                positiveColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
