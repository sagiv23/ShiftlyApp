import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/import_utils.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/add_shift/add_shift_form_sections.dart';

class AddShiftRawTab extends StatefulWidget {
  final List<JobType> jobs;
  final String? selectedJobTypeId;
  final ValueChanged<String?> onJobTypeChanged;
  final TextEditingController rawTextController;
  final VoidCallback onSaveRaw;

  const AddShiftRawTab({
    super.key,
    required this.jobs,
    required this.selectedJobTypeId,
    required this.onJobTypeChanged,
    required this.rawTextController,
    required this.onSaveRaw,
  });

  @override
  State<AddShiftRawTab> createState() => _AddShiftRawTabState();
}

class _AddShiftRawTabState extends State<AddShiftRawTab> {
  bool _isImporting = false;

  Future<void> _pickAndImportFile() async {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'json', 'txt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);
      final file = result.files.first;

      final importResult = await ImportUtils.importFromFile(
        file,
        widget.jobs,
        defaultJobId: widget.selectedJobTypeId ??
            (widget.jobs.isNotEmpty ? widget.jobs.first.id : 'default'),
      );

      setState(() => _isImporting = false);

      if (!mounted) return;

      if (importResult.shifts.isEmpty) {
        UIUtils.showSnackBar(
          context,
          importResult.errorMessage ?? l.import_error_msg,
          isError: true,
        );
        return;
      }

      await _showImportPreviewDialog(importResult.shifts, shiftProvider, l);
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        UIUtils.showSnackBar(context, l.import_error_msg, isError: true);
      }
    }
  }

  void _handleSaveOrParseRaw() async {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final content = widget.rawTextController.text.trim();

    if (content.isEmpty) {
      widget.onSaveRaw();
      return;
    }

    // Try multi-shift parsing from pasted text
    final defaultJobId = widget.selectedJobTypeId ??
        (widget.jobs.isNotEmpty ? widget.jobs.first.id : 'default');
    final importResult = ImportUtils.parseFromText(
        content, widget.jobs, defaultJobId);

    if (importResult.shifts.length > 1) {
      await _showImportPreviewDialog(importResult.shifts, shiftProvider, l);
    } else {
      widget.onSaveRaw();
    }
  }

  Future<void> _showImportPreviewDialog(List<Shift> shifts,
      ShiftProvider shiftProvider,
      AppLocalizations l,) async {
    final double totalHours = shifts.fold(0.0, (sum, s) => sum + s.netHours);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.download_rounded, color: AppTheme.electricCyan),
              const SizedBox(width: 8),
              Text(l.import_preview_title),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.import_found_shifts(shifts.length),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Hours: ${totalHours.toStringAsFixed(1)} hrs',
                  style: TextStyle(color: Theme
                      .of(context)
                      .colorScheme
                      .onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                const Divider(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shifts.length > 10 ? 10 : shifts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final s = shifts[index];
                      final job = widget.jobs.firstWhere(
                            (j) => j.id == s.jobTypeId,
                        orElse: () => JobType(id: '', name: 'Default'),
                      );
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            '${DateFormat('dd/MM/yyyy').format(s.date)} • ${job
                                .name}'),
                        subtitle: Text('${DateFormat('HH:mm').format(
                            s.startTime)} - ${DateFormat('HH:mm').format(
                            s.endTime)} (${s.netHours.toStringAsFixed(
                            1)} hrs)'),
                        trailing: s.tips > 0 ? Text(
                            '+${s.tips.toStringAsFixed(0)} tips',
                            style: const TextStyle(color: Colors.green,
                                fontWeight: FontWeight.bold)) : null,
                      );
                    },
                  ),
                ),
                if (shifts.length > 10)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '... and ${shifts.length - 10} more shifts',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.electricCyan,
                foregroundColor: const Color(0xFF040711),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.import_confirm_button(shifts.length)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (var s in shifts) {
        await shiftProvider.addShift(s);
      }
      widget.rawTextController.clear();
      if (mounted) {
        UIUtils.showSnackBar(context, l.import_success_msg(shifts.length));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // File Import Hero Section
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.electricCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.electricCyan.withValues(
                                alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppTheme.electricCyan,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.import_title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                l.import_paste_or_pick,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isImporting ? null : _pickAndImportFile,
                        icon: _isImporting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.folder_open_rounded),
                        label: Text(l.import_button),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricCyan,
                          foregroundColor: const Color(0xFF040711),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              AddShiftFormSection(
                title: l.add_shift_paste_title,
                icon: Icons.paste_rounded,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: widget.selectedJobTypeId,
                      decoration: InputDecoration(
                        labelText: l.add_shift_paste_default_job_label,
                        prefixIcon: const Icon(Icons.work_history_rounded),
                      ),
                      items: widget.jobs
                          .map(
                            (j) => DropdownMenuItem<String>(
                              value: j.id,
                              child: Text(j.name),
                            ),
                          )
                          .toList(),
                      onChanged: widget.onJobTypeChanged,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.primaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.add_shift_paste_format_info,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Container(
                decoration: AppTheme.sectionDecoration(context),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minHeight: 180),
                child: TextField(
                  controller: widget.rawTextController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: l.add_shift_paste_hint,
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: double.infinity,
                child: ScalePress(
                  onTap: _handleSaveOrParseRaw,
                  child: ElevatedButton.icon(
                    onPressed: _handleSaveOrParseRaw,
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(l.add_shift_paste_parse_button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
