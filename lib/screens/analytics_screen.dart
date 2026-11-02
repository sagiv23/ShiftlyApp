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
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/analytics/analytics_earnings_section.dart';
import 'package:shiftly/widgets/analytics/analytics_hero.dart';
import 'package:shiftly/widgets/analytics/analytics_nav.dart';
import 'package:shiftly/widgets/analytics/analytics_overview_section.dart';
import 'package:shiftly/widgets/analytics/analytics_pay_breakdown_section.dart';
import 'package:shiftly/widgets/analytics/analytics_smart_insights.dart';
import 'package:shiftly/widgets/analytics/analytics_work_patterns_section.dart';
import 'package:shiftly/widgets/analytics_charts.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';

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
  int _activeSectionIndex =
      0; // 0: Overview, 1: Earnings, 2: Work Patterns, 3: Pay Breakdown

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _earningsKey = GlobalKey();
  final GlobalKey _workPatternsKey = GlobalKey();
  final GlobalKey _payBreakdownKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  void _scrollToSection(int index) {
    setState(() {
      _activeSectionIndex = index;
    });

    GlobalKey? targetKey;
    switch (index) {
      case 0:
        targetKey = _overviewKey;
        break;
      case 1:
        targetKey = _earningsKey;
        break;
      case 2:
        targetKey = _workPatternsKey;
        break;
      case 3:
        targetKey = _payBreakdownKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
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
    double totalRegularHours = 0;
    double totalRegularEarnings = 0;
    double totalTier1Hours = 0;
    double totalTier1Earnings = 0;
    double totalTier2Hours = 0;
    double totalTier2Earnings = 0;
    double totalOvertimeHours = 0;
    double totalShabbatHours = 0;
    double totalShabbatEarnings = 0;
    double totalHolidayHours = 0;
    double totalHolidayEarnings = 0;
    final shiftCount = filteredShifts.length;

    for (var shift in filteredShifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
          job?.getRateForDate(shift.date) ??
          AppConstants.defaultHourlyRate;
      totalNetHours += shift.netHours;
      totalBaseSalary += shift.calculateBaseSalary(
        rate,
        rules: settings.overtimeRules,
        shabbatRules: settings.shabbatHolidayRules,
      );
      totalTips += shift.tips;
      totalExpenses += shift.totalAutomaticExpenses;
      totalIncomes += shift.totalAutomaticIncomes;

      final breakdown = shift.getSalaryBreakdown(
        rules: settings.overtimeRules,
        shabbatRules: settings.shabbatHolidayRules,
      );
      totalRegularHours += breakdown.regularHours;
      totalRegularEarnings += breakdown.regularEarnings;
      totalTier1Hours += breakdown.tier1Hours;
      totalTier1Earnings += breakdown.tier1Earnings;
      totalTier2Hours += breakdown.tier2Hours;
      totalTier2Earnings += breakdown.tier2Earnings;
      totalOvertimeHours += breakdown.totalOvertimeHours;
      totalShabbatHours += breakdown.shabbatHours;
      totalShabbatEarnings += breakdown.shabbatEarnings;
      totalHolidayHours += breakdown.holidayHours;
      totalHolidayEarnings += breakdown.holidayEarnings;
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
      settings,
      l,
    );

    // Prepare Cumulative Growth Data
    final cumulativeData = _generateCumulativeData(barDataPoints);

    // Prepare Donut Chart Data
    final donutSegments = _generateDonutSegments(
      filteredShifts,
      shiftProvider,
      settings,
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
      settings,
      l,
    );

    return AdaptiveScaffold(
      currentIndex: 1,
      title: l.analytics_title,
      body: SafeArea(
        bottom: true,
        child: shiftProvider.isLoading && shiftProvider.shifts.isEmpty
            ? const AnalyticsScreenSkeleton()
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceSm,
                  AppTheme.spaceXs,
                  AppTheme.spaceSm,
                  AppTheme.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Signature Hero Section
                    PageEntranceAnimation(
                      delayFraction: 0.0,
                      child: AnalyticsHero(
                        periodMode: _periodMode,
                        selectedDate: _selectedDate,
                        selectedJobId: _selectedJobId,
                        jobTypes: jobTypes,
                        totalNet: grandTotalNet,
                        totalBaseSalary: totalBaseSalary,
                        totalTips: totalTips,
                        totalIncomes: totalIncomes,
                        totalExpenses: totalExpenses,
                        totalHours: totalNetHours,
                        avgRate: avgEffectiveRate,
                        shiftCount: shiftCount,
                        projectedEom: projectedEom,
                        retentionPct: retentionPct,
                        rateBoost: rateBoost,
                        symbol: symbol,
                        onPeriodChanged: _changePeriod,
                        onPreviousPeriod: _previousPeriod,
                        onNextPeriod: _nextPeriod,
                        onJobChanged: (val) {
                          setState(() {
                            _selectedJobId = val;
                            _selectedBarIndex = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),

                    // 2. Quick Navigation Section Bar ("Explore Your Data")
                    PageEntranceAnimation(
                      delayFraction: 0.1,
                      child: AnalyticsNav(
                        selectedIndex: _activeSectionIndex,
                        onSectionSelected: _scrollToSection,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),

                    // 3. Smart Insights Card
                    if (shiftCount > 0) ...[
                      PageEntranceAnimation(
                        delayFraction: 0.15,
                        child: AnalyticsSmartInsights(
                          l: l,
                          symbol: symbol,
                          retentionPct: retentionPct,
                          rateBoost: rateBoost,
                          totalTips: totalTips,
                          totalNet: grandTotalNet,
                          durationCategories: durationCategories,
                          todSegments: todSegments,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                    ],

                    // Main Analytics Sections
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION C: OVERVIEW
                        Container(key: _overviewKey),
                        _SectionHeading(
                          title: l.analytics_section_overview,
                          icon: Icons.grid_view_rounded,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        AnalyticsOverviewSection(
                          l: l,
                          symbol: symbol,
                          totalNet: grandTotalNet,
                          totalBaseSalary: totalBaseSalary,
                          totalTips: totalTips,
                          totalIncomes: totalIncomes,
                          totalExpenses: totalExpenses,
                          totalHours: totalNetHours,
                          avgRate: avgEffectiveRate,
                          shiftCount: shiftCount,
                          projectedEom: projectedEom,
                          retentionPct: retentionPct,
                          rateBoost: rateBoost,
                          isMonthly: _periodMode == AnalyticsPeriodMode.monthly,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),

                        // SECTION D: EARNINGS
                        Container(key: _earningsKey),
                        _SectionHeading(
                          title: l.analytics_section_earnings,
                          icon: Icons.payments_rounded,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        AnalyticsEarningsSection(
                          l: l,
                          symbol: symbol,
                          dataPoints: barDataPoints,
                          selectedBarIndex: _selectedBarIndex,
                          onBarSelected: (idx) {
                            setState(() => _selectedBarIndex = idx);
                          },
                          cumulativeData: cumulativeData,
                          isWideScreen: isWideScreen,
                          isMonthMode:
                              _periodMode != AnalyticsPeriodMode.monthly,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),

                        // SECTION E: WORK PATTERNS
                        if (todSegments.isNotEmpty ||
                            durationCategories.isNotEmpty ||
                            donutSegments.isNotEmpty) ...[
                          Container(key: _workPatternsKey),
                          _SectionHeading(
                            title: l.analytics_section_work_patterns,
                            icon: Icons.schedule_rounded,
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          AnalyticsWorkPatternsSection(
                            l: l,
                            symbol: symbol,
                            todSegments: todSegments,
                            durationCategories: durationCategories,
                            donutSegments: donutSegments,
                            jobTypes: jobTypes,
                            grandTotalNet: grandTotalNet,
                            totalNetHours: totalNetHours,
                            byEarningsForJobs: _byEarningsForJobs,
                            onToggleByEarnings: (val) {
                              setState(() => _byEarningsForJobs = val);
                            },
                            isWideScreen: isWideScreen,
                          ),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],

                        // SECTION F: PAY BREAKDOWN
                        if (totalRegularHours > 0 ||
                            totalOvertimeHours > 0 ||
                            totalShabbatHours > 0 ||
                            totalHolidayHours > 0) ...[
                          Container(key: _payBreakdownKey),
                          _SectionHeading(
                            title: l.analytics_section_pay_breakdown,
                            icon: Icons.receipt_long_rounded,
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          AnalyticsPayBreakdownSection(
                            l: l,
                            symbol: symbol,
                            totalRegularHours: totalRegularHours,
                            totalRegularEarnings: totalRegularEarnings,
                            totalTier1Hours: totalTier1Hours,
                            totalTier1Earnings: totalTier1Earnings,
                            totalTier2Hours: totalTier2Hours,
                            totalTier2Earnings: totalTier2Earnings,
                            totalShabbatHours: totalShabbatHours,
                            totalShabbatEarnings: totalShabbatEarnings,
                            totalHolidayHours: totalHolidayHours,
                            totalHolidayEarnings: totalHolidayEarnings,
                          ),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- Helper Data Generators ---

  List<BarDataPoint> _generateBarDataPoints(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    SettingsProvider settings,
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
          final rate =
              s.hourlyRate ??
              job?.getRateForDate(s.date) ??
              AppConstants.defaultHourlyRate;
          hours += s.netHours;
          base += s.calculateBaseSalary(
            rate,
            rules: settings.overtimeRules,
            shabbatRules: settings.shabbatHolidayRules,
          );
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
          final rate =
              s.hourlyRate ??
              job?.getRateForDate(s.date) ??
              AppConstants.defaultHourlyRate;
          hours += s.netHours;
          base += s.calculateBaseSalary(
            rate,
            rules: settings.overtimeRules,
            shabbatRules: settings.shabbatHolidayRules,
          );
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
          final rate =
              s.hourlyRate ??
              job?.getRateForDate(s.date) ??
              AppConstants.defaultHourlyRate;
          hours += s.netHours;
          base += s.calculateBaseSalary(
            rate,
            rules: settings.overtimeRules,
            shabbatRules: settings.shabbatHolidayRules,
          );
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
    SettingsProvider settings,
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
        final rate =
            s.hourlyRate ??
            job?.getRateForDate(s.date) ??
            AppConstants.defaultHourlyRate;
        jobPay += s.calculateTotalPay(
          rate,
          rules: settings.overtimeRules,
          shabbatRules: settings.shabbatHolidayRules,
        );
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
    double dawnMinutes = 0;
    double morningMinutes = 0;
    double noonMinutes = 0;
    double afternoonMinutes = 0;
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

      int dawnCount = 0,
          mCount = 0,
          noonCount = 0,
          aftCount = 0,
          eCount = 0,
          nCount = 0;
      while (current.isBefore(end)) {
        final hour = current.hour;
        if (hour >= 22 || hour < 4) {
          nCount++;
        } else if (hour >= 4 && hour < 6) {
          dawnCount++;
        } else if (hour >= 6 && hour < 12) {
          mCount++;
        } else if (hour >= 12 && hour < 16) {
          noonCount++;
        } else if (hour >= 16 && hour < 18) {
          aftCount++;
        } else {
          eCount++;
        }
        current = current.add(const Duration(minutes: 1));
      }

      dawnMinutes += dawnCount * unpaidBreakRatio;
      morningMinutes += mCount * unpaidBreakRatio;
      noonMinutes += noonCount * unpaidBreakRatio;
      afternoonMinutes += aftCount * unpaidBreakRatio;
      eveningMinutes += eCount * unpaidBreakRatio;
      nightMinutes += nCount * unpaidBreakRatio;
    }

    final dawnHours = dawnMinutes / 60.0;
    final morningHours = morningMinutes / 60.0;
    final noonHours = noonMinutes / 60.0;
    final afternoonHours = afternoonMinutes / 60.0;
    final eveningHours = eveningMinutes / 60.0;
    final nightHours = nightMinutes / 60.0;

    return [
      TimeOfDaySegment(
        name: l.analytics_chart_tod_dawn,
        timeRange: '04:00-06:00',
        hours: dawnHours,
        color: const Color(0xFFFF7043),
        icon: Icons.wb_twilight_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_morning,
        timeRange: '06:00-12:00',
        hours: morningHours,
        color: const Color(0xFFF59E0B),
        icon: Icons.wb_sunny_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_noon,
        timeRange: '12:00-16:00',
        hours: noonHours,
        color: const Color(0xFF00ACC1),
        icon: Icons.light_mode_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_afternoon,
        timeRange: '16:00-18:00',
        hours: afternoonHours,
        color: const Color(0xFF388E3C),
        icon: Icons.wb_twilight,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_evening,
        timeRange: '18:00-22:00',
        hours: eveningHours,
        color: const Color(0xFF0284C7),
        icon: Icons.nights_stay_rounded,
      ),
      TimeOfDaySegment(
        name: l.analytics_chart_tod_night,
        timeRange: '22:00-04:00',
        hours: nightHours,
        color: const Color(0xFF6366F1),
        icon: Icons.nightlight_round,
      ),
    ];
  }

  List<ShiftDurationCategory> _generateDurationCategories(
    List<Shift> shifts,
    ShiftProvider shiftProvider,
    SettingsProvider settings,
    AppLocalizations l,
  ) {
    int shortCount = 0, stdCount = 0, longCount = 0;
    double shortHours = 0, stdHours = 0, longHours = 0;
    double shortPay = 0, stdPay = 0, longPay = 0;

    for (var s in shifts) {
      final job = shiftProvider.getJobTypeById(s.jobTypeId);
      final rate =
          s.hourlyRate ??
          job?.getRateForDate(s.date) ??
          AppConstants.defaultHourlyRate;
      final pay = s.calculateTotalPay(
        rate,
        rules: settings.overtimeRules,
        shabbatRules: settings.shabbatHolidayRules,
      );

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
        icon: Icons.bolt_rounded,
      ),
      ShiftDurationCategory(
        label: l.analytics_duration_standard,
        durationRange: l.analytics_duration_range_standard,
        count: stdCount,
        hours: stdHours,
        avgEarnings: stdCount > 0 ? (stdPay / stdCount) : 0,
        color: const Color(0xFF0284C7),
        icon: Icons.timer_outlined,
      ),
      ShiftDurationCategory(
        label: l.analytics_duration_long,
        durationRange: l.analytics_duration_range_long,
        count: longCount,
        hours: longHours,
        avgEarnings: longCount > 0 ? (longPay / longCount) : 0,
        color: const Color(0xFFEF4444),
        icon: Icons.warning_amber_rounded,
      ),
    ];
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.electricCyan),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.primaryText : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
