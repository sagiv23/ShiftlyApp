import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/break_type.dart';
import '../models/shift.dart';
import '../providers/settings_provider.dart';
import '../providers/shift_provider.dart';
import '../screens/add_shift_screen.dart';
import '../theme/app_theme.dart';
import '../utils/app_page_route.dart';
import '../utils/ui_utils.dart';

class ShiftTile extends StatelessWidget {
  final Shift shift;
  final bool useCardDecoration;
  final EdgeInsetsGeometry? margin;

  const ShiftTile({
    super.key,
    required this.shift,
    this.useCardDecoration = false,
    this.margin,
  });

  Future<void> _deleteShift(
    BuildContext context, {
    bool skipDialog = false,
  }) async {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final dateStr = DateFormat('dd/MM/yyyy').format(shift.date);

    if (!skipDialog) {
      final confirm = await UIUtils.showConfirmDialog(
        context: context,
        title: l.add_shift_delete_title,
        content: '${l.add_shift_delete_desc} $dateStr?',
        isDestructive: true,
        confirmLabel: l.common_delete,
      );
      if (!context.mounted) return;
      if (confirm != true) return;
    }

    shiftProvider.deleteShift(shift.id);
    UIUtils.showSnackBar(
      context,
      '$dateStr ${l.add_shift_delete_msg}',
      action: SnackBarAction(
        label: l.common_cancel,
        onPressed: () {
          shiftProvider.addShift(
            shift,
            l10n: {
              'title': l.notification_reminder_title,
              'body': l.notification_reminder_body,
              'hours': l.common_hours_suffix,
              'minutes': l.common_min_suffix,
              'channelName': l.notification_channel_reminders_name,
              'channelDesc': l.notification_channel_reminders_desc,
            },
          );
        },
      ),
    );
  }

  void _editShift(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute.slideHorizontal(AddShiftScreen(shiftToEdit: shift)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    final shiftProvider = context.read<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    final job = shiftProvider.getJobTypeById(shift.jobTypeId);
    final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
    final pay = shift.calculateTotalPay(rate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakType = shift.breakType ?? BreakType.none;

    Widget childContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXs,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.d().format(shift.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryDark,
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat.E(l.localeName).format(shift.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppTheme.iconForJobName(job?.name),
                      size: 16,
                      color: AppTheme.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        job?.name ?? l.common_error,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${DateFormat.Hm().format(shift.startTime)} – ${DateFormat.Hm().format(shift.endTime)}  ·  ${shift.netHours.toStringAsFixed(2)} ${l.common_hours_suffix}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (shift.tips > 0 ||
                    shift.totalAutomaticIncomes > 0 ||
                    shift.totalAutomaticExpenses > 0 ||
                    breakType != BreakType.none) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (shift.tips > 0)
                        ShiftTag(
                          label:
                              '+${UIUtils.formatCurrency(shift.tips, symbol: settings.currencySymbol)}',
                          icon: Icons.payments_outlined,
                          color: AppTheme.profit,
                        ),
                      if (shift.totalAutomaticIncomes > 0)
                        ShiftTag(
                          label:
                              '+${UIUtils.formatCurrency(shift.totalAutomaticIncomes, symbol: settings.currencySymbol)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppTheme.profit,
                        ),
                      if (breakType == BreakType.paid)
                        ShiftTag(
                          label:
                              "${settings.paidBreakDurationMinutes.toStringAsFixed(0)} ${l.common_min_suffix} ${l.add_shift_manual_paid_break}",
                          icon: Icons.timer_outlined,
                          color: AppTheme.primary,
                        ),
                      if (breakType == BreakType.unpaid)
                        ShiftTag(
                          label:
                              "${(shift.unpaidBreakMinutes ?? settings.unpaidBreakDurationMinutes).toStringAsFixed(0)} ${l.common_min_suffix} ${l.add_shift_manual_unpaid_break}",
                          icon: Icons.coffee_outlined,
                          color: AppTheme.warningSoft,
                        ),
                      if (shift.totalAutomaticExpenses > 0)
                        ShiftTag(
                          label:
                              '-${UIUtils.formatCurrency(shift.totalAutomaticExpenses, symbol: settings.currencySymbol)}',
                          icon: Icons.money_off_rounded,
                          color: AppTheme.expense,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceXs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              UIUtils.formatCurrency(pay, symbol: settings.currencySymbol),
              style: UIUtils.getCurrencyStyle(
                context,
                pay,
                positiveColor: AppTheme.primaryDark,
                baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l.common_edit,
              onPressed: () => _editShift(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppTheme.expenseSoft,
              ),
              tooltip: l.common_delete,
              onPressed: () => _deleteShift(context),
            ),
          ],
        ],
      ),
    );

    Widget tileContent;
    if (useCardDecoration) {
      tileContent = Container(
        margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spaceSm),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            onTap: () => _editShift(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm,
                vertical: AppTheme.spaceXs,
              ),
              child: childContent,
            ),
          ),
        ),
      );
    } else {
      tileContent = Padding(
        padding:
            margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () => _editShift(context),
            child: childContent,
          ),
        ),
      );
    }

    if (isWide) {
      return tileContent;
    }

    return Dismissible(
      key: Key(shift.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: useCardDecoration
            ? (margin ?? const EdgeInsets.only(bottom: AppTheme.spaceSm))
            : const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm,
                vertical: AppTheme.spaceXs / 2,
              ),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(
            useCardDecoration ? AppTheme.radiusLg : AppTheme.radiusMd,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spaceMd),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: AppTheme.expenseSoft,
        ),
      ),
      confirmDismiss: (direction) async {
        final dateStr = DateFormat('dd/MM/yyyy').format(shift.date);
        return await UIUtils.showConfirmDialog(
          context: context,
          title: l.add_shift_delete_title,
          content: '${l.add_shift_delete_desc} $dateStr?',
          isDestructive: true,
          confirmLabel: l.common_delete,
        );
      },
      onDismissed: (_) => _deleteShift(context, skipDialog: true),
      child: tileContent,
    );
  }
}

class ShiftTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const ShiftTag({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
