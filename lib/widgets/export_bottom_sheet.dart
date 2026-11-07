import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_animations.dart';
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
  String _format = 'excel';
  bool _includeAnalytics = true;
  String _rangeType = 'all';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        color: isDark
            ? AppTheme.darkCard
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
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
                  Row(
                    children: [
                      const Icon(
                          Icons.output_rounded, color: AppTheme.electricCyan),
                      const SizedBox(width: 8),
                      Text(
                        l.export_title,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
              const SizedBox(height: 10),

              // Format Selection Grid (2 columns for 5 options: Excel, PDF, CSV, TXT, JSON)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.8,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _formatCard(
                    id: 'excel',
                    label: l.export_format_excel,
                    icon: Icons.grid_on_rounded,
                    accentColor: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  _formatCard(
                    id: 'pdf',
                    label: l.export_format_pdf,
                    icon: Icons.picture_as_pdf_rounded,
                    accentColor: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                  _formatCard(
                    id: 'csv',
                    label: l.export_format_csv,
                    icon: Icons.table_chart_rounded,
                    accentColor: const Color(0xFF0284C7),
                    isDark: isDark,
                  ),
                  _formatCard(
                    id: 'txt',
                    label: l.export_format_txt,
                    icon: Icons.description_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                    isDark: isDark,
                  ),
                  _formatCard(
                    id: 'json',
                    label: l.export_format_json,
                    icon: Icons.code_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ],
              ),

              if (_format == 'excel' || _format == 'pdf') ...[
                const SizedBox(height: AppTheme.spaceSm),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l.export_include_analytics,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l.export_include_analytics_sub,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _includeAnalytics,
                    activeThumbColor: AppTheme.electricCyan,
                    activeTrackColor: AppTheme.electricCyan.withValues(
                        alpha: 0.4),
                    inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors
                        .white,
                    inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors
                        .grey.shade300,
                    onChanged: (val) => setState(() => _includeAnalytics = val),
                  ),
                ),
              ],
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
                          trailing: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppTheme.electricCyan,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : Colors.grey.shade400,
                            ),
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
                          trailing: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppTheme.electricCyan,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : Colors.grey.shade400,
                            ),
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
                      includeAnalytics: _includeAnalytics,
                      isHebrew: settings.locale.languageCode == 'he' ||
                          settings.locale.languageCode == 'ar',
                      l: l,
                      rules: settings.overtimeRules,
                      shabbatRules: settings.shabbatHolidayRules,
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context);
                    if (filePath != null && filePath.isNotEmpty) {
                      if (filePath != 'saved') {
                        await OpenFilex.open(filePath);
                      }
                      if (!context.mounted) return;
                      UIUtils.showSnackBar(
                        context,
                        '${l.export_success_msg} ($filePath)',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF040711),
                  ),
                  label: Text(
                    l.export_button,
                    style: const TextStyle(
                      color: Color(0xFF040711),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.electricCyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animateEntrance(context: context);
  }

  Widget _formatCard({
    required String id,
    required String label,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    final isSelected = _format == id;
    return InkWell(
      onTap: () => setState(() => _format = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : (isDark
                ? AppTheme.darkBorder
                : Colors.grey.shade300),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
