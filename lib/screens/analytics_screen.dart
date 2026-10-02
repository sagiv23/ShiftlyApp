import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/break_type.dart';
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

    final totalGross = totalBaseSalary + totalTips + totalIncomes;
    final grandTotalNet = totalGross - totalExpenses;
    final avgEffectiveRate = totalNetHours > 0
        ? (grandTotalNet / totalNetHours)
        : 0.0;
    final avgBaseRate = totalNetHours > 0
        ? (totalBaseSalary / totalNetHours)
        : 0.0;
    final rateBoost = avgEffectiveRate - avgBaseRate;
    final retentionPct = totalGross > 0
        ? ((grandTotalNet / totalGross) * 100)
        : 100.0;
    final tipYieldPerHour = totalNetHours > 0
        ? (totalTips / totalNetHours)
        : 0.0;

    // Monthly Projection
    double projectedEom = grandTotalNet;
    if (_periodMode == AnalyticsPeriodMode.monthly) {
      final now = DateTime.now();
      final daysInMonth = DateUtils.getDaysInMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      if (_selectedDate.year == now.year && _selectedDate.month == now.month) {
        final daysPassed = now.day.clamp(1, daysInMonth);
        final dailyPace = grandTotalNet / daysPassed;
        projectedEom = dailyPace * daysInMonth;
      }
    }

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
      l,
    );

    // Prepare Time of Day Segments
    final todSegments = _generateTimeOfDaySegments(
      filteredShifts,
      shiftProvider,
      l,
    );

    // Prepare Shift Duration Categories
    final durationCategories = _generateDurationCategories(
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

    final todCard = todSegments.isNotEmpty
        ? _buildTimeOfDayCard(
            context,
            l: l,
            symbol: symbol,
            segments: todSegments,
          )
        : null;

    final durationCard = durationCategories.isNotEmpty
        ? _buildDurationCard(
            context,
            l: l,
            symbol: symbol,
            categories: durationCategories,
          )
        : null;

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

    final smartInsightsCard = _buildSmartInsightsCard(
      context,
      l: l,
      symbol: symbol,
      retentionPct: retentionPct,
      rateBoost: rateBoost,
      totalTips: totalTips,
      totalNet: grandTotalNet,
      durationCategories: durationCategories,
      todSegments: todSegments,
    );

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
                projectedEom: projectedEom,
                retentionPct: retentionPct,
                tipYield: tipYieldPerHour,
                rateBoost: rateBoost,
                netExtras: totalTips + totalIncomes - totalExpenses,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // 3. Smart Insights Card
              if (shiftCount > 0) ...[
                smartInsightsCard,
                const SizedBox(height: AppTheme.spaceMd),
              ],

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

                // Row 2: Time of Day Breakdown & Shift Duration Distribution
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

                // Row 3: Job Donut Card
                if (jobDonutCard != null) ...[
                  jobDonutCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
              ] else ...[
                // Mobile Stacked Cards
                earningsBarCard,
                const SizedBox(height: AppTheme.spaceSm),
                cumulativeLineCard,
                const SizedBox(height: AppTheme.spaceSm),
                if (todCard != null) ...[
                  todCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (durationCard != null) ...[
                  durationCard,
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (jobDonutCard != null) ...[
                  jobDonutCard,
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
                    tooltip: l.common_previous,
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
                    tooltip: l.common_next,
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
    required double projectedEom,
    required double retentionPct,
    required double tipYield,
    required double rateBoost,
    required double netExtras,
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
              subtitle: _periodMode == AnalyticsPeriodMode.monthly
                  ? '${l.analytics_kpi_projected}: ${UIUtils.formatCurrency(projectedEom, symbol: symbol)}'
                  : '$shiftCount ${l.common_shifts_count}',
              icon: Icons.account_balance_wallet_rounded,
              gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_stat_avg_rate,
              value: UIUtils.formatCurrency(avgRate, symbol: symbol),
              subtitle: rateBoost > 0
                  ? l.analytics_rate_boost_subtitle(
                UIUtils.formatCurrency(rateBoost, symbol: symbol),
              )
                  : l.analytics_base_salary,
              icon: Icons.trending_up_rounded,
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_kpi_retention,
              value: '${retentionPct.toStringAsFixed(1)}%',
              subtitle: l.analytics_retention_subtitle,
              icon: Icons.savings_rounded,
              gradientColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              isDark: isDark,
            ),
            _KpiCard(
              title: l.analytics_stat_tips,
              value: UIUtils.formatCurrency(netExtras, symbol: symbol),
              subtitle: totalNet > 0
                  ? l.analytics_net_extras_pct_subtitle(
                ((netExtras / totalNet) * 100).toStringAsFixed(0),
              )
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

  Widget _buildSmartInsightsCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required double retentionPct,
    required double rateBoost,
    required double totalTips,
    required double totalNet,
    required List<ShiftDurationCategory> durationCategories,
    required List<TimeOfDaySegment> todSegments,
  }) {
    final insights = <String>[];

    // Insight 1: Night/Evening hours ratio
    double totalTodHours = 0;
    for (var s in todSegments) {
      totalTodHours += s.hours;
    }
    if (totalTodHours > 0) {
      final nightAndEvening = todSegments
          .where((s) => s.icon != Icons.wb_sunny_rounded)
          .fold<double>(0, (sum, s) => sum + s.hours);
      final eveningPct = (nightAndEvening / totalTodHours * 100).round();
      if (eveningPct > 20) {
        insights.add(
          l.analytics_insight_night_boost.replaceFirst(
            '[[percent]]',
            '$eveningPct',
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

    return Card(
      color: AppTheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l.analytics_insights_title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 13, height: 1.3),
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

  Widget _buildTimeOfDayCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<TimeOfDaySegment> segments,
  }) {
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

            TimeOfDayChartWidget(segments: segments, currencySymbol: symbol),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(
    BuildContext context, {
    required AppLocalizations l,
    required String symbol,
    required List<ShiftDurationCategory> categories,
  }) {
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
              categories: categories,
              currencySymbol: symbol,
            ),
          ],
        ),
      ),
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
                    _LegendDot(color: AppTheme.primary,
                        label: l.analytics_base_salary),
                    const SizedBox(width: 8),
                    _LegendDot(color: AppTheme.profit,
                        label: l.analytics_tips_and_extra),
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
                isMonthMode: _periodMode != AnalyticsPeriodMode.monthly,
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
        : l.analytics_hours_suffix_format(totalHours.toStringAsFixed(1));

    final centerSubtitle =
    _byEarningsForJobs ? l.analytics_stat_total_net : l
        .analytics_stat_total_hours;

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
                                  : l.analytics_hours_suffix_format(
                                      seg.hours.toStringAsFixed(1),
                                    ),
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

  // --- Helper Data Generators ---

  List<BarDataPoint> _generateBarDataPoints(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    final Map<String, List<Shift>> grouped = {};

    if (_periodMode == AnalyticsPeriodMode.monthly) {
      final daysInMonth = DateUtils.getDaysInMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      for (int d = 1; d <= daysInMonth; d++) {
        grouped[d.toString()] = [];
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
    AppLocalizations l,
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
      final jobName = job?.name ?? l.common_unknown_job;
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

  List<TimeOfDaySegment> _generateTimeOfDaySegments(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    double morningMinutes = 0;
    double eveningMinutes = 0;
    double nightMinutes = 0;

    for (var s in shifts) {
      DateTime current = s.startTime;
      final end = s.endTime.isBefore(s.startTime)
          ? s.endTime.add(const Duration(days: 1))
          : s.endTime;

      final totalShiftMins = end.difference(s.startTime).inMinutes.toDouble();
      if (totalShiftMins <= 0) continue;

      double unpaidBreakRatio = 1.0;
      if ((s.breakType ?? BreakType.none) == BreakType.unpaid) {
        final unpaidMins = s.unpaidBreakMinutes ?? 45.0;
        final netMins = totalShiftMins - unpaidMins;
        if (netMins > 0) {
          unpaidBreakRatio = netMins / totalShiftMins;
        } else {
          unpaidBreakRatio = 0.0;
        }
      }

      int mCount = 0, eCount = 0, nCount = 0;
      while (current.isBefore(end)) {
        final hour = current.hour;
        if (hour >= 6 && hour < 14) {
          mCount++;
        } else if (hour >= 14 && hour < 20) {
          eCount++;
        } else {
          nCount++;
        }
        current = current.add(const Duration(minutes: 1));
      }

      morningMinutes += mCount * unpaidBreakRatio;
      eveningMinutes += eCount * unpaidBreakRatio;
      nightMinutes += nCount * unpaidBreakRatio;
    }

    final morningHours = morningMinutes / 60.0;
    final eveningHours = eveningMinutes / 60.0;
    final nightHours = nightMinutes / 60.0;

    return [
      TimeOfDaySegment(
        name: l.analytics_chart_tod_morning,
        timeRange: '06:00-14:00',
        hours: morningHours,
        color: const Color(0xFFF59E0B),
        // Amber Sun
        icon: Icons.wb_sunny_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_evening,
        timeRange: '14:00-20:00',
        hours: eveningHours,
        color: const Color(0xFF0284C7),
        // Sky Blue
        icon: Icons.wb_twilight_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_night,
        timeRange: '20:00-06:00',
        hours: nightHours,
        color: const Color(0xFF6366F1),
        // Deep Indigo
        icon: Icons.nightlight_round,
      ),
    ];
  }

  List<ShiftDurationCategory> _generateDurationCategories(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    AppLocalizations l,
  ) {
    int shortCount = 0, stdCount = 0, longCount = 0;
    double shortHours = 0, stdHours = 0, longHours = 0;
    double shortPay = 0, stdPay = 0, longPay = 0;

    for (var s in shifts) {
      final job = shiftProvider.getJobTypeById(s.jobTypeId);
      final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
      final pay = s.calculateTotalPay(rate);

      if (s.netHours < 6) {
        shortCount++;
        shortHours += s.netHours;
        shortPay += pay;
      } else if (s.netHours <= 9) {
        stdCount++;
        stdHours += s.netHours;
        stdPay += pay;
      } else {
        longCount++;
        longHours += s.netHours;
        longPay += pay;
      }
    }

    return [
      ShiftDurationCategory(
        label: l.analytics_duration_short,
        durationRange: l.analytics_duration_range_short,
        count: shortCount,
        hours: shortHours,
        avgEarnings: shortCount > 0 ? (shortPay / shortCount) : 0,
        color: const Color(0xFF10B981),
        // Green
        icon: Icons.bolt_rounded,
      ),
      ShiftDurationCategory(
        label: l.analytics_duration_standard,
        durationRange: l.analytics_duration_range_standard,
        count: stdCount,
        hours: stdHours,
        avgEarnings: stdCount > 0 ? (stdPay / stdCount) : 0,
        color: const Color(0xFF0284C7),
        // Blue
        icon: Icons.timer_outlined,
      ),
      ShiftDurationCategory(
        label: l.analytics_duration_long,
        durationRange: l.analytics_duration_range_long,
        count: longCount,
        hours: longHours,
        avgEarnings: longCount > 0 ? (longPay / longCount) : 0,
        color: const Color(0xFFEF4444),
        // Red/Warning
        icon: Icons.warning_amber_rounded,
      ),
    ];
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
        : DateFormat('dd/MM/yyyy').format(point.date);

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
