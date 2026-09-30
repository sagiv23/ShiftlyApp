import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/analytics_charts.dart';

enum AnalyticsPeriodMode { monthly, yearly, allTime }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriodMode _periodMode = AnalyticsPeriodMode.monthly;
  DateTime _selectedDate = DateTime.now();
  String? _selectedJobId; // null = all jobs
  int? _selectedBarIndex;
  bool _byEarningsForJobs = true;

  void _changePeriod(AnalyticsPeriodMode newMode) {
    if (_periodMode != newMode) {
      setState(() {
        _periodMode = newMode;
        _selectedBarIndex = null;
      });
    }
  }

  void _previousPeriod() {
    setState(() {
      _selectedBarIndex = null;
      if (_periodMode == AnalyticsPeriodMode.monthly) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          1,
        );
      } else if (_periodMode == AnalyticsPeriodMode.yearly) {
        _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      _selectedBarIndex = null;
      if (_periodMode == AnalyticsPeriodMode.monthly) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          1,
        );
      } else if (_periodMode == AnalyticsPeriodMode.yearly) {
        _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
      }
    });
  }

  List<Shift> _filterShifts(List<Shift> allShifts) {
    return allShifts.where((shift) {
      // Job type filter
      if (_selectedJobId != null && shift.jobTypeId != _selectedJobId) {
        return false;
      }

      // Period filter
      if (_periodMode == AnalyticsPeriodMode.monthly) {
        return shift.date.year == _selectedDate.year &&
            shift.date.month == _selectedDate.month;
      } else if (_periodMode == AnalyticsPeriodMode.yearly) {
        return shift.date.year == _selectedDate.year;
      } else {
        return true; // All time
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final jobTypes = shiftProvider.jobTypes;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 850;

    final filteredShifts = _filterShifts(shiftProvider.shifts);

    // Calculate Totals
    double totalNetHours = 0;
    double totalBaseSalary = 0;
    double totalTips = 0;
    double totalExpenses = 0;
    double totalIncomes = 0;
    final shiftCount = filteredShifts.length;

    for (var shift in filteredShifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      totalNetHours += shift.netHours;
      totalBaseSalary += shift.netHours * rate;
      totalTips += shift.tips;
      totalExpenses += shift.totalAutomaticExpenses;
      totalIncomes += shift.totalAutomaticIncomes;
    }

    final grandTotalNet =
        totalBaseSalary + totalTips + totalIncomes - totalExpenses;
    final avgEffectiveRate = totalNetHours > 0
        ? (grandTotalNet / totalNetHours)
        : 0.0;

    // Prepare Bar Chart Data
    final barDataPoints = _generateBarDataPoints(
      filteredShifts,
      shiftProvider,
      l,
    );

    // Selected Bar Details
    BarDataPoint? selectedPoint;
    if (_selectedBarIndex != null &&
        _selectedBarIndex! >= 0 &&
        _selectedBarIndex! < barDataPoints.length) {
      selectedPoint = barDataPoints[_selectedBarIndex!];
    }

    // Prepare Cumulative Growth Data
    final cumulativeData = _generateCumulativeData(barDataPoints);

    // Prepare Donut Chart Data
    final donutSegments = _generateDonutSegments(
      filteredShifts,
      shiftProvider,
      jobTypes,
    );

    // Prepare Tips Trend Data
    final tipsTrendData = _generateTipsTrendData(filteredShifts, l);

    // Prepare Hourly Wage Trend Data
    final wageTrendData = _generateWageTrendData(
      filteredShifts,
      shiftProvider,
      l,
    );

    // Prepare Day of Week Data
    final dayOfWeekData = _generateDayOfWeekData(
      filteredShifts,
      shiftProvider,
      l,
    );

    // Chart Widgets
    final earningsBarCard = _buildEarningsChartCard(
      context,
      l: l,
      symbol: symbol,
      dataPoints: barDataPoints,
      selectedPoint: selectedPoint,
    );

    final cumulativeLineCard = _buildCumulativeGrowthCard(
      context,
      l: l,
      symbol: symbol,
      cumulativeData: cumulativeData,
    );

    final jobDonutCard = (jobTypes.length > 1 || donutSegments.isNotEmpty)
        ? _buildJobDistributionCard(
            context,
            l: l,
            symbol: symbol,
            segments: donutSegments,
            totalNet: grandTotalNet,
            totalHours: totalNetHours,
          )
        : null;

    final tipsTrendCard = tipsTrendData.length >= 2
        ? _buildTipsTrendCard(
            context,
            l: l,
            symbol: symbol,
            data: tipsTrendData,
          )
        : null;

    final wageTrendCard = wageTrendData.length >= 2
        ? _buildWageTrendCard(
            context,
            l: l,
            symbol: symbol,
            trendData: wageTrendData,
          )
        : null;

    final dayOfWeekCard = (dayOfWeekData.isNotEmpty && shiftCount >= 2)
        ? _buildDayOfWeekCard(
            context,
            l: l,
            symbol: symbol,
            days: dayOfWeekData,
          )
        : null;

    return AdaptiveScaffold(
      currentIndex: 2,
      title: l.analytics_title,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceSm,
            AppTheme.spaceXs,
            AppTheme.spaceSm,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Controls Header (Period Mode, Pager, Job Filter)
              _buildFilterHeader(context, l, jobTypes),
              const SizedBox(height: AppTheme.spaceSm),

              // 2. Summary KPI Cards
              _buildKpiGrid(
                context,
                l: l,
                symbol: symbol,
                totalNet: grandTotalNet,
                totalHours: totalNetHours,
                avgRate: avgEffectiveRate,
                totalTips: totalTips,
                shiftCount: shiftCount,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Responsive Chart Layout (Multi-column for wide screen, Stacked for mobile)
              if (isWideScreen) ...[
                // Row 1: Earnings Bar Chart & Cumulative Growth Line Chart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: earningsBarCard),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(child: cumulativeLineCard),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),

                // Row 2: Job Donut & Tips Trend Line Chart
                if (jobDonutCard != null || tipsTrendCard != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (jobDonutCard != null)
                        Expanded(child: jobDonutCard)
                      else
                        const Spacer(),
                      const SizedBox(width: AppTheme.spaceSm),
                      if (tipsTrendCard != null)
                        Expanded(child: tipsTrendCard)
                      else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],

                // Row 3: Hourly Wage Trend & Day of Week Performance
                if (wageTrendCard != null || dayOfWeekCard != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wageTrendCard != null)
                        Expanded(child: wageTrendCard)
                      else
                        const Spacer(),
                      const SizedBox(width: AppTheme.spaceSm),
                      if (dayOfWeekCard != null)
                        Expanded(child: dayOfWeekCard)
                      else
                        const Spacer(),
                    ],
                  ),
                ],
              ] else ...[
                // Mobile Stacked Cards
                earningsBarCard,
                const SizedBox(height: AppTheme.spaceSm),
                cumulativeLineCard,
                const SizedBox(height: AppTheme.spaceSm),
                if (jobDonutCard != null) ...[
                  jobDonutCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (tipsTrendCard != null) ...[
                  tipsTrendCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (wageTrendCard != null) ...[
                  wageTrendCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (dayOfWeekCard != null) ...[
                  dayOfWeekCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterHeader(
    BuildContext context,
    AppLocalizations l,
    List<JobType> jobTypes,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String dateTitle = '';
    if (_periodMode == AnalyticsPeriodMode.monthly) {
      dateTitle = DateFormat.yMMMM(l.localeName).format(_selectedDate);
    } else if (_periodMode == AnalyticsPeriodMode.yearly) {
      dateTitle = '${_selectedDate.year}';
    } else {
      dateTitle = l.analytics_period_all_time;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          children: [
            // Period Segmented Control
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AnalyticsPeriodMode>(
                segments: [
                  ButtonSegment(
                    value: AnalyticsPeriodMode.monthly,
                    label: Text(l.analytics_period_monthly),
                    icon: const Icon(
                      Icons.calendar_view_month_rounded,
                      size: 18,
                    ),
                  ),
                  ButtonSegment(
                    value: AnalyticsPeriodMode.yearly,
                    label: Text(l.analytics_period_yearly),
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: AnalyticsPeriodMode.allTime,
                    label: Text(l.analytics_period_all_time),
                    icon: const Icon(Icons.all_inclusive_rounded, size: 18),
                  ),
                ],
                selected: {_periodMode},
                onSelectionChanged: (val) => _changePeriod(val.first),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),

            // Date Pager & Job Selector Row
            Row(
              children: [
                if (_periodMode != AnalyticsPeriodMode.allTime) ...[
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _previousPeriod,
                    tooltip: 'קודם',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        dateTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _nextPeriod,
                    tooltip: 'הבא',
                  ),
                ] else
                  Expanded(
                    child: Text(
                      l.analytics_period_all_time,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),

                if (jobTypes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButton<String?>(
                      value: _selectedJobId,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.work_outline_rounded, size: 18),
                      hint: Text(
                        l.analytics_all_jobs,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l.analytics_all_jobs,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        ...jobTypes.map(
                          (job) => DropdownMenuItem<String?>(
                            value: job.id,
                            child: Text(
                              job.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedJobId = val;
                          _selectedBarIndex = null;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required double totalNet,
    required double totalHours,
    required double avgRate,
    required double totalTips,
    required int shiftCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spaceSm,
          crossAxisSpacing: AppTheme.spaceSm,
          childAspectRatio: constraints.maxWidth > 700 ? 1.5 : 1.35,
          children: [
            _KpiCard(
              title: l.analytics_stat_total_net,
              value: UIUtils.formatCurrency(totalNet, symbol: symbol),
              subtitle: '$shiftCount ${l.common_shifts_count}',
              icon: Icons.account_balance_wallet_rounded,
              gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_stat_total_hours,
              value: '${totalHours.toStringAsFixed(1)} שעות',
              subtitle: shiftCount > 0
                  ? 'ממוצע ${(totalHours / shiftCount).toStringAsFixed(1)} ש\' למשמרת'
                  : '0 שעות',
              icon: Icons.schedule_rounded,
              gradientColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_stat_avg_rate,
              value: UIUtils.formatCurrency(avgRate, symbol: symbol),
              subtitle: 'לשעה אפקטיבית',
              icon: Icons.trending_up_rounded,
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_stat_tips,
              value: UIUtils.formatCurrency(totalTips, symbol: symbol),
              subtitle: totalNet > 0
                  ? '${((totalTips / totalNet) * 100).toStringAsFixed(0)}% מההכנסה'
                  : '0%',
              icon: Icons.payments_rounded,
              gradientColors: const [Color(0xFFEC4899), Color(0xFFD97706)],
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEarningsChartCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<BarDataPoint> dataPoints,
    required BarDataPoint? selectedPoint,
  }) {
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
                    _LegendDot(color: AppTheme.primary, label: 'בסיס'),
                    const SizedBox(width: 8),
                    _LegendDot(color: AppTheme.profit, label: 'טיפים+תוספות'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),

            EarningsBarChartWidget(
              data: dataPoints,
              selectedIndex: _selectedBarIndex,
              onSelected: (idx) {
                setState(() => _selectedBarIndex = idx);
              },
              currencySymbol: symbol,
              height: 200,
            ),

            if (selectedPoint != null) ...[
              const Divider(height: AppTheme.spaceMd),
              _SelectedPointDetailsCard(
                point: selectedPoint,
                symbol: symbol,
                l: l,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCumulativeGrowthCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<CumulativeGrowthData> cumulativeData,
  }) {
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
                      color: const Color(0xFF6366F1),
                      label: l.analytics_gross_pay,
                    ),
                    const SizedBox(width: 8),
                    _LegendDot(
                      color: const Color(0xFF10B981),
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

  Widget _buildJobDistributionCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<DonutSegment> segments,
    required double totalNet,
    required double totalHours,
  }) {
    final centerTitle = _byEarningsForJobs
        ? UIUtils.formatCurrency(totalNet, symbol: symbol)
        : '${totalHours.toStringAsFixed(1)} ש\'';

    final centerSubtitle = _byEarningsForJobs ? 'סה"כ שכר' : 'סה"כ שעות';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  selected: {_byEarningsForJobs},
                  onSelectionChanged: (val) {
                    setState(() => _byEarningsForJobs = val.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: JobDonutChartWidget(
                    segments: segments,
                    centerTitle: centerTitle,
                    centerSubtitle: centerSubtitle,
                    size: 160,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: segments.map((seg) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: seg.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                seg.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _byEarningsForJobs
                                  ? UIUtils.formatCurrency(
                                      seg.amount,
                                      symbol: symbol,
                                    )
                                  : '${seg.hours.toStringAsFixed(1)} ש\'',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${seg.percentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsTrendCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<TipsTrendData> data,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.analytics_chart_tips_trend_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l.analytics_chart_tips_trend_subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),

            TipsTrendLineChartWidget(
              data: data,
              currencySymbol: symbol,
              height: 180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWageTrendCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<HourlyWageTrendData> trendData,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.analytics_chart_wage_trend_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l.analytics_chart_wage_trend_subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),

            HourlyWageLineChartWidget(
              data: trendData,
              currencySymbol: symbol,
              height: 180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<DayOfWeekPerformance> days,
  }) {
    DayOfWeekPerformance? bestDay;
    double maxRate = 0;
    for (var d in days) {
      if (d.avgHourlyRate > maxRate) {
        maxRate = d.avgHourlyRate;
        bestDay = d;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.analytics_chart_day_performance_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceXs),

            if (bestDay != null && maxRate > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.analytics_chart_best_day_msg
                            .replaceFirst('[[day]]', bestDay.dayName)
                            .replaceFirst(
                              '[[rate]]',
                              UIUtils.formatCurrency(
                                bestDay.avgHourlyRate,
                                symbol: symbol,
                              ),
                            ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppTheme.spaceSm),

            DayOfWeekChartWidget(days: days, currencySymbol: symbol),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods to generate Data Lists ---

  List<BarDataPoint> _generateBarDataPoints(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    final Map<String, List<Shift>> grouped = {};

    if (_periodMode == AnalyticsPeriodMode.monthly) {
      // Days of the month
      final daysInMonth = DateUtils.getDaysInMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      for (int d = 1; d <= daysInMonth; d++) {
        final key = d.toString();
        grouped[key] = [];
      }
      for (var shift in shifts) {
        final key = shift.date.day.toString();
        grouped[key]?.add(shift);
      }

      return List.generate(daysInMonth, (index) {
        final dayNum = index + 1;
        final dayShifts = grouped[dayNum.toString()] ?? [];
        final date = DateTime(_selectedDate.year, _selectedDate.month, dayNum);

        double base = 0, tips = 0, incomes = 0, expenses = 0, hours = 0;
        for (var s in dayShifts) {
          final job = shiftProvider.getJobTypeById(s.jobTypeId);
          final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
          hours += s.netHours;
          base += s.netHours * rate;
          tips += s.tips;
          expenses += s.totalAutomaticExpenses;
          incomes += s.totalAutomaticIncomes;
        }

        return BarDataPoint(
          id: 'day_$dayNum',
          label: '$dayNum',
          sublabel: DateFormat.E(l.localeName).format(date),
          date: date,
          basePay: base,
          tips: tips,
          extraIncomes: incomes,
          expenses: expenses,
          netHours: hours,
        );
      });
    } else if (_periodMode == AnalyticsPeriodMode.yearly) {
      // Months of the year
      for (int m = 1; m <= 12; m++) {
        grouped[m.toString()] = [];
      }
      for (var shift in shifts) {
        final key = shift.date.month.toString();
        grouped[key]?.add(shift);
      }

      return List.generate(12, (index) {
        final monthNum = index + 1;
        final monthShifts = grouped[monthNum.toString()] ?? [];
        final date = DateTime(_selectedDate.year, monthNum, 1);

        double base = 0, tips = 0, incomes = 0, expenses = 0, hours = 0;
        for (var s in monthShifts) {
          final job = shiftProvider.getJobTypeById(s.jobTypeId);
          final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
          hours += s.netHours;
          base += s.netHours * rate;
          tips += s.tips;
          expenses += s.totalAutomaticExpenses;
          incomes += s.totalAutomaticIncomes;
        }

        return BarDataPoint(
          id: 'month_$monthNum',
          label: DateFormat.MMM(l.localeName).format(date),
          sublabel: '${_selectedDate.year}',
          date: date,
          basePay: base,
          tips: tips,
          extraIncomes: incomes,
          expenses: expenses,
          netHours: hours,
        );
      });
    } else {
      // All-time grouped by month
      final sortedShifts = List<Shift>.from(shifts)
        ..sort((a, b) => a.date.compareTo(b.date));

      final monthMap = <String, List<Shift>>{};
      for (var s in sortedShifts) {
        final key = "${s.date.year}-${s.date.month.toString().padLeft(2, '0')}";
        monthMap.putIfAbsent(key, () => []).add(s);
      }

      final list = <BarDataPoint>[];
      monthMap.forEach((key, monthShifts) {
        final parts = key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month, 1);

        double base = 0, tips = 0, incomes = 0, expenses = 0, hours = 0;
        for (var s in monthShifts) {
          final job = shiftProvider.getJobTypeById(s.jobTypeId);
          final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
          hours += s.netHours;
          base += s.netHours * rate;
          tips += s.tips;
          expenses += s.totalAutomaticExpenses;
          incomes += s.totalAutomaticIncomes;
        }

        list.add(
          BarDataPoint(
            id: 'all_$key',
            label: DateFormat.MMM(l.localeName).format(date),
            sublabel: '$year',
            date: date,
            basePay: base,
            tips: tips,
            extraIncomes: incomes,
            expenses: expenses,
            netHours: hours,
          ),
        );
      });

      return list;
    }
  }

  List<CumulativeGrowthData> _generateCumulativeData(
    List<BarDataPoint> barPoints,
  ) {
    double runningGross = 0;
    double runningNet = 0;
    final list = <CumulativeGrowthData>[];

    for (var bp in barPoints) {
      runningGross += bp.totalGross;
      runningNet += bp.totalNet;
      list.add(
        CumulativeGrowthData(
          date: bp.date,
          label: bp.label,
          cumulativeGross: runningGross,
          cumulativeNet: runningNet,
        ),
      );
    }
    return list;
  }

  List<DonutSegment> _generateDonutSegments(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    List<JobType> jobTypes,
  ) {
    final Map<String, List<Shift>> jobShiftsMap = {};
    for (var shift in shifts) {
      jobShiftsMap.putIfAbsent(shift.jobTypeId, () => []).add(shift);
    }

    double grandTotal = 0;
    final Map<String, double> jobValues = {};
    final Map<String, double> jobHours = {};

    jobShiftsMap.forEach((jobId, jobShifts) {
      double jobPay = 0;
      double hours = 0;
      for (var s in jobShifts) {
        final job = shiftProvider.getJobTypeById(s.jobTypeId);
        final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
        jobPay += s.calculateTotalPay(rate);
        hours += s.netHours;
      }

      final val = _byEarningsForJobs ? jobPay : hours;
      jobValues[jobId] = jobPay;
      jobHours[jobId] = hours;
      grandTotal += val;
    });

    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF0284C7), // Sky Blue
      const Color(0xFF10B981), // Emerald Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
    ];

    int colorIdx = 0;
    final segments = <DonutSegment>[];

    jobShiftsMap.forEach((jobId, jobShifts) {
      final job = shiftProvider.getJobTypeById(jobId);
      final jobName = job?.name ?? 'תפקיד לא ידוע';
      final pay = jobValues[jobId] ?? 0;
      final hours = jobHours[jobId] ?? 0;
      final val = _byEarningsForJobs ? pay : hours;
      final pct = grandTotal > 0 ? (val / grandTotal) * 100.0 : 0.0;

      segments.add(
        DonutSegment(
          id: jobId,
          name: jobName,
          amount: pay,
          hours: hours,
          color: colors[colorIdx % colors.length],
          percentage: pct,
        ),
      );
      colorIdx++;
    });

    return segments;
  }

  List<TipsTrendData> _generateTipsTrendData(
    List<Shift> shifts,
    AppLocalizations l,
  ) {
    final sorted = List<Shift>.from(shifts)
      ..sort((a, b) => a.date.compareTo(b.date));

    final list = <TipsTrendData>[];
    for (var s in sorted) {
      if (s.tips <= 0 && s.totalAutomaticIncomes <= 0) continue;
      list.add(
        TipsTrendData(
          date: s.date,
          label: DateFormat('dd/MM').format(s.date),
          tips: s.tips,
          extraIncomes: s.totalAutomaticIncomes,
        ),
      );
    }
    return list;
  }

  List<HourlyWageTrendData> _generateWageTrendData(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    final sorted = List<Shift>.from(shifts)
      ..sort((a, b) => a.date.compareTo(b.date));

    final list = <HourlyWageTrendData>[];
    for (var s in sorted) {
      if (s.netHours <= 0) continue;
      final job = shiftProvider.getJobTypeById(s.jobTypeId);
      final base = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
      final totalPay = s.calculateTotalPay(base);
      final effective = totalPay / s.netHours;

      list.add(
        HourlyWageTrendData(
          date: s.date,
          label: DateFormat('dd/MM').format(s.date),
          effectiveRate: effective,
          baseRate: base,
        ),
      );
    }
    return list;
  }

  List<DayOfWeekPerformance> _generateDayOfWeekData(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    // 1 = Sunday, 7 = Saturday
    final Map<int, List<Shift>> dayMap = {for (int i = 1; i <= 7; i++) i: []};

    for (var s in shifts) {
      int dayIdx = s.date.weekday; // DateTime weekday: Mon=1..Sun=7
      // Convert to Sunday=1..Sat=7
      int sundayIdx = dayIdx == DateTime.sunday ? 1 : dayIdx + 1;
      dayMap[sundayIdx]?.add(s);
    }

    final dayNamesHebrew = ['א\'', 'ב\'', 'ג\'', 'ד\'', 'ה\'', 'ו\'', 'ש\''];
    final list = <DayOfWeekPerformance>[];

    for (int d = 1; d <= 7; d++) {
      final dayShifts = dayMap[d] ?? [];
      double totalPay = 0;
      double totalHours = 0;

      for (var s in dayShifts) {
        final job = shiftProvider.getJobTypeById(s.jobTypeId);
        final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
        totalPay += s.calculateTotalPay(rate);
        totalHours += s.netHours;
      }

      list.add(
        DayOfWeekPerformance(
          dayIndex: d,
          dayName: dayNamesHebrew[d - 1],
          totalEarnings: totalPay,
          totalHours: totalHours,
          shiftCount: dayShifts.length,
        ),
      );
    }

    return list;
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isDark;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = gradientColors.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: mainColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: Colors.white),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: mainColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SelectedPointDetailsCard extends StatelessWidget {
  final BarDataPoint point;
  final String symbol;
  final AppLocalizations l;

  const _SelectedPointDetailsCard({
    required this.point,
    required this.symbol,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(point.date);

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
              Text(
                '${l.analytics_selected_breakdown}: $dateStr',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                '${point.netHours.toStringAsFixed(1)} שעות',
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
              ),
              if (point.tips > 0)
                _DetailSubItem(
                  label: l.home_total_card_tips,
                  value: UIUtils.formatCurrency(point.tips, symbol: symbol),
                  color: AppTheme.profit,
                ),
              _DetailSubItem(
                label: l.analytics_stat_avg_rate,
                value: UIUtils.formatCurrency(
                  point.effectiveHourlyRate,
                  symbol: symbol,
                ),
                isBold: true,
              ),
              _DetailSubItem(
                label: l.common_net,
                value: UIUtils.formatCurrency(point.totalNet, symbol: symbol),
                isBold: true,
                color: AppTheme.primaryDark,
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
  final bool isBold;
  final Color? color;

  const _DetailSubItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
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
