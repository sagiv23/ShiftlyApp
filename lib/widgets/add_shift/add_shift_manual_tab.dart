import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/add_shift/add_shift_form_sections.dart';
import 'package:shiftly/widgets/shift_tile.dart';

class AddShiftManualTab extends StatelessWidget {
  final List<JobType> jobs;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? selectedJobTypeId;
  final BreakType selectedBreakType;
  final List<TextEditingController> tipControllers;
  final List<TextEditingController> autoExpenseAmountControllers;
  final List<TextEditingController> autoExpenseDescControllers;
  final List<TextEditingController> autoIncomeAmountControllers;
  final List<TextEditingController> autoIncomeDescControllers;
  final List<TimeOfDay> segmentStartTimes;
  final List<TimeOfDay> segmentEndTimes;
  final List<TextEditingController> segmentPercentageControllers;
  final TextEditingController descriptionController;
  final Shift? shiftToEdit;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<String?> onJobTypeChanged;
  final ValueChanged<BreakType> onBreakTypeChanged;
  final VoidCallback onAddTip;
  final ValueChanged<int> onRemoveTip;
  final VoidCallback onAddExpense;
  final ValueChanged<int> onRemoveExpense;
  final VoidCallback onAddIncome;
  final ValueChanged<int> onRemoveIncome;
  final VoidCallback onChanged;
  final VoidCallback onSaveManual;
  final Widget Function() buildWageSegmentsSection;
  final Widget Function() buildOvertimeSalaryBreakdownSection;

  const AddShiftManualTab({
    super.key,
    required this.jobs,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.selectedJobTypeId,
    required this.selectedBreakType,
    required this.tipControllers,
    required this.autoExpenseAmountControllers,
    required this.autoExpenseDescControllers,
    required this.autoIncomeAmountControllers,
    required this.autoIncomeDescControllers,
    required this.segmentStartTimes,
    required this.segmentEndTimes,
    required this.segmentPercentageControllers,
    required this.descriptionController,
    required this.shiftToEdit,
    required this.onDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onJobTypeChanged,
    required this.onBreakTypeChanged,
    required this.onAddTip,
    required this.onRemoveTip,
    required this.onAddExpense,
    required this.onRemoveExpense,
    required this.onAddIncome,
    required this.onRemoveIncome,
    required this.onChanged,
    required this.onSaveManual,
    required this.buildWageSegmentsSection,
    required this.buildOvertimeSalaryBreakdownSection,
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

  List<ShiftWageSegment> _peekWageSegments() {
    final segments = <ShiftWageSegment>[];
    for (int i = 0; i < segmentStartTimes.length; i++) {
      final sTime = segmentStartTimes[i];
      final eTime = segmentEndTimes[i];
      final pct =
          double.tryParse(segmentPercentageControllers[i].text) ?? 100.0;
      DateTime segStart = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        sTime.hour,
        sTime.minute,
      );
      DateTime segEnd = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        eTime.hour,
        eTime.minute,
      );
      if (segEnd.isBefore(segStart)) {
        segEnd = segEnd.add(const Duration(days: 1));
      }
      if (!segStart.isBefore(segEnd)) continue;
      segments.add(
        ShiftWageSegment(startTime: segStart, endTime: segEnd, percentage: pct),
      );
    }
    return segments;
  }

  Shift? _buildManualDraftShift(BuildContext context) {
    if (selectedJobTypeId == null) return null;
    final settings = context.read<SettingsProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final job = shiftProvider.getJobTypeById(selectedJobTypeId!);

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    var end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    return Shift(
      id: shiftToEdit?.id ?? 'preview-manual',
      date: selectedDate,
      startTime: start,
      endTime: end,
      jobTypeId: selectedJobTypeId!,
      tips: _calculateTotalTips(tipControllers),
      individualTips: _getTipList(tipControllers),
      hourlyRate: job?.getRateForDate(selectedDate),
      automaticExpenses: _peekMoneyList(
        amounts: autoExpenseAmountControllers,
        descs: autoExpenseDescControllers,
      ),
      automaticIncomes: _peekMoneyList(
        amounts: autoIncomeAmountControllers,
        descs: autoIncomeDescControllers,
      ),
      breakType: selectedBreakType,
      unpaidBreakMinutes: settings.unpaidBreakDurationMinutes,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      wageSegments: _peekWageSegments(),
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
        ...tipControllers.asMap().entries.map((entry) {
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
                  if (tipControllers.length > 1)
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
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final tipsTotal = _calculateTotalTips(tipControllers);
    final expensesTotal = _calculateTotalAutoExpenses();
    final incomesTotal = _calculateTotalAutoIncomes();
    final descText = descriptionController.text.trim();
    final breakOptions = <({BreakType type, String label})>[
      (type: BreakType.none, label: l.add_shift_manual_no_break),
      (
        type: BreakType.paid,
        label:
            '${settings.paidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_paid_break}',
      ),
      (
        type: BreakType.unpaid,
        label:
            '${settings.unpaidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_unpaid_break}',
      ),
    ];

    final shiftSections = <Widget>[
      AddShiftFormSection(
        title: l.add_shift_manual_time_section,
        icon: Icons.schedule_rounded,
        child: Column(
          children: [
            AddShiftPickerTile(
              icon: Icons.calendar_month_rounded,
              title: l.add_shift_manual_date_label,
              value: AppConstants.formatDate(selectedDate),
              onTap: () async {
                final picked = await AppDatePicker.showSingleDatePicker(
                  context: context,
                  initialDate: selectedDate,
                );
                if (picked != null && context.mounted) {
                  onDateChanged(picked);
                }
              },
            ),
            const Divider(height: 1),
            AddShiftPickerTile(
              icon: Icons.access_time_rounded,
              title: l.add_shift_manual_start_time_label,
              value: startTime.format(context),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null && context.mounted) {
                  onStartTimeChanged(picked);
                }
              },
            ),
            const Divider(height: 1),
            AddShiftPickerTile(
              icon: Icons.access_time_filled_rounded,
              title: l.add_shift_manual_end_time_label,
              value: endTime.format(context),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null && context.mounted) {
                  onEndTimeChanged(picked);
                }
              },
            ),
          ],
        ),
      ),
      AddShiftFormSection(
        title: l.add_shift_manual_job_type_label,
        icon: Icons.work_rounded,
        child: DropdownButtonFormField<String>(
          initialValue: selectedJobTypeId,
          decoration: InputDecoration(
            labelText: l.add_shift_manual_job_type_label,
            prefixIcon: const Icon(Icons.work_rounded),
          ),
          items: jobs
              .map(
                (j) => DropdownMenuItem<String>(
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
          onChanged: onJobTypeChanged,
        ),
      ),
      if (settings.breaksEnabled)
        AddShiftFormSection(
          title: l.add_shift_manual_break_type_section,
          icon: Icons.coffee_outlined,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 480) {
                return Wrap(
                  spacing: AppTheme.spaceXs,
                  runSpacing: AppTheme.spaceXs,
                  children: [
                    for (final option in breakOptions)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: selectedBreakType == option.type,
                        onSelected: (_) => onBreakTypeChanged(option.type),
                      ),
                  ],
                );
              }

              return SizedBox(
                width: double.infinity,
                child: SegmentedButton<BreakType>(
                  segments: [
                    for (final option in breakOptions)
                      ButtonSegment(
                        value: option.type,
                        label: Text(option.label),
                      ),
                  ],
                  selected: {selectedBreakType},
                  onSelectionChanged: (value) =>
                      onBreakTypeChanged(value.first),
                ),
              );
            },
          ),
        ),
    ];

    final earningsSections = <Widget>[
      AddShiftCollapsibleFormSection(
        title: l.add_shift_tips_title,
        icon: Icons.payments_outlined,
        summary: _moneySummary(tipsTotal, symbol),
        initiallyExpanded: tipsTotal > 0,
        child: _buildTipsSection(context),
      ),
      AddShiftCollapsibleFormSection(
        title: l.add_shift_expenses_title,
        icon: Icons.money_off_rounded,
        summary: _moneySummary(expensesTotal, symbol),
        initiallyExpanded: expensesTotal > 0,
        child: _buildAutoExpensesSection(context, symbol),
      ),
      AddShiftCollapsibleFormSection(
        title: l.add_shift_incomes_title,
        icon: Icons.account_balance_wallet_rounded,
        summary: _moneySummary(incomesTotal, symbol),
        initiallyExpanded: incomesTotal > 0,
        child: _buildAutoIncomesSection(context, symbol),
      ),
    ];

    final detailSections = <Widget>[
      AddShiftCollapsibleFormSection(
        title: l.add_shift_wage_segments_title,
        icon: Icons.percent_rounded,
        summary: segmentStartTimes.isEmpty
            ? ''
            : l.add_shift_segments_count(segmentStartTimes.length),
        initiallyExpanded: segmentStartTimes.isNotEmpty,
        child: buildWageSegmentsSection(),
      ),
      AddShiftCollapsibleFormSection(
        title: l.overtime_breakdown_title,
        icon: Icons.calculate_rounded,
        initiallyExpanded: false,
        child: buildOvertimeSalaryBreakdownSection(),
      ),
      AddShiftCollapsibleFormSection(
        title: l.shift_description_label,
        icon: Icons.note_alt_rounded,
        summary: descText.isEmpty
            ? ''
            : (descText.length > 28
                  ? '${descText.substring(0, 28)}…'
                  : descText),
        initiallyExpanded: descText.isNotEmpty,
        child: TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: l.shift_description_label,
            hintText: l.shift_description_hint,
          ),
          maxLines: 3,
          minLines: 1,
          onChanged: (_) => onChanged(),
        ),
      ),
    ];

    final endingSections = <Widget>[
      _buildLivePreview(context, _buildManualDraftShift(context)),
      SizedBox(
        width: double.infinity,
        child: ScalePress(
          onTap: onSaveManual,
          child: ElevatedButton.icon(
            onPressed: onSaveManual,
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(
              shiftToEdit != null
                  ? l.add_shift_shift_edit_dialog_title
                  : l.add_shift_shift_ended_dialog_title,
            ),
          ),
        ),
      ),
    ];

    Widget buildColumn(List<Widget> sections) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          sections[i],
          if (i < sections.length - 1) const SizedBox(height: AppTheme.spaceSm),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final sections = [
          ...shiftSections,
          ...earningsSections,
          ...detailSections,
          ...endingSections,
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            AppTheme.spaceLg,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumn([
                        ...shiftSections,
                        ...earningsSections,
                      ]),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: buildColumn([
                        ...detailSections,
                        ...endingSections,
                      ]),
                    ),
                  ],
                )
              : buildColumn(sections),
        );
      },
    );
  }
}
