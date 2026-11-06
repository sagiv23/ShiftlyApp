import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/shift_template.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:uuid/uuid.dart';

class ShiftTemplateChips extends StatelessWidget {
  final ValueChanged<ShiftTemplate> onSelectTemplate;
  final VoidCallback? onSaveCurrentAsTemplate;
  final String? selectedTemplateId;

  const ShiftTemplateChips({
    super.key,
    required this.onSelectTemplate,
    this.onSaveCurrentAsTemplate,
    this.selectedTemplateId,
  });

  IconData _getIconForTime(TimeOfDay start) {
    final h = start.hour;
    if (h >= 5 && h < 12) {
      return Icons.wb_sunny_rounded;
    } else if (h >= 12 && h < 18) {
      return Icons.wb_twilight_rounded;
    } else if (h >= 18 && h < 22) {
      return Icons.dark_mode_rounded;
    } else {
      return Icons.nightlight_round;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showManageTemplatesDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Consumer<SettingsProvider>(
          builder: (context, provider, _) {
            final templates = provider.shiftTemplates;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLg),
                ),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.shift_template_manage,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (templates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        l.shift_template_empty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: templates.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = templates[index];
                          final startStr = _formatTimeOfDay(t.startTime);
                          final endStr = _formatTimeOfDay(t.endTime);

                          return Material(
                            color: isDark
                                ? AppTheme.darkSecondaryBackground
                                : AppTheme.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getIconForTime(t.startTime),
                                color: AppTheme.electricCyan,
                              ),
                              title: Text(
                                t.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('$startStr - $endStr'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      showEditTemplateDialog(context, t);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppTheme.expense,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final confirm = await UIUtils.showConfirmDialog(
                                        context: context,
                                        title: l
                                            .shift_template_delete_confirm_title,
                                        content: l
                                            .shift_template_delete_confirm_content,
                                        confirmLabel: l.common_delete,
                                        isDestructive: true,
                                      );
                                      if (confirm) {
                                        await provider.deleteShiftTemplate(
                                          t.id,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showEditTemplateDialog(context, null);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l.shift_template_add_button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showEditTemplateDialog(
    BuildContext context,
    ShiftTemplate? templateToEdit,
  ) {
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(
      text: templateToEdit?.name ?? '',
    );
    TimeOfDay startTime =
        templateToEdit?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime =
        templateToEdit?.endTime ?? const TimeOfDay(hour: 16, minute: 0);
    BreakType breakType = templateToEdit?.breakType ?? BreakType.unpaid;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String formatTime(TimeOfDay t) {
              final h = t.hour.toString().padLeft(2, '0');
              final m = t.minute.toString().padLeft(2, '0');
              return '$h:$m';
            }

            return AlertDialog(
              title: Text(
                templateToEdit == null
                    ? l.shift_template_new_title
                    : l.shift_template_edit_title,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l.shift_template_name_label,
                        hintText: l.shift_template_morning,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setDialogState(() => startTime = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: l.add_shift_manual_start_time_label,
                                border: const OutlineInputBorder(),
                              ),
                              child: Text(formatTime(startTime)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setDialogState(() => endTime = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: l.add_shift_manual_end_time_label,
                                border: const OutlineInputBorder(),
                              ),
                              child: Text(formatTime(endTime)),
                            ),
                          ),
                        ),
                      ],
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
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final settings = context.read<SettingsProvider>();
                    final newTemplate = ShiftTemplate(
                      id: templateToEdit?.id ?? const Uuid().v4(),
                      name: name,
                      startTime: startTime,
                      endTime: endTime,
                      breakType: breakType,
                      jobTypeId: templateToEdit?.jobTypeId,
                    );

                    if (templateToEdit == null) {
                      await settings.addShiftTemplate(newTemplate);
                    } else {
                      await settings.updateShiftTemplate(newTemplate);
                    }

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      UIUtils.showSnackBar(
                        context,
                        l.shift_template_saved_snack,
                      );
                    }
                  },
                  child: Text(l.common_save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final templates = settings.shiftTemplates;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppTheme.electricCyan,
                ),
                const SizedBox(width: 6),
                Text(
                  l.shift_template_select_prompt,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onSaveCurrentAsTemplate != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onSaveCurrentAsTemplate!();
                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: Text(
                      l.shift_template_save_current,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                TextButton.icon(
                  onPressed: () => _showManageTemplatesDialog(context),
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: Text(
                    l.shift_template_manage,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: templates.map((t) {
                final isSelected = t.id == selectedTemplateId;
                final startStr = _formatTimeOfDay(t.startTime);
                final endStr = _formatTimeOfDay(t.endTime);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : isDark
                        ? AppTheme.darkSecondaryBackground
                        : AppTheme.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onSelectTemplate(t);
                        UIUtils.showSnackBar(
                          context,
                          l.shift_template_applied_snack,
                        );
                      },
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForTime(t.startTime),
                              size: 16,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.name,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '$startStr - $endStr',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
