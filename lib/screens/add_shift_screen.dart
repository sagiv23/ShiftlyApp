import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/services/overtime_calculator.dart';
import 'package:shiftly/services/shift_parser.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/add_shift/add_shift_manual_tab.dart';
import 'package:shiftly/widgets/add_shift/add_shift_raw_tab.dart';
import 'package:shiftly/widgets/add_shift/add_shift_timer_tab.dart';
import 'package:uuid/uuid.dart';

class AddShiftScreen extends StatefulWidget {
  final Shift? shiftToEdit;
  final int initialTabIndex;

  const AddShiftScreen({super.key, this.shiftToEdit, this.initialTabIndex = 0});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  // Manual Form State
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _selectedJobTypeId;
  final List<TextEditingController> _tipControllers = [];
  late BreakType _selectedBreakType;

  // Wage Segments State
  final List<TimeOfDay> _segmentStartTimes = [];
  final List<TimeOfDay> _segmentEndTimes = [];
  final List<TextEditingController> _segmentPercentageControllers = [];

  // Raw Paste State
  final TextEditingController _rawTextController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Timer State
  final List<TextEditingController> _timerTipControllers = [];
  final List<TextEditingController> _autoExpenseAmountControllers = [];
  final List<TextEditingController> _autoExpenseDescControllers = [];
  final List<TextEditingController> _autoIncomeAmountControllers = [];
  final List<TextEditingController> _autoIncomeDescControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.shiftToEdit == null ? 3 : 1,
      vsync: this,
      initialIndex: widget.shiftToEdit == null ? widget.initialTabIndex : 0,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _selectedDate = widget.shiftToEdit?.date ?? DateTime.now();
    _startTime = widget.shiftToEdit != null
        ? TimeOfDay.fromDateTime(widget.shiftToEdit!.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.shiftToEdit != null
        ? TimeOfDay.fromDateTime(widget.shiftToEdit!.endTime)
        : const TimeOfDay(hour: 17, minute: 0);
    _selectedBreakType = widget.shiftToEdit?.breakType ?? BreakType.none;
    _selectedJobTypeId = widget.shiftToEdit?.jobTypeId;

    _initShiftFormData();
  }

  void _initShiftFormData() {
    final settings = context.read<SettingsProvider>();
    if (widget.shiftToEdit != null) {
      final s = widget.shiftToEdit!;
      final expenses = s.automaticExpenses ?? [];
      for (var e in expenses) {
        _autoExpenseAmountControllers.add(
          TextEditingController(
            text: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
          ),
        );
        _autoExpenseDescControllers.add(
          TextEditingController(text: e.description),
        );
      }

      final incomes = s.automaticIncomes ?? [];
      for (var e in incomes) {
        _autoIncomeAmountControllers.add(
          TextEditingController(
            text: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
          ),
        );
        _autoIncomeDescControllers.add(
          TextEditingController(text: e.description),
        );
      }

      if (s.individualTips != null && s.individualTips!.isNotEmpty) {
        for (var tip in s.individualTips!) {
          _tipControllers.add(
            TextEditingController(text: tip > 0 ? tip.toStringAsFixed(0) : ''),
          );
        }
      } else if (s.tips > 0) {
        _tipControllers.add(
          TextEditingController(text: s.tips.toStringAsFixed(0)),
        );
      } else {
        _tipControllers.add(TextEditingController());
      }

      if (s.wageSegments != null) {
        for (var seg in s.wageSegments!) {
          _segmentStartTimes.add(TimeOfDay.fromDateTime(seg.startTime));
          _segmentEndTimes.add(TimeOfDay.fromDateTime(seg.endTime));
          _segmentPercentageControllers.add(
            TextEditingController(
              text: seg.percentage > 0 ? seg.percentage.toStringAsFixed(0) : '',
            ),
          );
        }
      }
      _descriptionController.text = s.description ?? '';
    } else {
      _tipControllers.add(TextEditingController());
      _timerTipControllers.add(TextEditingController());

      if (settings.automaticExpenseEnabled ||
          settings.defaultAutomaticExpenses.isNotEmpty) {
        for (var e in settings.defaultAutomaticExpenses) {
          _autoExpenseAmountControllers.add(
            TextEditingController(
              text: e.amount > 0 ? e.amount.toStringAsFixed(0) : '',
            ),
          );
          _autoExpenseDescControllers.add(
            TextEditingController(text: e.description),
          );
        }
      }

      if (settings.defaultAutomaticIncomes.isNotEmpty) {
        for (var inc in settings.defaultAutomaticIncomes) {
          _autoIncomeAmountControllers.add(
            TextEditingController(
              text: inc.amount > 0 ? inc.amount.toStringAsFixed(0) : '',
            ),
          );
          _autoIncomeDescControllers.add(
            TextEditingController(text: inc.description),
          );
        }
      }

      final shiftProvider = context.read<ShiftProvider>();
      if (_selectedJobTypeId == null && shiftProvider.jobTypes.isNotEmpty) {
        _selectedJobTypeId = shiftProvider.jobTypes.first.id;
      }
    }
  }

  @override
  void dispose() {
    for (var c in _tipControllers) {
      c.dispose();
    }
    for (var c in _timerTipControllers) {
      c.dispose();
    }
    for (var c in _autoExpenseAmountControllers) {
      c.dispose();
    }
    for (var c in _autoExpenseDescControllers) {
      c.dispose();
    }
    for (var c in _autoIncomeAmountControllers) {
      c.dispose();
    }
    for (var c in _autoIncomeDescControllers) {
      c.dispose();
    }
    for (var c in _segmentPercentageControllers) {
      c.dispose();
    }
    _rawTextController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateTotalTips(List<TextEditingController> controllers) {
    return controllers.fold(
      0.0,
      (sum, c) => sum + (double.tryParse(c.text) ?? 0.0),
    );
  }

  double _calculateTotalAutoExpenses() {
    double total = 0.0;
    for (var c in _autoExpenseAmountControllers) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    return total;
  }

  double _calculateTotalAutoIncomes() {
    double total = 0.0;
    for (var c in _autoIncomeAmountControllers) {
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

  List<AutomaticExpense>? _getExpenseList() {
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> list = [];
    for (int i = 0; i < _autoExpenseAmountControllers.length; i++) {
      final amountText = _autoExpenseAmountControllers[i].text.trim();
      final desc = _autoExpenseDescControllers[i].text.trim();

      if (amountText.isEmpty && desc.isEmpty) continue;

      final amount = double.tryParse(amountText);
      if (desc.isEmpty) {
        UIUtils.showSnackBar(
          context,
          l.settings_dialog_error_enter_desc,
          isError: true,
        );
        return null;
      }
      if (amount == null || amount < 0) {
        UIUtils.showSnackBar(
          context,
          l.onboarding_auto_expenses_invalid_amount,
          isError: true,
        );
        return null;
      }
      if (amount > 0) {
        list.add(AutomaticExpense(description: desc, amount: amount));
      }
    }
    return list;
  }

  List<AutomaticExpense>? _getIncomeList() {
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> list = [];
    for (int i = 0; i < _autoIncomeAmountControllers.length; i++) {
      final amountText = _autoIncomeAmountControllers[i].text.trim();
      final desc = _autoIncomeDescControllers[i].text.trim();

      if (amountText.isEmpty && desc.isEmpty) continue;

      final amount = double.tryParse(amountText);
      if (desc.isEmpty) {
        UIUtils.showSnackBar(
          context,
          l.settings_dialog_error_enter_income_desc,
          isError: true,
        );
        return null;
      }
      if (amount == null || amount < 0) {
        UIUtils.showSnackBar(
          context,
          l.onboarding_auto_expenses_invalid_amount,
          isError: true,
        );
        return null;
      }
      if (amount > 0) {
        list.add(AutomaticExpense(description: desc, amount: amount));
      }
    }
    return list;
  }

  Future<bool> _confirmOverlappingShifts({
    required DateTime start,
    required DateTime end,
    String? excludeShiftId,
  }) async {
    final shiftProvider = context.read<ShiftProvider>();
    final overlaps = shiftProvider.findOverlappingShifts(
      start: start,
      end: end,
      excludeShiftId: excludeShiftId,
    );
    if (overlaps.isEmpty) return true;

    final l = AppLocalizations.of(context)!;
    final details = overlaps
        .map((shift) {
          final jobName =
              shiftProvider.getJobTypeById(shift.jobTypeId)?.name ??
              l.add_shift_overlap_unknown_job;
          final date = AppConstants.formatDate(shift.startTime);
          final time =
              '${DateFormat.Hm().format(shift.startTime)}-${DateFormat.Hm().format(shift.endTime)}';
          return '• $jobName · $date · $time';
        })
        .join('\n');

    return UIUtils.showConfirmDialog(
      context: context,
      title: l.add_shift_overlap_title,
      content: l.add_shift_overlap_content(overlaps.length, details),
      confirmLabel: l.add_shift_overlap_confirm,
    );
  }

  void _finishTimerShift() async {
    final timerProvider = context.read<TimerProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;

    if (timerProvider.startTime == null || timerProvider.jobTypeId == null) {
      return;
    }

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.add_shift_shift_ended_dialog_title,
      content: l.add_shift_shift_ended_dialog_desc,
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final end = timerProvider.isRunning
        ? DateTime.now()
        : (timerProvider.reviewEndTime ?? DateTime.now());

    final expenses = _getExpenseList();
    if (expenses == null) return;
    final incomes = _getIncomeList();
    if (incomes == null) return;

    final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");

    final shift = Shift(
      id: const Uuid().v4(),
      date: timerProvider.startTime!,
      startTime: timerProvider.startTime!,
      endTime: end,
      jobTypeId: timerProvider.jobTypeId!,
      tips: _calculateTotalTips(_timerTipControllers),
      individualTips: _getTipList(_timerTipControllers),
      hourlyRate: job?.getRateForDate(timerProvider.startTime!),
      automaticExpenses: expenses,
      automaticIncomes: incomes,
      breakType: timerProvider.accumulatedUnpaidMinutes > 0
          ? BreakType.unpaid
          : BreakType.none,
      unpaidBreakMinutes: timerProvider.accumulatedUnpaidMinutes,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final overlapConfirmed = await _confirmOverlappingShifts(
      start: shift.startTime,
      end: shift.endTime,
    );
    if (!overlapConfirmed || !mounted) return;

    shiftProvider.addShift(shift);
    timerProvider.resetTimer();

    if (!mounted) return;
    UIUtils.showSnackBar(context, l.add_shift_shift_saved);
    Navigator.pop(context);
  }

  void _showFinishDialog() {
    context.read<TimerProvider>().stopShift();
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          AlertDialog(
            title: Text(l.add_shift_timer_stop_shift),
            content: Text(l.add_shift_timer_stopped_msg),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<TimerProvider>().resumeShift();
                },
                child: Text(l.add_shift_timer_continue_work),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _finishTimerShift();
                },
                child: Text(l.common_save_and_finish),
              ),
            ],
          ),
    );
  }

  void _saveManual() async {
    if (_selectedJobTypeId == null) return;
    final l = AppLocalizations.of(context)!;

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    var end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: widget.shiftToEdit != null
          ? l.add_shift_shift_edit_dialog_title
          : l.add_shift_shift_ended_dialog_title,
      content: l.add_shift_shift_ended_edit_dialog_desc,
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final shiftProvider = context.read<ShiftProvider>();
    final settings = context.read<SettingsProvider>();
    final job = shiftProvider.getJobTypeById(_selectedJobTypeId!);

    final expenses = _getExpenseList();
    if (expenses == null) return;
    final incomes = _getIncomeList();
    if (incomes == null) return;

    List<ShiftWageSegment> wageSegments = [];
    for (int i = 0; i < _segmentStartTimes.length; i++) {
      final sTime = _segmentStartTimes[i];
      final eTime = _segmentEndTimes[i];
      final pct =
          double.tryParse(_segmentPercentageControllers[i].text) ?? 100.0;

      DateTime segStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        sTime.hour,
        sTime.minute,
      );
      DateTime segEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        eTime.hour,
        eTime.minute,
      );
      if (segEnd.isBefore(segStart)) {
        segEnd = segEnd.add(const Duration(days: 1));
      }

      if (!segStart.isBefore(segEnd)) {
        UIUtils.showSnackBar(
          context,
          l.error_segment_invalid_time,
          isError: true,
        );
        return;
      }

      wageSegments.add(
        ShiftWageSegment(startTime: segStart, endTime: segEnd, percentage: pct),
      );
    }

    for (int i = 0; i < wageSegments.length; i++) {
      for (int j = i + 1; j < wageSegments.length; j++) {
        final s1 = wageSegments[i];
        final s2 = wageSegments[j];
        if (s1.startTime.isBefore(s2.endTime) &&
            s2.startTime.isBefore(s1.endTime)) {
          UIUtils.showSnackBar(context, l.error_segment_overlap, isError: true);
          return;
        }
      }
    }

    final overlapConfirmed = await _confirmOverlappingShifts(
      start: start,
      end: end,
      excludeShiftId: widget.shiftToEdit?.id,
    );
    if (!overlapConfirmed || !mounted) return;

    if (widget.shiftToEdit != null) {
      final s = widget.shiftToEdit!;
      s.date = _selectedDate;
      s.startTime = start;
      s.endTime = end;
      s.jobTypeId = _selectedJobTypeId!;
      s.tips = _calculateTotalTips(_tipControllers);
      s.individualTips = _getTipList(_tipControllers);
      s.hourlyRate = job?.getRateForDate(_selectedDate);
      s.automaticExpenses = expenses;
      s.automaticIncomes = incomes;
      s.breakType = _selectedBreakType;
      s.unpaidBreakMinutes = settings.unpaidBreakDurationMinutes;
      s.description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      s.wageSegments = wageSegments;

      if (!mounted) return;
      shiftProvider.updateShift(s);

      UIUtils.showSnackBar(context, l.add_shift_shift_saved);
    } else {
      final shift = Shift(
        id: const Uuid().v4(),
        date: _selectedDate,
        startTime: start,
        endTime: end,
        jobTypeId: _selectedJobTypeId!,
        tips: _calculateTotalTips(_tipControllers),
        individualTips: _getTipList(_tipControllers),
        hourlyRate: job?.getRateForDate(_selectedDate),
        automaticExpenses: expenses,
        automaticIncomes: incomes,
        breakType: _selectedBreakType,
        unpaidBreakMinutes: settings.unpaidBreakDurationMinutes,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        wageSegments: wageSegments,
      );
      if (!mounted) return;
      shiftProvider.addShift(shift);

      UIUtils.showSnackBar(context, l.add_shift_shift_saved);
    }
    if (mounted) Navigator.pop(context);
  }

  void _saveRaw() async {
    if (_selectedJobTypeId == null) return;
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    final lines = _rawTextController.text.split('\n');
    final validLines = lines.where((l) => l.trim().isNotEmpty).toList();
    if (validLines.isEmpty) return;

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.add_shift_paste_parse_dialog_title,
      content: '${l.add_shift_paste_parse_dialog_desc} (${validLines.length})',
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final shiftProvider = context.read<ShiftProvider>();
    final jobTypes = shiftProvider.jobTypes;

    int addedCount = 0;
    Map<String, String> rememberedJobTypeMappings = {};

    for (var line in validLines) {
      final parseResult = ShiftParser.parseResult(
        line,
        _selectedJobTypeId!,
        paidMinutes: settings.paidBreakDurationMinutes,
        unpaidMinutes: settings.unpaidBreakDurationMinutes,
        availableJobTypes: jobTypes,
      );

      final shift = parseResult.shift;
      String? trailingText = parseResult.trailingText;

      if (shift != null) {
        if (trailingText != null && trailingText.isNotEmpty) {
          if (rememberedJobTypeMappings.containsKey(trailingText)) {
            shift.jobTypeId = rememberedJobTypeMappings[trailingText]!;
          } else {
            if (!mounted) break;
            final dialogResult = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (ctx) {
                String? chosenJobId = jobTypes.isNotEmpty
                    ? jobTypes.first.id
                    : _selectedJobTypeId;
                bool remember = false;
                return StatefulBuilder(
                  builder: (context, setStateSB) => AlertDialog(
                    title: Text(l.add_shift_unknown_job_title(trailingText)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.add_shift_unknown_job_desc),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: chosenJobId,
                          decoration: InputDecoration(
                            labelText: l.add_shift_select_job_label,
                          ),
                          items: jobTypes
                              .map(
                                (j) => DropdownMenuItem<String>(
                                  value: j.id,
                                  child: Text(j.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setStateSB(() => chosenJobId = val),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: Text(l.add_shift_apply_all_instances),
                          value: remember,
                          onChanged: (val) =>
                              setStateSB(() => remember = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, {'action': 'skip'}),
                        child: Text(l.add_shift_skip),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(ctx, {'action': 'description'}),
                        child: Text(l.add_shift_save_as_desc),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, {
                          'action': 'assign',
                          'jobId': chosenJobId,
                          'remember': remember,
                        }),
                        child: Text(l.add_shift_assign),
                      ),
                    ],
                  ),
                );
              },
            );

            if (dialogResult == null || dialogResult['action'] == 'skip') {
              continue;
            } else if (dialogResult['action'] == 'assign') {
              final assignedJobId = dialogResult['jobId'] as String?;
              if (assignedJobId != null) {
                shift.jobTypeId = assignedJobId;
                if (dialogResult['remember'] == true) {
                  rememberedJobTypeMappings[trailingText] = assignedJobId;
                }
              }
            } else if (dialogResult['action'] == 'description') {
              shift.description = trailingText;
            }
          }
        }

        final job = shiftProvider.getJobTypeById(shift.jobTypeId);
        shift.hourlyRate = job?.getRateForDate(shift.date);
        if (settings.automaticExpenseEnabled ||
            settings.defaultAutomaticExpenses.isNotEmpty) {
          shift.automaticExpenses = settings.defaultAutomaticExpenses
              .map((e) => e.copyWith())
              .toList();
        }
        if (settings.automaticIncomeEnabled ||
            settings.defaultAutomaticIncomes.isNotEmpty) {
          shift.automaticIncomes = settings.defaultAutomaticIncomes
              .map((e) => e.copyWith())
              .toList();
        }
        final overlapConfirmed = await _confirmOverlappingShifts(
          start: shift.startTime,
          end: shift.endTime,
        );
        if (!overlapConfirmed) continue;
        if (!mounted) continue;
        shiftProvider.addShift(shift);
        addedCount++;
      }
    }

    if (!mounted) return;
    if (addedCount > 0) {
      Navigator.pop(context);
    } else {
      UIUtils.showSnackBar(context, l.add_shift_paste_error, isError: true);
    }
  }

  Widget _buildWageSegmentsSection() {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l.add_shift_wage_segments_subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _segmentStartTimes.add(_startTime);
                  _segmentEndTimes.add(_endTime);
                  _segmentPercentageControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text(l.add_shift_wage_segments_add),
            ),
          ],
        ),
        if (_segmentStartTimes.isNotEmpty) const SizedBox(height: 8),
        for (int i = 0; i < _segmentStartTimes.length; i++)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _segmentStartTimes[i],
                        );
                        if (picked != null && mounted) {
                          setState(() => _segmentStartTimes[i] = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l.add_shift_wage_segment_start,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          _segmentStartTimes[i].format(context),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _segmentEndTimes[i],
                        );
                        if (picked != null && mounted) {
                          setState(() => _segmentEndTimes[i] = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l.add_shift_wage_segment_end,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          _segmentEndTimes[i].format(context),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _segmentPercentageControllers[i],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: l.add_shift_wage_segment_percentage,
                        hintText: '150',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _segmentStartTimes.removeAt(i);
                        _segmentEndTimes.removeAt(i);
                        _segmentPercentageControllers[i].dispose();
                        _segmentPercentageControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOvertimeSalaryBreakdownSection() {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final symbol = settings.currencySymbol;

    DateTime start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    DateTime end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final job = _selectedJobTypeId != null
        ? shiftProvider.getJobTypeById(_selectedJobTypeId!)
        : null;
    final rate =
        job?.getRateForDate(_selectedDate) ?? AppConstants.defaultHourlyRate;

    List<ShiftWageSegment> manualWageSegments = [];
    for (int i = 0; i < _segmentStartTimes.length; i++) {
      final sTime = _segmentStartTimes[i];
      final eTime = _segmentEndTimes[i];
      final pct =
          double.tryParse(_segmentPercentageControllers[i].text) ?? 100.0;
      DateTime segStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        sTime.hour,
        sTime.minute,
      );
      DateTime segEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        eTime.hour,
        eTime.minute,
      );
      if (segEnd.isBefore(segStart)) {
        segEnd = segEnd.add(const Duration(days: 1));
      }
      manualWageSegments.add(
        ShiftWageSegment(startTime: segStart, endTime: segEnd, percentage: pct),
      );
    }

    final breakdown = OvertimeCalculator.calculateBreakdown(
      startTime: start,
      endTime: end,
      hourlyRate: rate,
      breakType: _selectedBreakType,
      unpaidBreakMinutes: settings.unpaidBreakDurationMinutes,
      rules: settings.overtimeRules,
      shabbatHolidayRules: settings.shabbatHolidayRules,
      tips: _calculateTotalTips(_tipControllers),
      automaticIncomes: _calculateTotalAutoIncomes(),
      automaticExpenses: _calculateTotalAutoExpenses(),
      wageSegments: manualWageSegments,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      decoration: BoxDecoration(
        color:
            (breakdown.hasOvertime ||
                breakdown.hasShabbat ||
                breakdown.hasHoliday)
            ? AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color:
              (breakdown.hasOvertime ||
                  breakdown.hasShabbat ||
                  breakdown.hasHoliday)
              ? AppTheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l.overtime_regular_hours_label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${breakdown.regularHours.toStringAsFixed(2)} ${l.common_hours_suffix} - ${UIUtils.formatCurrency(breakdown.regularEarnings, symbol: symbol)}',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (breakdown.hasShabbat) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.add_shift_shabbat_breakdown(
                      (breakdown.shabbatMultiplier * 100).toStringAsFixed(0),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${breakdown.shabbatHours.toStringAsFixed(2)} ${l.common_hours_suffix} - ${UIUtils.formatCurrency(breakdown.shabbatEarnings, symbol: symbol)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (breakdown.hasHoliday) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.add_shift_holiday_breakdown(
                      breakdown.holidayName ?? l.holiday_tag_label,
                      (breakdown.holidayMultiplier * 100).toStringAsFixed(0),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${breakdown.holidayHours.toStringAsFixed(2)} ${l.common_hours_suffix} - ${UIUtils.formatCurrency(breakdown.holidayEarnings, symbol: symbol)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (breakdown.tier1Hours > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.overtime_tier_custom_label.replaceFirst(
                      '[[rate]]',
                      (breakdown.tier1Multiplier * 100).toStringAsFixed(0),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${breakdown.tier1Hours.toStringAsFixed(2)} ${l.common_hours_suffix} - ${UIUtils.formatCurrency(breakdown.tier1Earnings, symbol: symbol)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (breakdown.tier2Hours > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.overtime_tier_custom_label.replaceFirst(
                      '[[rate]]',
                      (breakdown.tier2Multiplier * 100).toStringAsFixed(0),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${breakdown.tier2Hours.toStringAsFixed(2)} ${l.common_hours_suffix} - ${UIUtils.formatCurrency(breakdown.tier2Earnings, symbol: symbol)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (_selectedBreakType == BreakType.unpaid) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l.overtime_unpaid_break,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-${breakdown.unpaidBreakHours.toStringAsFixed(2)} ${l.common_hours_suffix}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${l.overtime_total_paid_time}: ${breakdown.netPaidHours.toStringAsFixed(2)} ${l.common_hours_suffix}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                UIUtils.formatCurrency(breakdown.totalShiftPay, symbol: symbol),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryDark,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rawJobs = context
        .watch<ShiftProvider>()
        .jobTypes;

    final jobs = List<JobType>.from(rawJobs)
      ..sort((a, b) {
        if (a.id == '1') return -1;
        if (b.id == '1') return 1;
        if (a.id == '2') return -1;
        if (b.id == '2') return 1;
        return a.name.compareTo(b.name);
      });

    final isEditing = widget.shiftToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l.add_shift_edit_title : l.add_shift_title),
      ),
      body: ResponsivePageBody(
        child: SafeArea(
          child: PageEntranceAnimation(
            child: isEditing
                ? AddShiftManualTab(
              jobs: jobs,
              selectedDate: _selectedDate,
              startTime: _startTime,
              endTime: _endTime,
              selectedJobTypeId: _selectedJobTypeId,
              selectedBreakType: _selectedBreakType,
              tipControllers: _tipControllers,
              autoExpenseAmountControllers: _autoExpenseAmountControllers,
              autoExpenseDescControllers: _autoExpenseDescControllers,
              autoIncomeAmountControllers: _autoIncomeAmountControllers,
              autoIncomeDescControllers: _autoIncomeDescControllers,
              segmentStartTimes: _segmentStartTimes,
              segmentEndTimes: _segmentEndTimes,
              segmentPercentageControllers: _segmentPercentageControllers,
              descriptionController: _descriptionController,
              shiftToEdit: widget.shiftToEdit,
              onDateChanged: (val) => setState(() => _selectedDate = val),
              onStartTimeChanged: (val) => setState(() => _startTime = val),
              onEndTimeChanged: (val) => setState(() => _endTime = val),
              onJobTypeChanged: (val) =>
                  setState(() => _selectedJobTypeId = val),
              onBreakTypeChanged: (val) =>
                  setState(() => _selectedBreakType = val),
              onAddTip: () =>
                  setState(() => _tipControllers.add(TextEditingController())),
              onRemoveTip: (idx) =>
                  setState(() => _tipControllers.removeAt(idx)),
              onAddExpense: () =>
                  setState(() {
                    _autoExpenseAmountControllers.add(TextEditingController());
                    _autoExpenseDescControllers.add(TextEditingController());
                  }),
              onRemoveExpense: (idx) =>
                  setState(() {
                    _autoExpenseAmountControllers.removeAt(idx);
                    _autoExpenseDescControllers.removeAt(idx);
                  }),
              onAddIncome: () =>
                  setState(() {
                    _autoIncomeAmountControllers.add(TextEditingController());
                    _autoIncomeDescControllers.add(TextEditingController());
                  }),
              onRemoveIncome: (idx) =>
                  setState(() {
                    _autoIncomeAmountControllers.removeAt(idx);
                    _autoIncomeDescControllers.removeAt(idx);
                  }),
              onChanged: () => setState(() {}),
              onSaveManual: _saveManual,
              buildWageSegmentsSection: _buildWageSegmentsSection,
              buildOvertimeSalaryBreakdownSection: _buildOvertimeSalaryBreakdownSection,
            )
                : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppTheme.spaceSm,
                    AppTheme.spaceXs,
                    AppTheme.spaceSm,
                    AppTheme.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .cardTheme
                        .color,
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMd,
                    ),
                    border: Border.all(
                      color: Theme
                          .of(
                        context,
                      )
                          .dividerColor
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        text: l.add_shift_timer_tab,
                        icon: const Icon(Icons.timer_outlined, size: 20),
                      ),
                      Tab(
                        text: l.add_shift_manual_tab,
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                      ),
                      Tab(
                        text: l.add_shift_paste_tab,
                        icon: const Icon(Icons.paste_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                AddShiftTimerTab(
                  jobs: jobs,
                  pulseController: _pulseController,
                  selectedJobTypeId: _selectedJobTypeId,
                  onJobTypeChanged: (val) =>
                      setState(() => _selectedJobTypeId = val),
                  timerTipControllers: _timerTipControllers,
                  autoExpenseAmountControllers: _autoExpenseAmountControllers,
                  autoExpenseDescControllers: _autoExpenseDescControllers,
                  autoIncomeAmountControllers: _autoIncomeAmountControllers,
                  autoIncomeDescControllers: _autoIncomeDescControllers,
                  onAddTip: () =>
                      setState(() =>
                          _timerTipControllers.add(TextEditingController())),
                  onRemoveTip: (idx) =>
                      setState(() => _timerTipControllers.removeAt(idx)),
                  onAddExpense: () =>
                      setState(() {
                        _autoExpenseAmountControllers.add(
                            TextEditingController());
                        _autoExpenseDescControllers.add(
                            TextEditingController());
                      }),
                  onRemoveExpense: (idx) =>
                      setState(() {
                        _autoExpenseAmountControllers.removeAt(idx);
                        _autoExpenseDescControllers.removeAt(idx);
                      }),
                  onAddIncome: () =>
                      setState(() {
                        _autoIncomeAmountControllers.add(
                            TextEditingController());
                        _autoIncomeDescControllers.add(TextEditingController());
                      }),
                  onRemoveIncome: (idx) =>
                      setState(() {
                        _autoIncomeAmountControllers.removeAt(idx);
                        _autoIncomeDescControllers.removeAt(idx);
                      }),
                  onChanged: () => setState(() {}),
                  onFinishTimerShift: _finishTimerShift,
                  onShowFinishDialog: _showFinishDialog,
                  tabController: _tabController,
                ),
                AddShiftManualTab(
                  jobs: jobs,
                  selectedDate: _selectedDate,
                  startTime: _startTime,
                  endTime: _endTime,
                  selectedJobTypeId: _selectedJobTypeId,
                  selectedBreakType: _selectedBreakType,
                  tipControllers: _tipControllers,
                  autoExpenseAmountControllers: _autoExpenseAmountControllers,
                  autoExpenseDescControllers: _autoExpenseDescControllers,
                  autoIncomeAmountControllers: _autoIncomeAmountControllers,
                  autoIncomeDescControllers: _autoIncomeDescControllers,
                  segmentStartTimes: _segmentStartTimes,
                  segmentEndTimes: _segmentEndTimes,
                  segmentPercentageControllers: _segmentPercentageControllers,
                  descriptionController: _descriptionController,
                  shiftToEdit: widget.shiftToEdit,
                  onDateChanged: (val) => setState(() => _selectedDate = val),
                  onStartTimeChanged: (val) => setState(() => _startTime = val),
                  onEndTimeChanged: (val) => setState(() => _endTime = val),
                  onJobTypeChanged: (val) =>
                      setState(() => _selectedJobTypeId = val),
                  onBreakTypeChanged: (val) =>
                      setState(() => _selectedBreakType = val),
                  onAddTip: () =>
                      setState(() =>
                          _tipControllers.add(TextEditingController())),
                  onRemoveTip: (idx) =>
                      setState(() => _tipControllers.removeAt(idx)),
                  onAddExpense: () =>
                      setState(() {
                        _autoExpenseAmountControllers.add(
                            TextEditingController());
                        _autoExpenseDescControllers.add(
                            TextEditingController());
                      }),
                  onRemoveExpense: (idx) =>
                      setState(() {
                        _autoExpenseAmountControllers.removeAt(idx);
                        _autoExpenseDescControllers.removeAt(idx);
                      }),
                  onAddIncome: () =>
                      setState(() {
                        _autoIncomeAmountControllers.add(
                            TextEditingController());
                        _autoIncomeDescControllers.add(TextEditingController());
                      }),
                  onRemoveIncome: (idx) =>
                      setState(() {
                        _autoIncomeAmountControllers.removeAt(idx);
                        _autoIncomeDescControllers.removeAt(idx);
                      }),
                  onChanged: () => setState(() {}),
                  onSaveManual: _saveManual,
                  buildWageSegmentsSection: _buildWageSegmentsSection,
                  buildOvertimeSalaryBreakdownSection: _buildOvertimeSalaryBreakdownSection,
                ),
                AddShiftRawTab(
                  jobs: jobs,
                  selectedJobTypeId: _selectedJobTypeId,
                  onJobTypeChanged: (val) =>
                      setState(() => _selectedJobTypeId = val),
                  rawTextController: _rawTextController,
                  onSaveRaw: _saveRaw,
                ),
              ],
            ),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
