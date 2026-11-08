import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';

class ShiftDescriptionsScreen extends StatefulWidget {
  const ShiftDescriptionsScreen({super.key});

  @override
  State<ShiftDescriptionsScreen> createState() =>
      _ShiftDescriptionsScreenState();
}

class _ShiftDescriptionsScreenState extends State<ShiftDescriptionsScreen> {
  bool _isLoading = true;
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _deleteDescription(BuildContext context,
      Shift shift, {
        bool skipDialog = false,
      }) async {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final oldDesc = shift.description;
    final dateStr = AppConstants.formatDate(shift.date);

    if (!skipDialog) {
      final confirm = await UIUtils.showConfirmDialog(
        context: context,
        title: l.shift_descriptions_delete_title,
        content: '${l.shift_descriptions_delete_content} $dateStr?',
        isDestructive: true,
        confirmLabel: l.common_delete,
      );
      if (!context.mounted) return;
      if (confirm != true) return;
    }

    shift.description = null;
    shiftProvider.updateShift(shift);
    UIUtils.showSnackBar(
      context,
      l.shift_descriptions_deleted_msg,
      action: SnackBarAction(
        label: l.common_cancel,
        onPressed: () {
          shift.description = oldDesc;
          shiftProvider.updateShift(shift);
        },
      ),
    );
  }

  void _editDescription(BuildContext context, Shift shift) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: shift.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text(l.shift_descriptions_edit_title),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l.shift_description_label,
                hintText: l.shift_description_hint,
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.common_cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final newDesc = controller.text.trim();
                  shift.description = newDesc.isEmpty ? null : newDesc;
                  context.read<ShiftProvider>().updateShift(shift);
                  Navigator.pop(ctx);
                  UIUtils.showSnackBar(
                    context,
                    l.shift_descriptions_updated_msg,
                  );
                },
                child: Text(l.common_save),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.watch<ShiftProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return AdaptiveScaffold(
        currentIndex: 4,
        title: l.shift_descriptions_title,
        body: const ShiftDescriptionsScreenSkeleton(),
      );
    }

    // Filter shifts that have descriptions
    List<Shift> shiftsWithDesc = shiftProvider.shifts.where((s) {
      return s.description != null && s.description!.trim().isNotEmpty;
    }).toList();

    if (_selectedDateFilter != null) {
      shiftsWithDesc = shiftsWithDesc.where((s) {
        return s.date.year == _selectedDateFilter!.year &&
            s.date.month == _selectedDateFilter!.month &&
            s.date.day == _selectedDateFilter!.day;
      }).toList();
    }

    // Sort by date descending
    shiftsWithDesc.sort((a, b) => b.date.compareTo(a.date));

    // Group by date
    final groupedShifts = groupBy(
      shiftsWithDesc,
          (s) => AppConstants.formatIsoDate(s.date),
    );

    return AdaptiveScaffold(
      currentIndex: 4,
      title: l.shift_descriptions_title,
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
            final picked = await AppDatePicker.showSingleDatePicker(
              context: context,
              initialDate: _selectedDateFilter ?? DateTime.now(),
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
                margin: const EdgeInsets.all(AppTheme.spaceSm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.electricCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppTheme.electricCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l.common_filter_date}: ${AppConstants.formatDate(_selectedDateFilter!)}',
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
            Expanded(
              child: shiftProvider.isLoading && shiftProvider.shifts.isEmpty
                  ? const ExpensesScreenSkeleton()
                  : PageEntranceAnimation(
                      delayFraction: 0.1,
                      child: groupedShifts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppTheme.electricCyan.withValues(
                                          alpha: 0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.note_alt_outlined,
                                        size: 56,
                                        color: AppTheme.electricCyan,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l.shift_descriptions_empty,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: isDark
                                                ? AppTheme.secondaryText
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(
                                AppTheme.spaceSm,
                                AppTheme.spaceXs,
                                AppTheme.spaceSm,
                                120,
                              ),
                              children: groupedShifts.keys.map((dateKey) {
                                final dateShifts = groupedShifts[dateKey]!;
                                final parsedDate = DateTime.parse(dateKey);
                                final formattedDate = DateFormat(
                                  'EEEE, dd/MM/yyyy',
                                  l.localeName,
                                ).format(parsedDate);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.electricCyan,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ...dateShifts.map((shift) {
                                      final job = shiftProvider.getJobTypeById(
                                        shift.jobTypeId,
                                      );
                                      final jobName =
                                          job?.name ?? l.common_unknown_job;
                                      final timeStr =
                                          '${AppConstants.formatTime(
                                          shift.startTime)} - ${AppConstants
                                          .formatTime(shift.endTime)}';
                                      final screenWidth = MediaQuery
                                          .of(context)
                                          .size
                                          .width;
                                      final isWide = screenWidth >=
                                          AppConstants.wideScreenWidth;

                                      final cardWidget = Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: ListTile(
                                          onTap: () =>
                                              _editDescription(context, shift),
                                          leading: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppTheme.electricCyan
                                                  .withValues(alpha: 0.14),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppTheme.electricCyan
                                                    .withValues(alpha: 0.25),
                                              ),
                                            ),
                                            child: Icon(
                                              AppTheme.iconForJobName(jobName),
                                              color: AppTheme.electricCyan,
                                              size: 20,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  jobName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  timeStr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppTheme.secondaryText
                                                        : Colors.grey.shade600,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Text(
                                              shift.description ?? '',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isWide) ...[
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 20),
                                                  tooltip: l.common_edit,
                                                  onPressed: () =>
                                                      _editDescription(
                                                          context, shift),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 20,
                                                    color: AppTheme.softCoral,
                                                  ),
                                                  tooltip: l.common_delete,
                                                  onPressed: () =>
                                                      _deleteDescription(
                                                          context, shift),
                                                ),
                                              ] else
                                                ...[
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(
                                                        Icons.more_vert,
                                                        size: 20),
                                                    tooltip: l.common_edit,
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _editDescription(
                                                            context, shift);
                                                      } else
                                                      if (value == 'delete') {
                                                        _deleteDescription(
                                                            context, shift);
                                                      }
                                                    },
                                                    itemBuilder: (context) =>
                                                    [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            const Icon(Icons
                                                                .edit_outlined,
                                                                size: 18),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(l.common_edit),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .delete_outline_rounded,
                                                              size: 18,
                                                              color: AppTheme
                                                                  .softCoral,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              l.common_delete,
                                                              style: const TextStyle(
                                                                  color: AppTheme
                                                                      .softCoral),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                            ],
                                          ),
                                        ),
                                      );

                                      if (isWide) {
                                        return cardWidget;
                                      }

                                      return Dismissible(
                                        key: Key(shift.id),
                                        direction: DismissDirection.startToEnd,
                                        background: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.softCoral
                                                .withValues(
                                                alpha: isDark ? 0.25 : 0.15),
                                            borderRadius: BorderRadius.circular(
                                                AppTheme.radiusMd),
                                          ),
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(
                                              right: AppTheme.spaceMd),
                                          child: const Icon(
                                            Icons.delete_sweep_rounded,
                                            color: AppTheme.softCoral,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          final dateStr = AppConstants
                                              .formatDate(shift.date);
                                          return await UIUtils
                                              .showConfirmDialog(
                                            context: context,
                                            title: l
                                                .shift_descriptions_delete_title,
                                            content: '${l
                                                .shift_descriptions_delete_content} $dateStr?',
                                            isDestructive: true,
                                            confirmLabel: l.common_delete,
                                          );
                                        },
                                        onDismissed: (_) =>
                                            _deleteDescription(context, shift,
                                                skipDialog: true),
                                        child: cardWidget,
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
