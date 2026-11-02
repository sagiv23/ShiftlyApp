import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/analytics_charts.dart';

class AnalyticsWorkPatternsSection extends StatelessWidget {
  final AppLocalizations l;
  final String symbol;
  final List<TimeOfDaySegment> todSegments;
  final List<ShiftDurationCategory> durationCategories;
  final List<DonutSegment> donutSegments;
  final List<JobType> jobTypes;
  final double grandTotalNet;
  final double totalNetHours;
  final bool byEarningsForJobs;
  final ValueChanged<bool> onToggleByEarnings;
  final bool isWideScreen;

  const AnalyticsWorkPatternsSection({
    super.key,
    required this.l,
    required this.symbol,
    required this.todSegments,
    required this.durationCategories,
    required this.donutSegments,
    required this.jobTypes,
    required this.grandTotalNet,
    required this.totalNetHours,
    required this.byEarningsForJobs,
    required this.onToggleByEarnings,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    final todCard = todSegments.isNotEmpty
        ? _buildTimeOfDayCard(context)
        : null;

    final durationCard = durationCategories.isNotEmpty
        ? _buildDurationCard(context)
        : null;

    final jobDonutCard = (jobTypes.length > 1 || donutSegments.isNotEmpty)
        ? _buildJobDistributionCard(context)
        : null;

    if (isWideScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todCard != null || durationCard != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todCard != null)
                  Expanded(child: todCard)
                else
                  const Spacer(),
                const SizedBox(width: AppTheme.spaceSm),
                if (durationCard != null)
                  Expanded(child: durationCard)
                else
                  const Spacer(),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
          ],
          if (jobDonutCard != null) ...[jobDonutCard],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todCard != null) ...[
          todCard,
          const SizedBox(height: AppTheme.spaceSm),
        ],
        if (durationCard != null) ...[
          durationCard,
          const SizedBox(height: AppTheme.spaceSm),
        ],
        if (jobDonutCard != null) ...[jobDonutCard],
      ],
    );
  }

  Widget _buildTimeOfDayCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.analytics_chart_tod_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l.analytics_chart_tod_subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),

            TimeOfDayChartWidget(segments: todSegments, currencySymbol: symbol),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.analytics_chart_duration_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l.analytics_chart_duration_subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),

            ShiftDurationDistributionWidget(
              categories: durationCategories,
              currencySymbol: symbol,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDistributionCard(BuildContext context) {
    final centerTitle = byEarningsForJobs
        ? UIUtils.formatCurrency(grandTotalNet, symbol: symbol)
        : l.analytics_hours_suffix_format(totalNetHours.toStringAsFixed(1));

    final centerSubtitle = byEarningsForJobs
        ? l.analytics_stat_total_net
        : l.analytics_stat_total_hours;

    final isCompactScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  l.analytics_chart_jobs_title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle By Earnings vs By Hours
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(
                        l.analytics_chart_jobs_by_earnings,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(
                        l.analytics_chart_jobs_by_hours,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                  selected: {byEarningsForJobs},
                  onSelectionChanged: (val) {
                    onToggleByEarnings(val.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),

            if (isCompactScreen)
              Column(
                children: [
                  Center(
                    child: JobDonutChartWidget(
                      segments: donutSegments,
                      centerTitle: centerTitle,
                      centerSubtitle: centerSubtitle,
                      size: 160,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  ...donutSegments.map(
                    (seg) => _buildJobLegendRow(context, seg),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: JobDonutChartWidget(
                      segments: donutSegments,
                      centerTitle: centerTitle,
                      centerSubtitle: centerSubtitle,
                      size: 160,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: donutSegments
                          .map((seg) => _buildJobLegendRow(context, seg))
                          .toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobLegendRow(BuildContext context, DonutSegment seg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              seg.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            byEarningsForJobs
                ? UIUtils.formatCurrency(seg.amount, symbol: symbol)
                : l.analytics_hours_suffix_format(seg.hours.toStringAsFixed(1)),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: seg.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${seg.percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: seg.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
