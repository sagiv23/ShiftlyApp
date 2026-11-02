import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/shift_tile.dart';

/// A fluid Apple-style Tab Layout divided by Years and Months.
/// Allows browsing shifts and monthly financial summaries with intuitive physics
/// and instant visual feedback.
class YearMonthTabLayout extends StatefulWidget {
  final ScrollController? scrollController;
  final Map<String, List<Shift>> groupedShifts;
  final String currentMonthKey;
  final int? initialYear;
  final int? initialMonth;

  const YearMonthTabLayout({
    super.key,
    this.scrollController,
    required this.groupedShifts,
    required this.currentMonthKey,
    this.initialYear,
    this.initialMonth,
  });

  @override
  State<YearMonthTabLayout> createState() => _YearMonthTabLayoutState();
}

class _YearMonthTabLayoutState extends State<YearMonthTabLayout> {
  late int _selectedYear;
  late int _selectedMonth;
  late List<int> _availableYears;
  final ScrollController _monthScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Extract all unique years from grouped shifts or include current year
    final yearsSet = <int>{now.year};
    for (final key in widget.groupedShifts.keys) {
      final parts = key.split('-');
      if (parts.isNotEmpty) {
        final year = int.tryParse(parts[0]);
        if (year != null) yearsSet.add(year);
      }
    }
    _availableYears = yearsSet.toList()..sort((a, b) => b.compareTo(a));

    // Default to initial year & month if provided, otherwise current year & month
    _selectedYear =
        widget.initialYear ??
        (_availableYears.contains(now.year) ? now.year : _availableYears.first);
    _selectedMonth = widget.initialMonth ?? now.month;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
  }

  @override
  void didUpdateWidget(YearMonthTabLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.initialYear != null &&
            widget.initialYear != oldWidget.initialYear) ||
        (widget.initialMonth != null &&
            widget.initialMonth != oldWidget.initialMonth)) {
      setState(() {
        if (widget.initialYear != null) _selectedYear = widget.initialYear!;
        if (widget.initialMonth != null) _selectedMonth = widget.initialMonth!;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedMonth();
      });
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedMonth() {
    if (!_monthScrollController.hasClients) return;
    final maxScroll = _monthScrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final targetOffset = ((_selectedMonth - 1) / 11.0) * maxScroll;
    _monthScrollController.animateTo(
      targetOffset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  String get _currentKey =>
      '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';

  List<Shift> _getShiftsForSelectedMonth(ShiftProvider shiftProvider) {
    return shiftProvider.filteredShifts.where((shift) {
      return shift.date.year == _selectedYear &&
          shift.date.month == _selectedMonth;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  int _getShiftCountForMonth(ShiftProvider shiftProvider, int year, int month) {
    return shiftProvider.filteredShifts.where((shift) {
      return shift.date.year == year && shift.date.month == month;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shiftsForMonth = _getShiftsForSelectedMonth(shiftProvider);

    // Calculate totals for selected month
    double monthHours = 0;
    double monthGross = 0;
    double monthTips = 0;
    double monthExpenses = 0;
    double monthIncomes = 0;

    for (final shift in shiftsForMonth) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      monthHours += shift.netHours;
      monthGross += shift.calculateBaseSalary(
        rate,
        rules: settingsProvider.overtimeRules,
        shabbatRules: settingsProvider.shabbatHolidayRules,
      );
      monthTips += shift.tips;
      monthExpenses += shift.totalAutomaticExpenses;
      monthIncomes += shift.totalAutomaticIncomes;
    }

    final monthKey = _currentKey;
    final extraExpenses = shiftProvider.expensesGroupedByMonth[monthKey] ?? [];
    for (final expense in extraExpenses) {
      monthExpenses += expense.amount;
    }

    final extraIncomes = shiftProvider.incomesGroupedByMonth[monthKey] ?? [];
    for (final income in extraIncomes) {
      monthIncomes += income.amount;
    }

    int totalShiftsCount = shiftsForMonth.length;
    if (timerProvider.startTime != null &&
        timerProvider.startTime!.year == _selectedYear &&
        timerProvider.startTime!.month == _selectedMonth) {
      totalShiftsCount += 1;
      final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
      final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
      monthHours += timerProvider.netMinutes / 60.0;
      monthGross += (timerProvider.netMinutes / 60.0) * rate;
      monthTips += timerProvider.tips;
      if (settingsProvider.automaticExpenseEnabled) {
        for (final e in settingsProvider.defaultAutomaticExpenses) {
          monthExpenses += e.amount;
        }
      }
    }

    final monthNet = monthGross + monthTips + monthIncomes - monthExpenses;
    final date = DateTime(_selectedYear, _selectedMonth);
    final monthFullName = DateFormat.MMMM(l.localeName).format(date);

    return ListView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceXl,
      ),
      children: [
        // Year Tabs Segment
        _buildYearTabs(context, isDark),

        const SizedBox(height: AppTheme.spaceSm),

        // Month Tabs Segment
        _buildMonthTabs(context, shiftProvider, isDark, l),

        const SizedBox(height: AppTheme.spaceMd),

        // Month Snapshot Summary Header
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildMonthSummaryCard(
            summaryKey: ValueKey('summary_$_currentKey'),
            context: context,
            monthName: monthFullName,
            year: _selectedYear,
            net: monthNet,
            gross: monthGross,
            hours: monthHours,
            shiftCount: totalShiftsCount,
            tips: monthTips,
            expenses: monthExpenses,
            incomes: monthIncomes,
            isDark: isDark,
            l: l,
          ),
        ),

        const SizedBox(height: AppTheme.spaceMd),

        // Shifts List or Empty State
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: shiftsForMonth.isEmpty
              ? Padding(
                  key: ValueKey('empty_$_currentKey'),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: EmptyStateWidget(
                    title: l.home_shift_list_no_shifts,
                    subtitle:
                        '${l.home_shift_list_shifts_on} $monthFullName $_selectedYear',
                  ),
                )
              : Container(
                  key: ValueKey('list_$_currentKey'),
                  decoration: AppTheme.sectionDecoration(context),
                  child: Column(
                    children: [
                      for (var i = 0; i < shiftsForMonth.length; i++) ...[
                        ShiftTile(shift: shiftsForMonth[i]),
                        if (i < shiftsForMonth.length - 1)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Apple-style horizontal year selector tabs with auto-centering & fluid scroll
  Widget _buildYearTabs(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard.withValues(alpha: 0.8)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: (constraints.maxWidth - 8).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final year in _availableYears) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedYear = year;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToSelectedMonth();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.fastOutSlowIn,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: year == _selectedYear
                                  ? (isDark
                                        ? AppTheme.electricCyan.withValues(
                                            alpha: 0.25,
                                          )
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              border: year == _selectedYear
                                  ? Border.all(
                                      color: AppTheme.electricCyan.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.2,
                                    )
                                  : null,
                              boxShadow: year == _selectedYear
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.electricCyan.withValues(
                                          alpha: isDark ? 0.2 : 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontWeight: year == _selectedYear
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: year == _selectedYear
                                      ? AppTheme.electricCyan
                                      : (isDark
                                            ? AppTheme.secondaryText
                                            : const Color(0xFF64748B)),
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Apple-style horizontal 12-months selector sub-tabs with auto-centering & fluid scroll
  Widget _buildMonthTabs(
    BuildContext context,
    ShiftProvider shiftProvider,
    bool isDark,
    AppLocalizations l,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              controller: _monthScrollController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: (constraints.maxWidth - 4).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int index = 0; index < 12; index++)
                      Builder(
                        builder: (context) {
                          final monthNum = index + 1;
                          final isSelected = monthNum == _selectedMonth;
                          final date = DateTime(_selectedYear, monthNum);
                          final monthShortName = DateFormat.MMM(
                            l.localeName,
                          ).format(date);
                          final shiftCount = _getShiftCountForMonth(
                            shiftProvider,
                            _selectedYear,
                            monthNum,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _selectedMonth = monthNum;
                                });
                                _scrollToSelectedMonth();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.fastOutSlowIn,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.electricCyan
                                      : (isDark
                                            ? AppTheme.darkCard.withValues(
                                                alpha: 0.6,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.7,
                                              )),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.electricCyan
                                                .withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      monthShortName,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.black
                                            : (isDark
                                                  ? AppTheme.primaryText
                                                  : const Color(0xFF334155)),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    if (shiftCount > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.black.withValues(
                                                  alpha: 0.25,
                                                )
                                              : AppTheme.electricCyan
                                                    .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                        child: Text(
                                          '$shiftCount',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? Colors.black
                                                : AppTheme.electricCyan,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Overview snapshot card for selected month & year
  Widget _buildMonthSummaryCard({
    required Key summaryKey,
    required BuildContext context,
    required String monthName,
    required int year,
    required double net,
    required double gross,
    required double hours,
    required int shiftCount,
    required double tips,
    required double expenses,
    required double incomes,
    required bool isDark,
    required AppLocalizations l,
  }) {
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final monthKey = _currentKey;
    final hasAnimated = AnimationCache.animatedMonthKeys.contains(monthKey);
    final duration = hasAnimated
        ? Duration.zero
        : const Duration(milliseconds: 600);

    return Container(
      key: summaryKey,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [const Color(0xFF1E293B), AppTheme.darkCard]
              : [Colors.white, const Color(0xFFE8F8FB)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: isDark ? .28 : .22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricCyan.withValues(alpha: isDark ? .10 : .06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$monthName $year',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.electricCyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.electricCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: hasAnimated ? shiftCount.toDouble() : 0.0,
                    end: shiftCount.toDouble(),
                  ),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  onEnd: () {
                    if (!hasAnimated) {
                      AnimationCache.animatedMonthKeys.add(monthKey);
                    }
                  },
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()} ${l.common_shifts_count}',
                      style: const TextStyle(
                        color: AppTheme.electricCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.common_net,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: hasAnimated ? net : 0.0,
                        end: net,
                      ),
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      onEnd: () {
                        if (!hasAnimated) {
                          AnimationCache.animatedMonthKeys.add(monthKey);
                        }
                      },
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            UIUtils.formatCurrency(value, symbol: symbol),
                            style: UIUtils.getCurrencyStyle(
                              context,
                              value,
                              baseStyle: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                              positiveColor: AppTheme.profit,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l.analytics_gross_pay,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: hasAnimated ? gross : 0.0,
                        end: gross,
                      ),
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      onEnd: () {
                        if (!hasAnimated) {
                          AnimationCache.animatedMonthKeys.add(monthKey);
                        }
                      },
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            UIUtils.formatCurrency(value, symbol: symbol),
                            style: UIUtils.getCurrencyStyle(
                              context,
                              value,
                              baseStyle: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              positiveColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l.home_total_card_hours,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: hasAnimated ? hours : 0.0,
                        end: hours,
                      ),
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      onEnd: () {
                        if (!hasAnimated) {
                          AnimationCache.animatedMonthKeys.add(monthKey);
                        }
                      },
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '${value.toStringAsFixed(1)} ${l.common_hours_suffix}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tips > 0 || incomes > 0 || expenses > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (tips > 0)
                  _PillBadge(
                    label: l.home_total_card_tips,
                    amount: tips,
                    color: AppTheme.mintGreen,
                    symbol: symbol,
                  ),
                if (incomes > 0)
                  _PillBadge(
                    label: l.expenses_tab_incomes,
                    amount: incomes,
                    color: AppTheme.electricCyan,
                    symbol: symbol,
                  ),
                if (expenses > 0)
                  _PillBadge(
                    label: l.home_total_card_expenses,
                    amount: -expenses,
                    color: AppTheme.softCoral,
                    symbol: symbol,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String symbol;

  const _PillBadge({
    required this.label,
    required this.amount,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label ${UIUtils.formatCurrency(amount, symbol: symbol)}',
        style: UIUtils.getCurrencyStyle(
          context,
          amount,
          baseStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          positiveColor: color,
        ),
      ),
    );
  }
}
