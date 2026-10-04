import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:uuid/uuid.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TextEditingController> _autoExpenseAmountControllers = [];
  final List<TextEditingController> _autoExpenseDescControllers = [];
  final List<TextEditingController> _autoIncomeAmountControllers = [];
  final List<TextEditingController> _autoIncomeDescControllers = [];
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    final settings = context.read<SettingsProvider>();
    for (var e in settings.defaultAutomaticExpenses) {
      _autoExpenseAmountControllers.add(
        TextEditingController(text: e.amount.toStringAsFixed(0)),
      );
      _autoExpenseDescControllers.add(
        TextEditingController(text: e.description),
      );
    }
    if (_autoExpenseAmountControllers.isEmpty) {
      _autoExpenseAmountControllers.add(TextEditingController(text: '0'));
      _autoExpenseDescControllers.add(TextEditingController(text: ''));
    }

    for (var e in settings.defaultAutomaticIncomes) {
      _autoIncomeAmountControllers.add(
        TextEditingController(text: e.amount.toStringAsFixed(0)),
      );
      _autoIncomeDescControllers.add(
        TextEditingController(text: e.description),
      );
    }
    if (_autoIncomeAmountControllers.isEmpty) {
      _autoIncomeAmountControllers.add(TextEditingController(text: '0'));
      _autoIncomeDescControllers.add(TextEditingController(text: ''));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    super.dispose();
  }

  Future<void> _saveDefaultExpenses() async {
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> expenses = [];
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
        return;
      }
      if (amount == null || amount <= 0) {
        UIUtils.showSnackBar(
          context,
          l.onboarding_auto_expenses_invalid_amount,
          isError: true,
        );
        return;
      }
      expenses.add(AutomaticExpense(description: desc, amount: amount));
    }
    await settings.updateDefaultAutomaticExpenses(expenses);
    if (mounted) {
      UIUtils.showSnackBar(context, l.expenses_auto_updated_msg);
    }
  }

  Future<void> _saveDefaultIncomes() async {
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> incomes = [];
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
        return;
      }
      if (amount == null || amount <= 0) {
        UIUtils.showSnackBar(
          context,
          l.onboarding_auto_expenses_invalid_amount,
          isError: true,
        );
        return;
      }
      incomes.add(AutomaticExpense(description: desc, amount: amount));
    }
    await settings.updateDefaultAutomaticIncomes(incomes);
    if (mounted) {
      UIUtils.showSnackBar(context, l.expenses_auto_incomes_updated_msg);
    }
  }

  void _showItemDialog(
    BuildContext context, {
    Expense? item,
    required bool isIncome,
  }) {
    final settings = context.read<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final amountController = TextEditingController(
      text: item?.amount.toString() ?? '',
    );
    DateTime selectedDate = item?.date ?? DateTime.now();

    final titleText = isIncome
        ? (item == null
              ? l.incomes_dialog_add_title
              : l.incomes_dialog_edit_title)
        : (item == null
              ? l.expenses_dialog_add_title
              : l.expenses_dialog_edit_title);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(titleText),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: l.onboarding_auto_expenses_desc_label,
                    hintText: l.default_expenses_trips,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: '${l.expenses_total_label} ($symbol)',
                    prefixIcon: Icon(
                      isIncome
                          ? Icons.attach_money_rounded
                          : Icons.sell_rounded,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final desc = descriptionController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (desc.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    isIncome
                        ? l.settings_dialog_error_enter_income_desc
                        : l.settings_dialog_error_enter_desc,
                    isError: true,
                  );
                  return;
                }

                if (amount <= 0) {
                  UIUtils.showSnackBar(
                    context,
                    l.onboarding_auto_expenses_invalid_amount,
                    isError: true,
                  );
                  return;
                }

                final confirmTemplate = isIncome
                    ? l.incomes_save_income_confirm_content
                    : l.expenses_save_expense_confirm_content;

                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: titleText,
                  content: confirmTemplate
                      .replaceAll('[[desc]]', desc)
                      .replaceAll(
                        '[[amount]]',
                        UIUtils.formatCurrency(amount, symbol: symbol),
                      ),
                  cancelLabel: l.common_cancel,
                  confirmLabel: l.common_save,
                );

                if (confirmed != true || !context.mounted) return;

                final provider = context.read<ShiftProvider>();
                if (item == null) {
                  provider.addExpense(
                    Expense(
                      id: const Uuid().v4(),
                      date: selectedDate,
                      description: desc,
                      amount: amount,
                      isIncome: isIncome,
                    ),
                  );
                } else {
                  item.description = desc;
                  item.amount = amount;
                  item.date = selectedDate;
                  provider.updateExpense(item);
                }
                Navigator.pop(ctx);
              },
              child: Text(l.common_save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    final isIncomeTab = _tabController.index == 1;

    // Collect all expenses (standalone + shift automatic expenses)
    final List<_ItemRecord> expenseRecords = [];
    for (var e in shiftProvider.expenses) {
      expenseRecords.add(
        _ItemRecord(
          id: e.id,
          date: e.date,
          description: e.description,
          amount: e.amount,
          isIncome: false,
          standaloneExpense: e,
        ),
      );
    }
    for (var shift in shiftProvider.shifts) {
      if (shift.automaticExpenses != null) {
        final job = shiftProvider.getJobTypeById(shift.jobTypeId);
        final jobName = job?.name ?? '';
        for (int i = 0; i < shift.automaticExpenses!.length; i++) {
          final ae = shift.automaticExpenses![i];
          expenseRecords.add(
            _ItemRecord(
              id: 'shift_exp_${shift.id}_$i',
              date: shift.date,
              description: ae.description,
              amount: ae.amount,
              isIncome: false,
              shift: shift,
              shiftIndex: i,
              shiftInfo: '${l.common_shifts_count} ($jobName)',
            ),
          );
        }
      }
    }

    // Collect all incomes (standalone special incomes + shift automatic incomes)
    final List<_ItemRecord> incomeRecords = [];
    for (var e in shiftProvider.incomes) {
      incomeRecords.add(
        _ItemRecord(
          id: e.id,
          date: e.date,
          description: e.description,
          amount: e.amount,
          isIncome: true,
          standaloneExpense: e,
        ),
      );
    }
    for (var shift in shiftProvider.shifts) {
      if (shift.automaticIncomes != null) {
        final job = shiftProvider.getJobTypeById(shift.jobTypeId);
        final jobName = job?.name ?? '';
        for (int i = 0; i < shift.automaticIncomes!.length; i++) {
          final ai = shift.automaticIncomes![i];
          incomeRecords.add(
            _ItemRecord(
              id: 'shift_inc_${shift.id}_$i',
              date: shift.date,
              description: ai.description,
              amount: ai.amount,
              isIncome: true,
              shift: shift,
              shiftIndex: i,
              shiftInfo: '${l.common_shifts_count} ($jobName)',
            ),
          );
        }
      }
    }

    if (_selectedDateFilter != null) {
      expenseRecords.removeWhere((r) =>
      r.date.year != _selectedDateFilter!.year ||
          r.date.month != _selectedDateFilter!.month ||
          r.date.day != _selectedDateFilter!.day);
      incomeRecords.removeWhere((r) =>
      r.date.year != _selectedDateFilter!.year ||
          r.date.month != _selectedDateFilter!.month ||
          r.date.day != _selectedDateFilter!.day);
    }

    final groupedExpenses = groupBy(
      expenseRecords,
      (r) => "${r.date.year}-${r.date.month.toString().padLeft(2, '0')}",
    );

    final groupedIncomes = groupBy(
      incomeRecords,
      (r) => "${r.date.year}-${r.date.month.toString().padLeft(2, '0')}",
    );

    return AdaptiveScaffold(
      currentIndex: 3,
      title: l.expenses_title,
      actions: [
        if (_selectedDateFilter != null)
          IconButton(
            icon: const Icon(Icons.filter_alt_off_rounded),
            tooltip: l.common_clear_date_filter,
            onPressed: () => setState(() => _selectedDateFilter = null),
          ),
        IconButton(
          icon: const Icon(Icons.calendar_today_rounded),
          tooltip: l.common_search_by_date,
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDateFilter ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _selectedDateFilter = picked);
            }
          },
        ),
      ],
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            if (_selectedDateFilter != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm,
                  vertical: AppTheme.spaceXs,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l.common_filter_date}: ${DateFormat('dd/MM/yyyy')
                          .format(_selectedDateFilter!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _selectedDateFilter = null),
                      child: Text(l.common_clear_date_filter),
                    ),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppTheme.spaceSm,
                AppTheme.spaceXs,
                AppTheme.spaceSm,
                AppTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.money_off_rounded, size: 20),
                    text: l.expenses_tab_expenses,
                  ),
                  Tab(
                    icon: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 20,
                    ),
                    text: l.expenses_tab_incomes,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Expenses
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceSm,
                      AppTheme.spaceXs,
                      AppTheme.spaceSm,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          l.expenses_auto_section_title,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l.expenses_auto_section_enable),
                                  subtitle: Text(
                                    l.expenses_auto_section_subtitle,
                                  ),
                                  secondary: const Icon(
                                    Icons.auto_fix_high_rounded,
                                    color: AppTheme.primaryDark,
                                  ),
                                  value: settings.automaticExpenseEnabled,
                                  onChanged: (val) =>
                                      settings.setAutomaticExpenseEnabled(val),
                                  activeThumbColor: AppTheme.primaryDark,
                                  activeTrackColor: AppTheme.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                if (settings.automaticExpenseEnabled) ...[
                                  const Divider(height: AppTheme.spaceLg),
                                  ...List.generate(
                                    _autoExpenseAmountControllers.length,
                                    (index) => _buildAutoRow(
                                      index,
                                      settings.currencySymbol,
                                      false,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => setState(() {
                                      _autoExpenseAmountControllers.add(
                                        TextEditingController(text: '0'),
                                      );
                                      _autoExpenseDescControllers.add(
                                        TextEditingController(text: ''),
                                      );
                                    }),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                    ),
                                    label: Text(l.expenses_action_add_auto),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveDefaultExpenses,
                                      child: Text(
                                        l.expenses_action_update_settings,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _buildSectionHeader(
                          context,
                          l.expenses_history_section_title,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        if (groupedExpenses.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(l.expenses_no_history),
                            ),
                          )
                        else
                          ...groupedExpenses.keys
                              .toList()
                              .sorted((a, b) => b.compareTo(a))
                              .map((monthKey) {
                                final items = groupedExpenses[monthKey]!;
                                return _MonthItemSection(
                                  monthKey: monthKey,
                                  items: items,
                                  isIncome: false,
                                  onEdit: (record) {
                                    if (record.shift != null) {
                                      Navigator.push(
                                        context,
                                        AppPageRoute.slideHorizontal(
                                          AddShiftScreen(
                                            shiftToEdit: record.shift,
                                          ),
                                        ),
                                      );
                                    } else if (record.standaloneExpense !=
                                        null) {
                                      _showItemDialog(
                                        context,
                                        item: record.standaloneExpense,
                                        isIncome: false,
                                      );
                                    }
                                  },
                                );
                              }),
                      ],
                    ),
                  ),

                  // Tab 2: Special Incomes
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceSm,
                      AppTheme.spaceXs,
                      AppTheme.spaceSm,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          l.expenses_auto_incomes_section_title,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    l.expenses_auto_incomes_section_enable,
                                  ),
                                  subtitle: Text(
                                    l.expenses_auto_incomes_section_subtitle,
                                  ),
                                  secondary: const Icon(
                                    Icons.savings_rounded,
                                    color: AppTheme.profitSoft,
                                  ),
                                  value: settings.automaticIncomeEnabled,
                                  onChanged: (val) =>
                                      settings.setAutomaticIncomeEnabled(val),
                                  activeThumbColor: AppTheme.profit,
                                  activeTrackColor: AppTheme.profit.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                if (settings.automaticIncomeEnabled) ...[
                                  const Divider(height: AppTheme.spaceLg),
                                  ...List.generate(
                                    _autoIncomeAmountControllers.length,
                                    (index) => _buildAutoRow(
                                      index,
                                      settings.currencySymbol,
                                      true,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => setState(() {
                                      _autoIncomeAmountControllers.add(
                                        TextEditingController(text: '0'),
                                      );
                                      _autoIncomeDescControllers.add(
                                        TextEditingController(text: ''),
                                      );
                                    }),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                    ),
                                    label: Text(
                                      l.onboarding_auto_incomes_add_button,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.profitSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveDefaultIncomes,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.profitSoft,
                                      ),
                                      child: Text(
                                        l.expenses_action_update_settings,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _buildSectionHeader(
                          context,
                          l.incomes_history_section_title,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        if (groupedIncomes.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(l.incomes_no_history),
                            ),
                          )
                        else
                          ...groupedIncomes.keys
                              .toList()
                              .sorted((a, b) => b.compareTo(a))
                              .map((monthKey) {
                                final items = groupedIncomes[monthKey]!;
                                return _MonthItemSection(
                                  monthKey: monthKey,
                                  items: items,
                                  isIncome: true,
                                  onEdit: (record) {
                                    if (record.shift != null) {
                                      Navigator.push(
                                        context,
                                        AppPageRoute.slideHorizontal(
                                          AddShiftScreen(
                                            shiftToEdit: record.shift,
                                          ),
                                        ),
                                      );
                                    } else if (record.standaloneExpense !=
                                        null) {
                                      _showItemDialog(
                                        context,
                                        item: record.standaloneExpense,
                                        isIncome: true,
                                      );
                                    }
                                  },
                                );
                              }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context, isIncome: isIncomeTab),
        backgroundColor: isIncomeTab
            ? AppTheme.profitSoft
            : AppTheme.expenseSoft,
        foregroundColor: Colors.white,
        label: Text(
          isIncomeTab
              ? l.incomes_action_new_income
              : l.expenses_action_new_expense,
        ),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildAutoRow(int index, String symbol, bool isIncome) {
    final l = AppLocalizations.of(context)!;
    final amountControllers = isIncome
        ? _autoIncomeAmountControllers
        : _autoExpenseAmountControllers;
    final descControllers = isIncome
        ? _autoIncomeDescControllers
        : _autoExpenseDescControllers;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: descControllers[index],
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
                hintText: l.default_expenses_trips,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: amountControllers[index],
              decoration: InputDecoration(labelText: symbol),
              keyboardType: TextInputType.number,
            ),
          ),
          if (amountControllers.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() {
                amountControllers.removeAt(index);
                descControllers.removeAt(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ItemRecord {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final bool isIncome;
  final Shift? shift;
  final int? shiftIndex;
  final String? shiftInfo;
  final Expense? standaloneExpense;

  _ItemRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.isIncome,
    this.shift,
    this.shiftIndex,
    this.shiftInfo,
    this.standaloneExpense,
  });
}

class _MonthItemSection extends StatelessWidget {
  final String monthKey;
  final List<_ItemRecord> items;
  final bool isIncome;
  final Function(_ItemRecord) onEdit;

  const _MonthItemSection({
    required this.monthKey,
    required this.items,
    required this.isIncome,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final date = DateTime.parse("$monthKey-01");
    final monthName = DateFormat.MMMM(l.localeName).format(date);
    final total = items.fold<double>(0, (sum, e) => sum + e.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName ${date.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                '${l.expenses_total_label}: ${UIUtils.formatCurrency(total, symbol: symbol)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isIncome ? AppTheme.profitSoft : AppTheme.expenseSoft,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (record) => _ItemTile(
            record: record,
            isIncome: isIncome,
            onTap: () => onEdit(record),
            symbol: symbol,
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final _ItemRecord record;
  final bool isIncome;
  final VoidCallback onTap;
  final String symbol;

  const _ItemTile({
    required this.record,
    required this.isIncome,
    required this.onTap,
    required this.symbol,
  });

  Future<void> _deleteRecord(BuildContext context) async {
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final deleteTitle = isIncome
        ? l.incomes_dialog_delete_title
        : l.expenses_dialog_delete_title;
    final deleteConfirmText = isIncome
        ? l.incomes_delete_income_confirm_content
        : l.expenses_delete_expense_confirm_content;
    final deletedMsg = isIncome
        ? l.incomes_deleted_msg
        : l.expenses_deleted_msg;

    final confirm = await UIUtils.showConfirmDialog(
      context: context,
      title: deleteTitle,
      content: deleteConfirmText
          .replaceAll('[[desc]]', record.description)
          .replaceAll(
            '[[amount]]',
            UIUtils.formatCurrency(record.amount, symbol: symbol),
          ),
      isDestructive: true,
      confirmLabel: l.common_delete,
      cancelLabel: l.common_cancel,
    );
    if (!context.mounted) return;

    if (confirm == true) {
      if (record.shift != null && record.shiftIndex != null) {
        final shift = record.shift!;
        if (isIncome) {
          shift.automaticIncomes?.removeAt(record.shiftIndex!);
        } else {
          shift.automaticExpenses?.removeAt(record.shiftIndex!);
        }
        shiftProvider.updateShift(shift);
      } else if (record.standaloneExpense != null) {
        shiftProvider.deleteExpense(record.standaloneExpense!.id);
      }
      UIUtils.showSnackBar(
        context,
        deletedMsg,
        action: SnackBarAction(
          label: l.common_cancel,
          onPressed: () {
            if (record.shift != null && record.shiftIndex != null) {
              final shift = record.shift!;
              if (isIncome) {
                shift.automaticIncomes ??= [];
                shift.automaticIncomes!.insert(
                  record.shiftIndex!,
                  AutomaticExpense(
                    description: record.description,
                    amount: record.amount,
                  ),
                );
              } else {
                shift.automaticExpenses ??= [];
                shift.automaticExpenses!.insert(
                  record.shiftIndex!,
                  AutomaticExpense(
                    description: record.description,
                    amount: record.amount,
                  ),
                );
              }
              shiftProvider.updateShift(shift);
            } else if (record.standaloneExpense != null) {
              shiftProvider.addExpense(record.standaloneExpense!);
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    Widget cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isIncome ? AppTheme.profit : AppTheme.expense).withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            record.shift != null
                ? Icons.work_outline_rounded
                : (isIncome
                      ? Icons.account_balance_wallet_rounded
                      : Icons.money_off_rounded),
            color: isIncome ? AppTheme.profitSoft : AppTheme.expenseSoft,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                record.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (record.shiftInfo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.shiftInfo!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(record.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              UIUtils.formatCurrency(record.amount, symbol: symbol),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? AppTheme.profitSoft : AppTheme.expenseSoft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (isWide) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: AppLocalizations.of(context)!.common_edit,
                onPressed: onTap,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppTheme.expenseSoft,
                ),
                tooltip: AppLocalizations.of(context)!.common_delete,
                onPressed: () => _deleteRecord(context),
              ),
            ],
          ],
        ),
      ),
    );

    if (isWide) {
      return cardWidget;
    }

    final l = AppLocalizations.of(context)!;
    final deleteTitle = isIncome
        ? l.incomes_dialog_delete_title
        : l.expenses_dialog_delete_title;
    final deleteConfirmText = isIncome
        ? l.incomes_delete_income_confirm_content
        : l.expenses_delete_expense_confirm_content;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: (isIncome ? AppTheme.profit : AppTheme.expense).withValues(
            alpha: 0.18,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spaceMd),
        child: Icon(
          Icons.delete_sweep_rounded,
          color: isIncome ? AppTheme.profitSoft : AppTheme.expenseSoft,
        ),
      ),
      confirmDismiss: (direction) async => await UIUtils.showConfirmDialog(
        context: context,
        title: deleteTitle,
        content: deleteConfirmText
            .replaceAll('[[desc]]', record.description)
            .replaceAll(
              '[[amount]]',
              UIUtils.formatCurrency(record.amount, symbol: symbol),
            ),
        isDestructive: true,
        confirmLabel: l.common_delete,
        cancelLabel: l.common_cancel,
      ),
      onDismissed: (_) => _deleteRecord(context),
      child: cardWidget,
    );
  }
}
