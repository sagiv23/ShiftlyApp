import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/add_shift/add_shift_form_sections.dart';

class AddShiftRawTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              AddShiftFormSection(
                title: l.add_shift_paste_title,
                icon: Icons.paste_rounded,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedJobTypeId,
                      decoration: InputDecoration(
                        labelText: l.add_shift_paste_default_job_label,
                        prefixIcon: const Icon(Icons.work_history_rounded),
                      ),
                      items: jobs
                          .map(
                            (j) => DropdownMenuItem<String>(
                              value: j.id,
                              child: Text(j.name),
                            ),
                          )
                          .toList(),
                      onChanged: onJobTypeChanged,
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
                constraints: const BoxConstraints(minHeight: 200),
                child: TextField(
                  controller: rawTextController,
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
                  onTap: onSaveRaw,
                  child: ElevatedButton.icon(
                    onPressed: onSaveRaw,
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
