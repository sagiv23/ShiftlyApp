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
import 'package:shiftly/screens/shift_history_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/export_bottom_sheet.dart';
import 'package:shiftly/widgets/shift_tile.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';
import 'package:shiftly/widgets/year_month_tab_layout.dart';

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
    final currentMonthKey = DateFormat('yyyy-MM').format(now);
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
                ? AppTheme.electricCyan
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
            Column(
              children: [
                if (hasActiveTimer) const _ActiveTimerBanner(),
                if (shiftProvider.activeFilter?.isActive == true)
                  const _ActiveFiltersBar(),
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
                    onAddShift: () =>
                        Navigator.push(
                          context,
                          AppPageRoute.slideUp(const AddShiftScreen()),
                        ),
                    onAnalytics: () =>
                        MainScreenScope.of(context)?.onTabSelected(1),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  if (groupedShifts.isNotEmpty) ...[
                    _HistoryEntryPoint(
                      groupedShifts: groupedShifts,
                      currentMonthKey: currentMonthKey,
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                  if (currentMonthShifts.isNotEmpty) ...[
                    _SectionHeading(
                      title:
                      '${l.home_shift_list_shifts_on} ${DateFormat.MMMM(l
                          .localeName).format(now)}',
                      actionLabel: l.home_action_calendar,
                      onAction: () =>
                          MainScreenScope.of(context)?.onTabSelected(0),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    _RecentShiftList(
                      shifts: currentMonthShifts,
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
    final symbol = context
        .watch<SettingsProvider>()
        .currencySymbol;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final elapsed =
    month.year == DateTime
        .now()
        .year && month.month == DateTime
        .now()
        .month
        ? DateTime
        .now()
        .day / daysInMonth
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
              : [Colors.white, const Color(0xFFE8F8FB)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: isDark ? .28 : .22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricCyan.withValues(alpha: isDark ? .12 : .08),
            blurRadius: 30,
            offset: const Offset(0, 12),
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
                  monthName,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: isDark
                        ? AppTheme.secondaryText
                        : const Color(0xFF475569),
                  ),
                ),
              ),
              IconButton(
                onPressed: onAnalytics,
                tooltip: l.analytics_title,
                icon: const Icon(
                  Icons.insights_rounded,
                  color: AppTheme.electricCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.analytics_net_pay,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall,
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
                  style: Theme
                      .of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                    color: AppTheme.mintGreen,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: gross),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${l.home_total_card_base}: ${UIUtils.formatCurrency(
                    value, symbol: symbol)}',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall,
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceMd),
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
          const SizedBox(height: AppTheme.spaceSm),
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
          const SizedBox(height: AppTheme.spaceMd),
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
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddShift,
              icon: const Icon(Icons.add_rounded),
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
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .surface
              .withValues(alpha: .45),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.electricCyan, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall,
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
    final symbol = context
        .watch<SettingsProvider>()
        .currencySymbol;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label ${UIUtils.formatCurrency(amount, symbol: symbol)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) =>
      Row(
        children: [
          Expanded(
            child: Text(title, style: Theme
                .of(context)
                .textTheme
                .titleLarge),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      );
}

class _RecentShiftList extends StatelessWidget {
  final List<Shift> shifts;

  const _RecentShiftList({required this.shifts});

  @override
  Widget build(BuildContext context) =>
      Container(
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

/// Keeps the main page focused on the present. Full history is still one tap
/// away in a native draggable sheet, where vertical browsing has clear intent.
class _HistoryEntryPoint extends StatelessWidget {
  final Map<String, List<Shift>> groupedShifts;
  final String currentMonthKey;

  const _HistoryEntryPoint({
    required this.groupedShifts,
    required this.currentMonthKey,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => _showHistory(context),
          child: Ink(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neonViolet.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppTheme.neonViolet,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    l.export_range_all,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute.slideUp(const ShiftHistoryScreen()),
    );
  }
}

class _HistorySheet extends StatefulWidget {
  final ScrollController scrollController;
  final Map<String, List<Shift>> groupedShifts;
  final String currentMonthKey;

  const _HistorySheet({
    required this.scrollController,
    required this.groupedShifts,
    required this.currentMonthKey,
  });

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  bool _useTabView = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final entries = widget.groupedShifts.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Drag handle and header bar
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${l.analytics_period_all_time} ${l.common_shifts_count}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                // View mode switcher: Tab View vs List View
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _useTabView = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _useTabView
                                ? (isDark
                                ? AppTheme.electricCyan
                                .withValues(alpha: 0.25)
                                : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: _useTabView
                                ? Border.all(
                              color: AppTheme.electricCyan
                                  .withValues(alpha: 0.5),
                              width: 1,
                            )
                                : null,
                          ),
                          child: Icon(
                            Icons.calendar_view_month_rounded,
                            size: 18,
                            color: _useTabView
                                ? AppTheme.electricCyan
                                : (isDark
                                ? AppTheme.secondaryText
                                : Colors.grey.shade600),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _useTabView = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: !_useTabView
                                ? (isDark
                                ? AppTheme.electricCyan
                                .withValues(alpha: 0.25)
                                : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: !_useTabView
                                ? Border.all(
                              color: AppTheme.electricCyan
                                  .withValues(alpha: 0.5),
                              width: 1,
                            )
                                : null,
                          ),
                          child: Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 18,
                            color: !_useTabView
                                ? AppTheme.electricCyan
                                : (isDark
                                ? AppTheme.secondaryText
                                : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main body content
          Expanded(
            child: _useTabView
                ? YearMonthTabLayout(
              scrollController: widget.scrollController,
              groupedShifts: widget.groupedShifts,
              currentMonthKey: widget.currentMonthKey,
            )
                : ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceXl,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _MonthExpansionSection(
                  monthKey: entry.key,
                  shifts: entry.value,
                  initiallyExpanded: entry.key == widget.currentMonthKey,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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

    final settings = context.watch<SettingsProvider>();

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      totalNetHours += shift.netHours;
      totalBaseSalary += shift.calculateBaseSalary(
        rate,
        rules: settings.overtimeRules,
        shabbatRules: settings.shabbatHolidayRules,
      );
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
          color: isDark ? AppTheme.darkCard : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTheme.electricCyan,
              fontSize: 18,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "$monthShiftCount ${l.common_shifts_count}  · ${l.home_shift_list_net_total}: ${UIUtils.formatCurrency(net, symbol: symbol)} ·  ${totalNetHours.toStringAsFixed(2)} ${l.common_hours_suffix}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.secondaryText : Colors.grey.shade700,
              ),
            ),
          ),
          children: [
            Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
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
                          isDark: isDark,
                        ),
                        if (totalTips > 0) ...[
                          VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                          _SummaryItem(
                            label: l.home_total_card_tips,
                            value: UIUtils.formatCurrency(
                              totalTips,
                              symbol: symbol,
                            ),
                            amount: totalTips,
                            accent: AppTheme.mintGreen,
                            isDark: isDark,
                          ),
                        ],
                        if (totalMonthIncomes > 0) ...[
                          VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                          _SummaryItem(
                            label: l.expenses_tab_incomes,
                            value: UIUtils.formatCurrency(
                              totalMonthIncomes,
                              symbol: symbol,
                            ),
                            amount: totalMonthIncomes,
                            accent: AppTheme.mintGreen,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    height: 1,
                    indent: 10,
                    endIndent: 10,
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
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
                            isDark: isDark,
                          ),
                          VerticalDivider(
                            width: 1,
                            indent: 4,
                            endIndent: 4,
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                        ],
                        _SummaryItem(
                          label: l.common_net,
                          value: UIUtils.formatCurrency(net, symbol: symbol),
                          isBold: true,
                          amount: net,
                          isDark: isDark,
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
  final bool isDark;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.amount,
    this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    if ((amount ?? 0) < 0) {
      textColor = AppTheme.softCoral;
    } else if (isBold) {
      textColor = AppTheme.electricCyan;
    } else if (accent != null) {
      textColor = accent;
    } else {
      textColor = isDark ? AppTheme.primaryText : Colors.black87;
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.secondaryText : Colors.grey.shade600,
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
        backgroundColor: AppTheme.electricCyan.withValues(alpha: 0.12),
        side: BorderSide(color: AppTheme.electricCyan.withValues(alpha: 0.25)),
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
                backgroundColor: AppTheme.electricCyan,
                foregroundColor: const Color(0xFF040711),
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
              style: const TextStyle(
                color: AppTheme.electricCyan,
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
          activeColor: AppTheme.electricCyan,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
