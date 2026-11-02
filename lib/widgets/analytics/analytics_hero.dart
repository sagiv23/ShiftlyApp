import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';

enum AnalyticsPeriodMode { monthly, yearly, allTime }

class AnalyticsHero extends StatelessWidget {
  final AnalyticsPeriodMode periodMode;
  final DateTime selectedDate;
  final String? selectedJobId;
  final List<JobType> jobTypes;
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
  final String symbol;

  final ValueChanged<AnalyticsPeriodMode> onPeriodChanged;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final ValueChanged<String?> onJobChanged;
  final ValueChanged<int>? onSectionSelected;

  const AnalyticsHero({
    super.key,
    required this.periodMode,
    required this.selectedDate,
    required this.selectedJobId,
    required this.jobTypes,
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
    required this.symbol,
    required this.onPeriodChanged,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.onJobChanged,
    this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.electricCyan;

    String dateTitle = '';
    if (periodMode == AnalyticsPeriodMode.monthly) {
      dateTitle = DateFormat.yMMMM(l.localeName).format(selectedDate);
    } else if (periodMode == AnalyticsPeriodMode.yearly) {
      dateTitle = '${selectedDate.year}';
    } else {
      dateTitle = l.analytics_period_all_time;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [const Color(0xFF152B49), AppTheme.darkCard]
              : [Colors.white, const Color(0xFFF0F9FF)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: isDark ? .32 : .25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricCyan.withValues(alpha: isDark ? .14 : .09),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Period Selector & Job Filter Controls
          _buildControlsRow(context, l, isDark, dateTitle),

          const SizedBox(height: AppTheme.spaceMd),

          // 2. Greeting & Currency Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.analytics_hero_greeting,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: totalNet),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, _) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            UIUtils.formatCurrency(val, symbol: symbol),
                            style: UIUtils.getCurrencyStyle(
                              context,
                              val,
                              baseStyle: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                              positiveColor: AppTheme.profit,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: totalBaseSalary),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${l.home_total_card_base}: ${UIUtils.formatCurrency(value, symbol: symbol)}',
                    style: UIUtils.getCurrencyStyle(
                      context,
                      value,
                      baseStyle: Theme.of(context).textTheme.bodySmall,
                      positiveColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceSm + 4),

          // 3. Supporting Snapshot Metrics Row (Hours & Shift Count)
          Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  icon: Icons.schedule_rounded,
                  value:
                      '${totalHours.toStringAsFixed(1)} ${l.common_hours_suffix}',
                  label: l.home_total_card_hours,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _SnapshotMetric(
                  icon: Icons.work_history_rounded,
                  value: '$shiftCount',
                  label: l.common_shifts_count,
                ),
              ),
            ],
          ),

          // 4. Amount Pills (Base, Tips, Incomes, Expenses)
          if (totalTips > 0 || totalIncomes > 0 || totalExpenses > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AmountPill(
                  label: l.home_total_card_base,
                  amount: totalBaseSalary,
                  color: AppTheme.electricCyan,
                  symbol: symbol,
                ),
                if (totalTips > 0)
                  _AmountPill(
                    label: l.home_total_card_tips,
                    amount: totalTips,
                    color: AppTheme.mintGreen,
                    symbol: symbol,
                  ),
                if (totalIncomes > 0)
                  _AmountPill(
                    label: l.expenses_tab_incomes,
                    amount: totalIncomes,
                    color: AppTheme.electricCyan,
                    symbol: symbol,
                  ),
                if (totalExpenses > 0)
                  _AmountPill(
                    label: l.home_total_card_expenses,
                    amount: -totalExpenses,
                    color: AppTheme.softCoral,
                    symbol: symbol,
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppTheme.spaceSm + 4),

          // 5. Centered Projection / Shifts Badge Box (Text Centered & Separated)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    (periodMode == AnalyticsPeriodMode.monthly
                            ? AppTheme.neonViolet
                            : primaryColor)
                        .withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color:
                      (periodMode == AnalyticsPeriodMode.monthly
                              ? AppTheme.neonViolet
                              : primaryColor)
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    periodMode == AnalyticsPeriodMode.monthly
                        ? l.analytics_kpi_projected
                        : l.common_shifts_count,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: periodMode == AnalyticsPeriodMode.monthly
                          ? AppTheme.neonViolet
                          : AppTheme.electricCyan,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    periodMode == AnalyticsPeriodMode.monthly
                        ? UIUtils.formatCurrency(
                            projectedEom,
                            symbol: symbol,
                            decimals: 0,
                          )
                        : '$shiftCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: periodMode == AnalyticsPeriodMode.monthly
                          ? AppTheme.neonViolet
                          : AppTheme.electricCyan,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow(
    BuildContext context,
    AppLocalizations l,
    bool isDark,
    String dateTitle,
  ) {
    return Column(
      children: [
        // 1. Full Width SegmentedButton (Monthly, Yearly, All Time)
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AnalyticsPeriodMode>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.comfortable,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            segments: [
              ButtonSegment(
                value: AnalyticsPeriodMode.monthly,
                label: Text(
                  l.analytics_period_monthly,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ButtonSegment(
                value: AnalyticsPeriodMode.yearly,
                label: Text(
                  l.analytics_period_yearly,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ButtonSegment(
                value: AnalyticsPeriodMode.allTime,
                label: Text(
                  l.analytics_period_all_time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            selected: {periodMode},
            onSelectionChanged: (val) => onPeriodChanged(val.first),
          ),
        ),

        // 2. Job Selector Dropdown centered on its own row below
        if (jobTypes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: DropdownButton<String?>(
                value: selectedJobId,
                underline: const SizedBox(),
                isDense: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 2, left: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppTheme.electricCyan,
                  ),
                ),
                hint: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.work_outline_rounded,
                      size: 15,
                      color: AppTheme.electricCyan,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.analytics_all_jobs,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.work_outline_rounded,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.analytics_all_jobs,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ...jobTypes.map(
                    (job) => DropdownMenuItem<String?>(
                      value: job.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            size: 15,
                            color: AppTheme.electricCyan,
                          ),
                          const SizedBox(width: 8),
                          Text(job.name, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: onJobChanged,
              ),
            ),
          ),
        ],

        if (periodMode != AnalyticsPeriodMode.allTime) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: onPreviousPeriod,
                tooltip: l.common_previous,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Text(
                dateTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brightCyan,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: onNextPeriod,
                tooltip: l.common_next,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SnapshotMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.electricCyan, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AmountPill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String symbol;

  const _AmountPill({
    required this.label,
    required this.amount,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            UIUtils.formatCurrency(amount, symbol: symbol),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
