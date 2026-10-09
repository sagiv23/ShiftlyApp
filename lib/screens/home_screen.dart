import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/export_bottom_sheet.dart';
import 'package:shiftly/widgets/grand_total_card.dart';
import 'package:shiftly/widgets/shift_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final auth = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context)!;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;

    double grandTotalNetHours = 0;
    double grandTotalBaseSalary = 0;
    double grandTotalTips = 0;
    double grandTotalExpenses = 0;
    double grandTotalIncomes = 0;
    int grandTotalShifts = shiftProvider.filteredShifts.length;

    for (var shift in shiftProvider.filteredShifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      grandTotalNetHours += shift.netHours;
      grandTotalBaseSalary += shift.netHours * rate;
      grandTotalTips += shift.tips;
      grandTotalExpenses += shift.totalAutomaticExpenses;
      grandTotalIncomes += shift.totalAutomaticIncomes;
    }

    for (var expense in shiftProvider.expenses) {
      grandTotalExpenses += expense.amount;
    }

    for (var income in shiftProvider.incomes) {
      grandTotalIncomes += income.amount;
    }

    if (timerProvider.startTime != null) {
      grandTotalShifts += 1;
      final settings = context.read<SettingsProvider>();
      final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
      final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
      grandTotalNetHours += timerProvider.netMinutes / 60.0;
      grandTotalBaseSalary += (timerProvider.netMinutes / 60.0) * rate;
      grandTotalTips += timerProvider.tips;
      if (settings.automaticExpenseEnabled) {
        for (var e in settings.defaultAutomaticExpenses) {
          grandTotalExpenses += e.amount;
        }
      }
    }

    return AdaptiveScaffold(
      currentIndex: 2,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l.common_app_name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (auth.isLoggedIn && auth.userName != null)
            Text(
              l.home_welcome_back.replaceFirst('[[name]]', auth.userName!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          tooltip: l.export_title,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ExportBottomSheet(),
          ),
        ),
        IconButton(
          icon: Icon(
            shiftProvider.activeFilter?.isActive == true
                ? Icons.filter_alt_rounded
                : Icons.filter_alt_outlined,
            color: shiftProvider.activeFilter?.isActive == true
                ? AppTheme.primary
                : null,
          ),
          tooltip: l.filter_title,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const _FilterBottomSheet(),
            );
          },
        ),
        const SizedBox(width: AppTheme.spaceXs),
      ],
      body: SafeArea(
        child: Column(
          children: [
            PageEntranceAnimation(
              delayFraction: 0.0,
              child: Column(
                children: [
                  if (timerProvider.startTime != null)
                    _ActiveTimerBanner(timer: timerProvider),
                  if (shiftProvider.activeFilter?.isActive == true)
                    const _ActiveFiltersBar(),
                ],
              ),
            ),
            Expanded(
              child: groupedShifts.isEmpty && timerProvider.startTime == null
                  ? (shiftProvider.activeFilter?.isActive == true
                        ? _FilterEmptyState()
                        : EmptyStateWidget(
                            title: l.home_empty_state_title,
                            subtitle: l.home_empty_state_subtitle,
                          ))
                  : PageEntranceAnimation(
                      delayFraction: 0.15,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spaceSm,
                          AppTheme.spaceXs,
                          AppTheme.spaceSm,
                          120, // Increased for ad space and system navigation
                        ),
                        itemCount: groupedShifts.isEmpty
                            ? 1
                            : groupedShifts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GrandTotalCard(
                              totalHours: grandTotalNetHours,
                              totalBase: grandTotalBaseSalary,
                              totalTips: grandTotalTips,
                              totalExpenses: grandTotalExpenses,
                              totalIncomes: grandTotalIncomes,
                              totalShifts: grandTotalShifts,
                            );
                          }
                          final monthKey = groupedShifts.keys.elementAt(
                            index - 1,
                          );
                          final shifts = groupedShifts[monthKey]!;
                          return _MonthExpansionSection(
                            monthKey: monthKey,
                            shifts: shifts,
                            initiallyExpanded: index == 1,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => Navigator.push(
          context,
          AppPageRoute.slideUp(const AddShiftScreen()),
        ),
        label: Text(l.home_action_new_shift),
        icon: const Icon(Icons.add_rounded),
        tooltip: l.home_action_new_shift,
      ),
    );
  }
}

class _ActiveTimerBanner extends StatelessWidget {
  final TimerProvider timer;

  const _ActiveTimerBanner({required this.timer});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final job = shiftProvider.getJobTypeById(timer.jobTypeId ?? "");
    final rate = timer.startTime != null
        ? (job?.getRateForDate(timer.startTime!) ?? 40.22)
        : (job?.hourlyRate ?? 40.22);
    final pay = timer.calculateLivePay(rate);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final d = timer.elapsed;
    final timeStr =
        "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";

    final isBreak = timer.isOnBreak;
    final accent = isBreak ? AppTheme.warningSoft : AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScalePress(
      onTap: () => Navigator.push(
        context,
        AppPageRoute.slideUp(const AddShiftScreen(initialTabIndex: 0)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppTheme.spaceSm,
          AppTheme.spaceXs,
          AppTheme.spaceSm,
          AppTheme.spaceSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBreak
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBreak
                        ? l.home_active_timer_break
                        : '${l.home_active_timer_active} ${job?.name ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? accent : accent.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l.home_active_timer_time} $timeStr  ·  ${UIUtils.formatCurrency(pay, symbol: symbol)}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: accent),
          ],
        ),
      ),
    );
  }
}

class _MonthExpansionSection extends StatelessWidget {
  final String monthKey;
  final List<Shift> shifts;
  final bool initiallyExpanded;

  const _MonthExpansionSection({
    required this.monthKey,
    required this.shifts,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;

    double totalNetHours = 0;
    double totalBaseSalary = 0;
    double totalTips = 0;
    double totalMonthExpenses = 0;
    double totalMonthIncomes = 0;
    int monthShiftCount = shifts.length;

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      totalNetHours += shift.netHours;
      totalBaseSalary += shift.netHours * rate;
      totalTips += shift.tips;
      totalMonthExpenses += shift.totalAutomaticExpenses;
      totalMonthIncomes += shift.totalAutomaticIncomes;
    }

    final allExpenses = shiftProvider.expensesGroupedByMonth[monthKey] ?? [];
    for (var expense in allExpenses) {
      totalMonthExpenses += expense.amount;
    }

    final allIncomes = shiftProvider.incomesGroupedByMonth[monthKey] ?? [];
    for (var income in allIncomes) {
      totalMonthIncomes += income.amount;
    }

    final date = DateTime.parse("$monthKey-01");
    final monthName = DateFormat.MMMM(l.localeName).format(date);
    final year = date.year;

    final timerProvider = context.watch<TimerProvider>();
    if (timerProvider.startTime != null &&
        timerProvider.startTime!.year == year &&
        timerProvider.startTime!.month == date.month) {
      monthShiftCount += 1;
      final settings = context.read<SettingsProvider>();
      final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
      final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
      totalNetHours += timerProvider.netMinutes / 60.0;
      totalBaseSalary += (timerProvider.netMinutes / 60.0) * rate;
      totalTips += timerProvider.tips;
      if (settings.automaticExpenseEnabled) {
        for (var e in settings.defaultAutomaticExpenses) {
          totalMonthExpenses += e.amount;
        }
      }
    }

    final net =
        totalBaseSalary + totalTips + totalMonthIncomes - totalMonthExpenses;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSm + 4,
            vertical: AppTheme.spaceXs,
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
          title: Text(
            "$monthName $year",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
              fontSize: 18,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "$monthShiftCount ${l.common_shifts_count}  · ${l.home_shift_list_net_total}: ${UIUtils.formatCurrency(net, symbol: symbol)} ·  ${totalNetHours.toStringAsFixed(2)} ${l.common_hours_suffix}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceSm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SummaryItem(
                          label: l.home_total_card_base,
                          value: UIUtils.formatCurrency(
                            totalBaseSalary,
                            symbol: symbol,
                          ),
                          amount: totalBaseSalary,
                        ),
                        if (totalTips > 0) ...[
                          const VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                          _SummaryItem(
                            label: l.home_total_card_tips,
                            value: UIUtils.formatCurrency(
                              totalTips,
                              symbol: symbol,
                            ),
                            amount: totalTips,
                            accent: AppTheme.profit,
                          ),
                        ],
                        if (totalMonthIncomes > 0) ...[
                          const VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                          _SummaryItem(
                            label: l.expenses_tab_incomes,
                            value: UIUtils.formatCurrency(
                              totalMonthIncomes,
                              symbol: symbol,
                            ),
                            amount: totalMonthIncomes,
                            accent: AppTheme.profit,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, indent: 10, endIndent: 10),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (totalMonthExpenses > 0) ...[
                          _SummaryItem(
                            label: l.home_total_card_expenses,
                            value: UIUtils.formatCurrency(
                              totalMonthExpenses,
                              symbol: symbol,
                            ),
                            amount: -totalMonthExpenses,
                          ),
                          const VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                          ),
                        ],
                        _SummaryItem(
                          label: l.common_net,
                          value: UIUtils.formatCurrency(net, symbol: symbol),
                          isBold: true,
                          amount: net,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...shifts.map((shift) => ShiftTile(shift: shift)),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double? amount;
  final Color? accent;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.amount,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    if ((amount ?? 0) < 0) {
      textColor = AppTheme.expense;
    } else if (isBold) {
      textColor = AppTheme.primaryDark;
    } else if (accent != null) {
      textColor = accent;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isBold ? 17 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.filter_list_off_rounded,
      title: l.filter_empty_state_title,
      subtitle: l.filter_empty_state_subtitle,
      action: TextButton.icon(
        onPressed: () => context.read<ShiftProvider>().clearFilter(),
        icon: const Icon(Icons.clear_all_rounded),
        label: Text(l.filter_clear_all),
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();
    final filter = provider.activeFilter;
    if (filter == null || !filter.isActive) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
        children: [
          Center(
            child: Text(
              l.filter_active_filters,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          if (filter.minWage != null || filter.maxWage != null)
            _ActiveFilterChip(
              label: l.filter_chip_wage
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minWage ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxWage ?? 5000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinWage: true, clearMaxWage: true),
              ),
            ),
          if (filter.minTips != null || filter.maxTips != null)
            _ActiveFilterChip(
              label: l.filter_chip_tips
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minTips ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxTips ?? 1000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinTips: true, clearMaxTips: true),
              ),
            ),
          if (filter.minExpenses != null || filter.maxExpenses != null)
            _ActiveFilterChip(
              label: l.filter_chip_expenses
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(
                      filter.minExpenses ?? 0,
                      symbol: symbol,
                    ),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxExpenses ?? 500,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinExpenses: true, clearMaxExpenses: true),
              ),
            ),
          if (filter.minDuration != null || filter.maxDuration != null)
            _ActiveFilterChip(
              label: l.filter_chip_duration
                  .replaceFirst(
                    '[[min]]',
                    (filter.minDuration ?? 0).toStringAsFixed(1),
                  )
                  .replaceFirst(
                    '[[max]]',
                    (filter.maxDuration ?? 24).toStringAsFixed(1),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinDuration: true, clearMaxDuration: true),
              ),
            ),
          if (filter.startDate != null || filter.endDate != null)
            _ActiveFilterChip(
              label: l.filter_chip_date
                  .replaceFirst(
                    '[[start]]',
                    filter.startDate != null
                        ? DateFormat('dd/MM').format(filter.startDate!)
                        : '...',
                  )
                  .replaceFirst(
                    '[[end]]',
                    filter.endDate != null
                        ? DateFormat('dd/MM').format(filter.endDate!)
                        : '...',
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearStartDate: true, clearEndDate: true),
              ),
            ),
          if (filter.typeIds != null && filter.typeIds!.isNotEmpty)
            _ActiveFilterChip(
              label: l.filter_chip_job.replaceFirst(
                '[[name]]',
                filter.typeIds!.length == 1
                    ? provider.getJobTypeById(filter.typeIds!.first)?.name ??
                          '?'
                    : '${filter.typeIds!.length} ${l.common_shifts_count}',
              ),
              onDeleted: () =>
                  provider.setFilter(filter.copyWith(clearTypeIds: true)),
            ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => provider.clearFilter(),
            child: Text(
              l.filter_clear_all,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _ActiveFilterChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ShiftFilter _filter;

  @override
  void initState() {
    super.initState();
    final active = context.read<ShiftProvider>().activeFilter;
    if (active != null) {
      _filter = active;
    } else {
      final jobTypes = context.read<ShiftProvider>().jobTypes;
      _filter = ShiftFilter(
        typeIds: jobTypes.isNotEmpty ? [jobTypes.first.id] : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final jobTypes = shiftProvider.jobTypes;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    // Calculate dynamic maximums
    double maxWage = shiftProvider.maxCapturedWage;
    if (maxWage == 0) maxWage = 500;

    double maxTips = shiftProvider.maxCapturedTips;
    if (maxTips == 0) maxTips = 500;

    double maxExpenses = shiftProvider.maxCapturedExpenses;
    if (maxExpenses == 0) maxExpenses = 500;

    double maxDuration = shiftProvider.maxCapturedDuration;
    if (maxDuration == 0) maxDuration = 24;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.filter_title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = ShiftFilter();
                    });
                  },
                  child: Text(
                    l.filter_clear_all,
                  ), // Label might be "איפוס סינון" in ARB
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                0,
                AppTheme.spaceMd,
                40, // Spacing for navigation buttons
              ),
              children: [
                _buildRangeSection(
                  title: l.filter_wage_range,
                  min: 0,
                  max: maxWage,
                  values: RangeValues(
                    (_filter.minWage ?? 0).clamp(0, maxWage),
                    (_filter.maxWage ?? maxWage).clamp(0, maxWage),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minWage: v.start,
                        maxWage: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_tips_range,
                  min: 0,
                  max: maxTips,
                  values: RangeValues(
                    (_filter.minTips ?? 0).clamp(0, maxTips),
                    (_filter.maxTips ?? maxTips).clamp(0, maxTips),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minTips: v.start,
                        maxTips: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_expenses_range,
                  min: 0,
                  max: maxExpenses,
                  values: RangeValues(
                    (_filter.minExpenses ?? 0).clamp(0, maxExpenses),
                    (_filter.maxExpenses ?? maxExpenses).clamp(0, maxExpenses),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minExpenses: v.start,
                        maxExpenses: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_duration_range,
                  min: 0,
                  max: maxDuration,
                  values: RangeValues(
                    (_filter.minDuration ?? 0).clamp(0, maxDuration),
                    (_filter.maxDuration ?? maxDuration).clamp(0, maxDuration),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minDuration: v.start,
                        maxDuration: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) => v.toStringAsFixed(1),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l.filter_date_range,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _filter.startDate != null && _filter.endDate != null
                          ? "${DateFormat.yMd().format(_filter.startDate!)} - ${DateFormat.yMd().format(_filter.endDate!)}"
                          : l.common_start,
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final range = await AppDatePicker.showDateRangePicker(
                        context: context,
                        initialDateRange:
                            _filter.startDate != null && _filter.endDate != null
                            ? DateTimeRange(
                                start: _filter.startDate!,
                                end: _filter.endDate!,
                              )
                            : null,
                      );
                      if (range != null) {
                        setState(() {
                          _filter = _filter.copyWith(
                            startDate: range.start,
                            endDate: range.end,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                _buildJobTypeMultiSelect(jobTypes),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              0,
              AppTheme.spaceMd,
              24, // Spacing for buttons
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_filter.typeIds == null || _filter.typeIds!.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    l.filter_error_no_job_selected,
                    isError: true,
                  );
                  return;
                }
                shiftProvider.setFilter(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l.filter_apply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeMultiSelect(List<JobType> jobTypes) {
    final l = AppLocalizations.of(context)!;
    final selectedIds = _filter.typeIds ?? [];
    final allSelected =
        jobTypes.isNotEmpty && selectedIds.length == jobTypes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.filter_job_type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (jobTypes.length > 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _filter = _filter.copyWith(typeIds: []);
                    } else {
                      _filter = _filter.copyWith(
                        typeIds: jobTypes.map((j) => j.id).toList(),
                      );
                    }
                  });
                },
                child: Text(
                  allSelected ? l.filter_clear_all : l.filter_select_all,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: jobTypes.map((JobType job) {
                final isSelected = selectedIds.contains(job.id);
                return CheckboxListTile(
                  title: Text(job.name, style: const TextStyle(fontSize: 14)),
                  value: isSelected,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                  onChanged: (bool? value) {
                    setState(() {
                      final newList = List<String>.from(selectedIds);
                      if (value == true) {
                        newList.add(job.id);
                      } else {
                        newList.remove(job.id);
                      }
                      _filter = _filter.copyWith(typeIds: newList);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSection({
    required String title,
    required double min,
    required double max,
    required RangeValues values,
    required ValueChanged<RangeValues> onChanged,
    required String Function(double) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "${labelBuilder(values.start)} - ${labelBuilder(values.end)}",
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: max > min ? (max - min).toInt().clamp(1, 10000) : 1,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
