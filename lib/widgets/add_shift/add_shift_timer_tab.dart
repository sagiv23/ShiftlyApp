import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/add_shift/add_shift_form_sections.dart';
import 'package:shiftly/widgets/shift_tile.dart';

class AddShiftTimerTab extends StatelessWidget {
  final List<JobType> jobs;
  final AnimationController pulseController;
  final String? selectedJobTypeId;
  final ValueChanged<String?> onJobTypeChanged;
  final List<TextEditingController> timerTipControllers;
  final List<TextEditingController> autoExpenseAmountControllers;
  final List<TextEditingController> autoExpenseDescControllers;
  final List<TextEditingController> autoIncomeAmountControllers;
  final List<TextEditingController> autoIncomeDescControllers;
  final VoidCallback onAddTip;
  final ValueChanged<int> onRemoveTip;
  final VoidCallback onAddExpense;
  final ValueChanged<int> onRemoveExpense;
  final VoidCallback onAddIncome;
  final ValueChanged<int> onRemoveIncome;
  final VoidCallback onChanged;
  final VoidCallback onFinishTimerShift;
  final VoidCallback onShowFinishDialog;
  final TabController tabController;

  const AddShiftTimerTab({
    super.key,
    required this.jobs,
    required this.pulseController,
    required this.selectedJobTypeId,
    required this.onJobTypeChanged,
    required this.timerTipControllers,
    required this.autoExpenseAmountControllers,
    required this.autoExpenseDescControllers,
    required this.autoIncomeAmountControllers,
    required this.autoIncomeDescControllers,
    required this.onAddTip,
    required this.onRemoveTip,
    required this.onAddExpense,
    required this.onRemoveExpense,
    required this.onAddIncome,
    required this.onRemoveIncome,
    required this.onChanged,
    required this.onFinishTimerShift,
    required this.onShowFinishDialog,
    required this.tabController,
  });

  double _calculateTotalTips(List<TextEditingController> controllers) {
    return controllers.fold(
      0.0,
      (sum, c) => sum + (double.tryParse(c.text) ?? 0.0),
    );
  }

  double _calculateTotalAutoExpenses() {
    double total = 0.0;
    for (var c in autoExpenseAmountControllers) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    return total;
  }

  double _calculateTotalAutoIncomes() {
    double total = 0.0;
    for (var c in autoIncomeAmountControllers) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    return total;
  }

  List<double> _getTipList(List<TextEditingController> controllers) {
    return controllers
        .map((c) => double.tryParse(c.text) ?? 0.0)
        .where((t) => t > 0)
        .toList();
  }

  List<AutomaticExpense> _peekMoneyList({
    required List<TextEditingController> amounts,
    required List<TextEditingController> descs,
  }) {
    final list = <AutomaticExpense>[];
    for (int i = 0; i < amounts.length; i++) {
      final amountText = amounts[i].text.trim();
      final desc = descs[i].text.trim();
      if (amountText.isEmpty && desc.isEmpty) continue;
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) continue;
      list.add(
        AutomaticExpense(
          description: desc.isEmpty ? '-' : desc,
          amount: amount,
        ),
      );
    }
    return list;
  }

  Shift? _buildTimerDraftShift(BuildContext context) {
    final timer = context.read<TimerProvider>();
    final settings = context.read<SettingsProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final jobId = timer.jobTypeId ?? selectedJobTypeId;
    if (jobId == null || timer.startTime == null) return null;

    final end = timer.isRunning
        ? DateTime.now()
        : (timer.reviewEndTime ?? DateTime.now());
    final job = shiftProvider.getJobTypeById(jobId);

    return Shift(
      id: 'preview-timer',
      date: timer.startTime!,
      startTime: timer.startTime!,
      endTime: end,
      jobTypeId: jobId,
      tips: _calculateTotalTips(timerTipControllers),
      individualTips: _getTipList(timerTipControllers),
      hourlyRate: job?.getRateForDate(timer.startTime!),
      automaticExpenses: _peekMoneyList(
        amounts: autoExpenseAmountControllers,
        descs: autoExpenseDescControllers,
      ),
      automaticIncomes: _peekMoneyList(
        amounts: autoIncomeAmountControllers,
        descs: autoIncomeDescControllers,
      ),
      breakType: timer.accumulatedUnpaidMinutes > 0
          ? BreakType.unpaid
          : BreakType.none,
      unpaidBreakMinutes: timer.accumulatedUnpaidMinutes > 0
          ? timer.accumulatedUnpaidMinutes
          : settings.unpaidBreakDurationMinutes,
    );
  }

  Widget _buildLivePreview(BuildContext context, Shift? draft) {
    if (draft == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: AppTheme.spaceXs,
          ),
          child: Text(
            l.add_shift_preview_title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ShiftTile(
          shift: draft,
          useCardDecoration: true,
          interactive: false,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }

  String _moneySummary(double total, String symbol) {
    if (total <= 0) return '';
    return UIUtils.formatCurrency(total, symbol: symbol);
  }

  Widget _buildTipsSection(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...timerTipControllers.asMap().entries.map((entry) {
          final idx = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkBackground.withValues(alpha: 0.4)
                    : AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 20,
                    color: AppTheme.profit.withValues(alpha: 0.8),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: l.add_shift_tips_hint,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  if (timerTipControllers.length > 1)
                    IconButton(
                      tooltip: l.common_delete,
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppTheme.expense,
                      ),
                      onPressed: () => onRemoveTip(idx),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAddTip,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l.add_shift_tips_add_button),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryDark),
        ),
      ],
    );
  }

  Widget _buildAutoExpensesSection(BuildContext context, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...List.generate(autoExpenseAmountControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: autoExpenseDescControllers[index],
                    decoration: InputDecoration(
                      labelText: l.onboarding_auto_expenses_desc_label,
                      hintText: l.default_expenses_trips,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: autoExpenseAmountControllers[index],
                    decoration: InputDecoration(
                      labelText: symbol,
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.expense,
                  ),
                  onPressed: () => onRemoveExpense(index),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAddExpense,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l.add_shift_expenses_add_button),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryDark),
        ),
      ],
    );
  }

  Widget _buildAutoIncomesSection(BuildContext context, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...List.generate(autoIncomeAmountControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: autoIncomeDescControllers[index],
                    decoration: InputDecoration(
                      labelText: l.onboarding_auto_expenses_desc_label,
                      hintText: l.default_expenses_trips,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: autoIncomeAmountControllers[index],
                    decoration: InputDecoration(
                      labelText: symbol,
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.profit,
                  ),
                  onPressed: () => onRemoveIncome(index),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAddIncome,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l.add_shift_incomes_add_button),
          style: TextButton.styleFrom(foregroundColor: AppTheme.profitSoft),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final isRunning = timerProvider.isRunning;
    final isOnBreak = timerProvider.isOnBreak;
    final isReviewMode = timerProvider.startTime != null && !isRunning;
    final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
    final livePay = timerProvider.calculateLivePay(
      job?.getRateForDate(timerProvider.startTime ?? DateTime.now()) ??
          AppConstants.defaultHourlyRate,
    );

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    }

    final buttonColor = isReviewMode
        ? AppTheme.profit
        : (isRunning
              ? (isOnBreak ? AppTheme.warningSoft : AppTheme.primary)
              : Theme.of(context).colorScheme.surfaceContainerHighest);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spaceSm),
              ScalePress(
                onTap: () {
                  if (isReviewMode) {
                    timerProvider.resumeShift();
                    tabController.animateTo(0);
                  } else if (!isRunning) {
                    if (selectedJobTypeId == null) {
                      UIUtils.showSnackBar(
                        context,
                        l.add_shift_pick_a_job,
                        isError: true,
                      );
                      return;
                    }
                    timerProvider.startShift(selectedJobTypeId!);
                    for (var c in timerTipControllers) {
                      c.text = '0';
                    }
                  } else {
                    if (isOnBreak) {
                      timerProvider.endBreak();
                    } else {
                      onShowFinishDialog();
                    }
                  }
                },
                child: AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    final pulse = isRunning && !isOnBreak
                        ? 8 + (pulseController.value * 14)
                        : 6.0;
                    final glowAlpha = isRunning && !isOnBreak
                        ? 0.25 + (pulseController.value * 0.25)
                        : 0.2;
                    return Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: glowAlpha),
                            blurRadius: pulse,
                            spreadRadius: isRunning && !isOnBreak
                                ? 4 + (pulseController.value * 8)
                                : 2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonColor,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 8,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isReviewMode
                                ? Icons.play_arrow_rounded
                                : (isRunning
                                      ? (isOnBreak
                                            ? Icons.play_arrow_rounded
                                            : Icons.stop_rounded)
                                      : Icons.play_arrow_rounded),
                            size: 64,
                            color: isReviewMode || isRunning
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            isReviewMode
                                ? l.add_shift_timer_continue_work
                                : (isRunning
                                      ? (isOnBreak
                                            ? l.add_shift_timer_resume_work
                                            : l.add_shift_timer_stop_shift)
                                      : l.add_shift_timer_start_shift),
                            style: TextStyle(
                              color: isReviewMode || isRunning
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Text(
                formatDuration(timerProvider.elapsed),
                style: AppTheme.monoNumber.copyWith(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                UIUtils.formatCurrency(livePay, symbol: symbol),
                style: UIUtils.getCurrencyStyle(
                  context,
                  livePay,
                  baseStyle: AppTheme.monoNumber.copyWith(fontSize: 28),
                  positiveColor: AppTheme.primaryDark,
                ),
              ),
              Text(
                l.add_shift_timer_accumulated_live,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (isOnBreak || timerProvider.accumulatedUnpaidMinutes > 0) ...[
                const SizedBox(height: AppTheme.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isOnBreak)
                        Text(
                          '${l.add_shift_timer_countdown} ${timerProvider.breakRemaining.inMinutes}:${(timerProvider.breakRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: AppTheme.monoNumber.copyWith(
                            fontSize: 20,
                            color:
                                timerProvider.activeBreakType == BreakType.paid
                                ? AppTheme.primaryDark
                                : AppTheme.warningSoft,
                          ),
                        ),
                      Text(
                        isOnBreak
                            ? (timerProvider.activeBreakType == BreakType.paid
                                  ? l.add_shift_timer_break_paid
                                  : l.add_shift_timer_break_unpaid)
                            : '${l.add_shift_timer_total_break_unpaid} ${timerProvider.accumulatedUnpaidMinutes.toStringAsFixed(1)} ${l.common_min_suffix}',
                        style: TextStyle(
                          color: AppTheme.warningSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spaceLg),
              AddShiftFormSection(
                title: l.add_shift_manual_job_type_label,
                icon: Icons.work_outline_rounded,
                child: DropdownButtonFormField<String>(
                  initialValue: (isRunning || isReviewMode)
                      ? timerProvider.jobTypeId
                      : selectedJobTypeId,
                  decoration: InputDecoration(
                    labelText: l.add_shift_manual_job_type_label,
                    prefixIcon: const Icon(Icons.work_rounded),
                  ),
                  items: jobs
                      .map(
                        (j) => DropdownMenuItem(
                          value: j.id,
                          child: Row(
                            children: [
                              Icon(AppTheme.iconForJobName(j.name), size: 18),
                              const SizedBox(width: 8),
                              Text(j.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    if (isRunning || isReviewMode) {
                      timerProvider.setJobType(val);
                    } else {
                      onJobTypeChanged(val);
                    }
                  },
                ),
              ),
              if (settings.breaksEnabled && isRunning && !isReviewMode) ...[
                const SizedBox(height: AppTheme.spaceMd),
                AddShiftFormSection(
                  title: l.add_shift_manual_break_type_section,
                  icon: Icons.coffee_outlined,
                  child: SegmentedButton<BreakType?>(
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: BreakType.paid,
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: Text(
                          '${settings.paidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_paid_break}',
                        ),
                      ),
                      ButtonSegment(
                        value: BreakType.unpaid,
                        icon: const Icon(Icons.coffee_outlined, size: 18),
                        label: Text(
                          '${settings.unpaidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_unpaid_break}',
                        ),
                      ),
                    ],
                    selected: {if (isOnBreak) timerProvider.activeBreakType},
                    onSelectionChanged: (val) {
                      if (val.isEmpty) {
                        if (isOnBreak) timerProvider.endBreak();
                        return;
                      }
                      final type = val.first!;
                      final minutes = type == BreakType.paid
                          ? settings.paidBreakDurationMinutes
                          : settings.unpaidBreakDurationMinutes;
                      timerProvider.toggleBreak(type, minutes);
                    },
                  ),
                ),
              ],
              if (isRunning || isReviewMode) ...[
                const SizedBox(height: AppTheme.spaceMd),
                AddShiftCollapsibleFormSection(
                  title: l.add_shift_tips_title,
                  icon: Icons.payments_outlined,
                  summary: _moneySummary(
                    _calculateTotalTips(timerTipControllers),
                    symbol,
                  ),
                  initiallyExpanded:
                      _calculateTotalTips(timerTipControllers) > 0,
                  child: _buildTipsSection(context),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                AddShiftCollapsibleFormSection(
                  title: l.add_shift_expenses_title,
                  icon: Icons.money_off_rounded,
                  summary: _moneySummary(_calculateTotalAutoExpenses(), symbol),
                  initiallyExpanded: _calculateTotalAutoExpenses() > 0,
                  child: _buildAutoExpensesSection(context, symbol),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                AddShiftCollapsibleFormSection(
                  title: l.add_shift_incomes_title,
                  icon: Icons.account_balance_wallet_rounded,
                  summary: _moneySummary(_calculateTotalAutoIncomes(), symbol),
                  initiallyExpanded: _calculateTotalAutoIncomes() > 0,
                  child: _buildAutoIncomesSection(context, symbol),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildLivePreview(context, _buildTimerDraftShift(context)),
                const SizedBox(height: AppTheme.spaceMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isReviewMode
                        ? onFinishTimerShift
                        : onShowFinishDialog,
                    icon: Icon(
                      isReviewMode ? Icons.check_rounded : Icons.stop_rounded,
                    ),
                    label: Text(
                      isReviewMode
                          ? l.common_save_and_finish
                          : l.add_shift_timer_stop_shift,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReviewMode
                          ? AppTheme.profit
                          : AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final confirmed = await UIUtils.showConfirmDialog(
                      context: context,
                      title: l.add_shift_timer_reset_title,
                      content: l.add_shift_timer_reset_desc,
                      isDestructive: true,
                      confirmLabel: l.common_reset,
                    );
                    if (confirmed != true) return;
                    if (!context.mounted) return;
                    timerProvider.resetTimer();
                  },
                  child: Text(
                    l.common_reset_and_cancel,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
