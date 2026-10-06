import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/automatic_expense.dart';
import '../models/expense.dart';
import '../models/shift.dart';
import '../providers/shift_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ui_utils.dart';

class ExpenseRecord {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final bool isIncome;
  final Shift? shift;
  final int? shiftIndex;
  final String? shiftInfo;
  final Expense? standaloneExpense;

  ExpenseRecord({
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

class ExpenseTile extends StatelessWidget {
  final ExpenseRecord record;
  final bool isIncome;
  final VoidCallback onTap;
  final String symbol;

  const ExpenseTile({
    super.key,
    required this.record,
    required this.isIncome,
    required this.onTap,
    required this.symbol,
  });

  Future<void> _deleteRecord(
    BuildContext context, {
    bool skipDialog = false,
  }) async {
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

    if (!skipDialog) {
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
      if (confirm != true) return;
    }

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
      onDismissed: (_) => _deleteRecord(context, skipDialog: true),
      child: cardWidget,
    );
  }
}
