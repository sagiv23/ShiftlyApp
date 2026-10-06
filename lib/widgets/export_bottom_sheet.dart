import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/export_utils.dart';
import 'package:shiftly/utils/ui_utils.dart';

class ExportBottomSheet extends StatefulWidget {
  const ExportBottomSheet({super.key});

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  String _format = 'csv'; // 'csv' or 'txt'
  String _rangeType = 'all'; // 'all', 'month', 'custom'
  String? _selectedMonthKey;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;
    final monthKeys = groupedShifts.keys.toList();

    if (_selectedMonthKey == null && monthKeys.isNotEmpty) {
      _selectedMonthKey = monthKeys.first;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.export_title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                l.export_format_label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'csv',
                    label: Text(l.export_format_csv),
                    icon: const Icon(Icons.table_chart_rounded),
                  ),
                  ButtonSegment(
                    value: 'txt',
                    label: Text(l.export_format_txt),
                    icon: const Icon(Icons.description_rounded),
                  ),
                ],
                selected: {_format},
                onSelectionChanged: (val) =>
                    setState(() => _format = val.first),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                l.export_range_label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _rangeType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(l.export_range_all),
                  ),
                  if (monthKeys.isNotEmpty)
                    DropdownMenuItem(
                      value: 'month',
                      child: Text(l.export_range_month),
                    ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text(l.export_range_custom),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _rangeType = val);
                },
              ),
              if (_rangeType == 'month' && monthKeys.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMonthKey,
                  decoration: InputDecoration(
                    labelText: l.export_select_month,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  items: monthKeys.map((key) {
                    final date = DateTime.parse('$key-01');
                    final monthName = DateFormat.MMMM(
                      l.localeName,
                    ).format(date);
                    return DropdownMenuItem(
                      value: key,
                      child: Text('$monthName ${date.year}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMonthKey = val);
                  },
                ),
              ],
              if (_rangeType == 'custom') ...[
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(l.export_start_date),
                          subtitle: Text(AppConstants.formatDate(_startDate)),
                          trailing: const Icon(Icons.calendar_today_rounded),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          onTap: () async {
                            final picked =
                                await AppDatePicker.showSingleDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(l.export_end_date),
                          subtitle: Text(AppConstants.formatDate(_endDate)),
                          trailing: const Icon(Icons.calendar_today_rounded),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          onTap: () async {
                            final picked =
                                await AppDatePicker.showSingleDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppTheme.spaceLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    List<Shift> shiftsToExport = [];
                    if (_rangeType == 'all') {
                      shiftsToExport = shiftProvider.shifts;
                    } else if (_rangeType == 'month' &&
                        _selectedMonthKey != null) {
                      shiftsToExport = groupedShifts[_selectedMonthKey] ?? [];
                    } else if (_rangeType == 'custom') {
                      shiftsToExport = shiftProvider.shifts.where((s) {
                        return (s.date.isAfter(
                              _startDate.subtract(const Duration(days: 1)),
                            ) &&
                            s.date.isBefore(
                              _endDate.add(const Duration(days: 1)),
                            ));
                      }).toList();
                    }

                    if (shiftsToExport.isEmpty) {
                      UIUtils.showSnackBar(
                        context,
                        l.export_empty_error,
                        isError: true,
                      );
                      return;
                    }

                    final filePath = await ExportUtils.exportShifts(
                      shiftProvider: shiftProvider,
                      shifts: shiftsToExport,
                      format: _format,
                      currencySymbol: settings.currencySymbol,
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context); // Close bottom sheet
                    if (filePath != null && filePath.isNotEmpty) {
                      if (filePath != 'saved') {
                        await OpenFilex.open(filePath);
                      }
                      if (!context.mounted) return;
                      UIUtils.showSnackBar(
                        context,
                        '${l.export_success_msg} (Downloads)',
                      );
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l.export_button),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
