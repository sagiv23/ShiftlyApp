import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/screens/shift_history_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/filter_bottom_sheet.dart';
import 'package:shiftly/widgets/shift_tile.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final hasActiveTimer = context.select<TimerProvider, bool>(
      (t) => t.startTime != null,
    );
    final auth = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context)!;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;

    final settings = context.watch<SettingsProvider>();
    final now = DateTime.now();
    final currentMonthShifts = shiftProvider.filteredShifts.where((shift) {
      return shift.date.year == now.year && shift.date.month == now.month;
    }).toList();

    double monthHours = 0;
    double monthGross = 0;
    double monthTips = 0;
    double monthExpenses = 0;
    double monthIncomes = 0;

    for (final shift in currentMonthShifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      monthHours += shift.netHours;
      monthGross += shift.calculateBaseSalary(
        rate,
        rules: settings.overtimeRules,
        shabbatRules: settings.shabbatHolidayRules,
      );
      monthTips += shift.tips;
      monthExpenses += shift.totalAutomaticExpenses;
      monthIncomes += shift.totalAutomaticIncomes;
    }

    for (final expense in shiftProvider.expenses) {
      if (expense.date.year == now.year && expense.date.month == now.month) {
        monthExpenses += expense.amount;
      }
    }

    for (final income in shiftProvider.incomes) {
      if (income.date.year == now.year && income.date.month == now.month) {
        monthIncomes += income.amount;
      }
    }

    if (hasActiveTimer) {
      final timerProvider = context.read<TimerProvider>();
      if (timerProvider.startTime?.year == now.year &&
          timerProvider.startTime?.month == now.month) {
        final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
        final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
        monthHours += timerProvider.netMinutes / 60.0;
        monthGross += (timerProvider.netMinutes / 60.0) * rate;
        monthTips += timerProvider.tips;
        if (settings.automaticExpenseEnabled) {
          for (final expense in settings.defaultAutomaticExpenses) {
            monthExpenses += expense.amount;
          }
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
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (auth.isLoggedIn && auth.userName != null)
            Text(
              l.home_welcome_back.replaceFirst('[[name]]', auth.userName!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.electricCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_view_month_rounded),
          tooltip: l.export_range_all,
          onPressed: () {
            Navigator.push(
              context,
              AppPageRoute.slideUp(const ShiftHistoryScreen()),
            );
          },
        ),
        const SizedBox(width: AppTheme.spaceXs),
      ],
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                if (hasActiveTimer) const _ActiveTimerBanner(),
                if (shiftProvider.activeFilter?.isActive == true)
                  const ActiveFiltersBar(),
              ],
            ),
            Expanded(
              child: shiftProvider.isLoading && shiftProvider.shifts.isEmpty
                  ? const HomeScreenSkeleton()
                  : !auth.isGuest &&
                        shiftProvider.errorMessage != null &&
                        shiftProvider.shifts.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.cloud_off_rounded,
                      title: l.common_error,
                      subtitle: shiftProvider.errorMessage,
                      action: ElevatedButton.icon(
                        onPressed: () => shiftProvider.syncWithServer(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l.common_reset),
                      ),
                    )
                  : groupedShifts.isEmpty && !hasActiveTimer
                  ? (shiftProvider.activeFilter?.isActive == true
                        ? _FilterEmptyState()
                        : EmptyStateWidget(
                            title: l.home_empty_state_title,
                            subtitle: l.home_empty_state_subtitle,
                          ))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spaceSm,
                        AppTheme.spaceXs,
                        AppTheme.spaceSm,
                        104,
                      ),
                      children: [
                        _MonthlySnapshot(
                          month: now,
                          net:
                              monthGross +
                              monthTips +
                              monthIncomes -
                              monthExpenses,
                          gross: monthGross,
                          hours: monthHours,
                          shiftCount:
                              currentMonthShifts.length +
                              (hasActiveTimer ? 1 : 0),
                          tips: monthTips,
                          reimbursements: monthIncomes,
                          expenses: monthExpenses,
                          onAddShift: () => Navigator.push(
                            context,
                            AppPageRoute.slideUp(const AddShiftScreen()),
                          ),
                          onAnalytics: () =>
                              MainScreenScope.of(context)?.onTabSelected(1),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        if (groupedShifts.isNotEmpty) ...[
                          _SectionHeading(
                            title:
                                '${l.home_shift_list_shifts_on} ${DateFormat.MMMM(l.localeName).format(now)}',
                            historyLabel: l.export_range_all,
                            onHistory: () => Navigator.push(
                              context,
                              AppPageRoute.slideUp(const ShiftHistoryScreen()),
                            ),
                            actionLabel: l.home_action_calendar,
                            onAction: () =>
                                MainScreenScope.of(context)?.onTabSelected(0),
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          if (currentMonthShifts.isNotEmpty)
                            _RecentShiftList(shifts: currentMonthShifts)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l.home_empty_state_subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The home screen opens with one answer: what the user has kept this month.
/// Supporting detail is grouped underneath instead of competing with the total.
class _MonthlySnapshot extends StatelessWidget {
  final DateTime month;
  final double net;
  final double gross;
  final double hours;
  final int shiftCount;
  final double tips;
  final double reimbursements;
  final double expenses;
  final VoidCallback onAddShift;
  final VoidCallback onAnalytics;

  const _MonthlySnapshot({
    required this.month,
    required this.net,
    required this.gross,
    required this.hours,
    required this.shiftCount,
    required this.tips,
    required this.reimbursements,
    required this.expenses,
    required this.onAddShift,
    required this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final elapsed =
        month.year == DateTime.now().year && month.month == DateTime.now().month
        ? DateTime.now().day / daysInMonth
        : 1.0;
    final monthName = DateFormat.MMMM(l.localeName).format(month);

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? AppTheme.secondaryText
                      : const Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onAnalytics,
                tooltip: l.analytics_title,
                icon: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.electricCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.analytics_net_pay,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: net),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            UIUtils.formatCurrency(value, symbol: symbol),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: AppTheme.mintGreen,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: gross),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '${l.home_total_card_base}: ${UIUtils.formatCurrency(value, symbol: symbol)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm + 4),
          Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  icon: Icons.schedule_rounded,
                  value: '${hours.toStringAsFixed(1)} ${l.common_hours_suffix}',
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
          if (tips > 0 || reimbursements > 0 || expenses > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AmountPill(
                  label: l.home_total_card_base,
                  amount: gross,
                  color: AppTheme.electricCyan,
                ),
                if (tips > 0)
                  _AmountPill(
                    label: l.home_total_card_tips,
                    amount: tips,
                    color: AppTheme.mintGreen,
                  ),
                if (reimbursements > 0)
                  _AmountPill(
                    label: l.expenses_tab_incomes,
                    amount: reimbursements,
                    color: AppTheme.electricCyan,
                  ),
                if (expenses > 0)
                  _AmountPill(
                    label: l.home_total_card_expenses,
                    amount: -expenses,
                    color: AppTheme.softCoral,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppTheme.spaceSm + 4),
          Semantics(
            label: '$monthName ${(elapsed * 100).round()}%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: elapsed,
                minHeight: 5,
                color: AppTheme.electricCyan,
                backgroundColor: AppTheme.electricCyan.withValues(alpha: .14),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm + 4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onAddShift,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l.home_action_new_shift),
            ),
          ),
        ],
      ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
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

  const _AmountPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label ${UIUtils.formatCurrency(amount, symbol: symbol)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? historyLabel;
  final VoidCallback? onHistory;

  const _SectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.historyLabel,
    this.onHistory,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      if (onHistory != null && historyLabel != null)
        TextButton.icon(
          onPressed: onHistory,
          icon: const Icon(Icons.history_rounded, size: 16),
          label: Text(
            historyLabel!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: AppTheme.electricCyan,
          ),
        ),
      if (onAction != null && actionLabel != null)
        IconButton(
          onPressed: onAction,
          tooltip: actionLabel,
          icon: const Icon(Icons.calendar_month_rounded, size: 20),
          color: AppTheme.electricCyan,
          visualDensity: VisualDensity.compact,
        ),
    ],
  );
}

class _RecentShiftList extends StatelessWidget {
  final List<Shift> shifts;

  const _RecentShiftList({required this.shifts});

  @override
  Widget build(BuildContext context) => Container(
    decoration: AppTheme.sectionDecoration(context),
    child: Column(
      children: [
        for (var i = 0; i < shifts.length; i++) ...[
          ShiftTile(shift: shifts[i]),
          if (i < shifts.length - 1)
            const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ],
    ),
  );
}

class _ActiveTimerBanner extends StatelessWidget {
  const _ActiveTimerBanner();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
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
    final accent = isBreak ? AppTheme.warmAmber : AppTheme.electricCyan;
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
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.4 : 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                isBreak
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBreak
                        ? l.home_active_timer_break
                        : '${l.home_active_timer_active} ${job?.name ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: isDark ? AppTheme.primaryText : accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l.home_active_timer_time} $timeStr  ·  ${UIUtils.formatCurrency(pay, symbol: symbol)}',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.secondaryText
                          : Colors.grey.shade700,
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
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
