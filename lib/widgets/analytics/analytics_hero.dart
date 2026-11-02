import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/theme/app_theme.dart';

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
      child: _buildControlsRow(context, l, isDark, dateTitle),
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
