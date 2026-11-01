import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_date_picker.dart';
import 'package:shiftly/utils/ui_utils.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ShiftFilter _filter;

  @override
  void initState() {
    super.initState();
    final active = context.read<ShiftProvider>().activeFilter;
    if (active != null) {
      _filter = active;
    } else {
      final jobTypes = context.read<ShiftProvider>().jobTypes;
      _filter = ShiftFilter(
        typeIds: jobTypes.isNotEmpty ? [jobTypes.first.id] : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final jobTypes = shiftProvider.jobTypes;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    // Calculate dynamic maximums
    double maxWage = shiftProvider.maxCapturedWage;
    if (maxWage == 0) maxWage = 500;

    double maxTips = shiftProvider.maxCapturedTips;
    if (maxTips == 0) maxTips = 500;

    double maxExpenses = shiftProvider.maxCapturedExpenses;
    if (maxExpenses == 0) maxExpenses = 500;

    double maxDuration = shiftProvider.maxCapturedDuration;
    if (maxDuration == 0) maxDuration = 24;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.filter_title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = ShiftFilter();
                    });
                  },
                  child: Text(l.filter_clear_all),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                0,
                AppTheme.spaceMd,
                40, // Spacing for navigation buttons
              ),
              children: [
                _buildRangeSection(
                  title: l.filter_wage_range,
                  min: 0,
                  max: maxWage,
                  values: RangeValues(
                    (_filter.minWage ?? 0).clamp(0, maxWage),
                    (_filter.maxWage ?? maxWage).clamp(0, maxWage),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minWage: v.start,
                        maxWage: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_tips_range,
                  min: 0,
                  max: maxTips,
                  values: RangeValues(
                    (_filter.minTips ?? 0).clamp(0, maxTips),
                    (_filter.maxTips ?? maxTips).clamp(0, maxTips),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minTips: v.start,
                        maxTips: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_expenses_range,
                  min: 0,
                  max: maxExpenses,
                  values: RangeValues(
                    (_filter.minExpenses ?? 0).clamp(0, maxExpenses),
                    (_filter.maxExpenses ?? maxExpenses).clamp(0, maxExpenses),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minExpenses: v.start,
                        maxExpenses: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_duration_range,
                  min: 0,
                  max: maxDuration,
                  values: RangeValues(
                    (_filter.minDuration ?? 0).clamp(0, maxDuration),
                    (_filter.maxDuration ?? maxDuration).clamp(0, maxDuration),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minDuration: v.start,
                        maxDuration: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) => v.toStringAsFixed(1),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l.filter_date_range,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _filter.startDate != null && _filter.endDate != null
                          ? "${DateFormat.yMd().format(_filter.startDate!)} - ${DateFormat.yMd().format(_filter.endDate!)}"
                          : l.common_start,
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final range = await AppDatePicker.showDateRangePicker(
                        context: context,
                        initialDateRange:
                            _filter.startDate != null && _filter.endDate != null
                            ? DateTimeRange(
                                start: _filter.startDate!,
                                end: _filter.endDate!,
                              )
                            : null,
                      );
                      if (range != null) {
                        setState(() {
                          _filter = _filter.copyWith(
                            startDate: range.start,
                            endDate: range.end,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                _buildJobTypeMultiSelect(jobTypes),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              0,
              AppTheme.spaceMd,
              24, // Spacing for buttons
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_filter.typeIds == null || _filter.typeIds!.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    l.filter_error_no_job_selected,
                    isError: true,
                  );
                  return;
                }
                shiftProvider.setFilter(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.electricCyan,
                foregroundColor: const Color(0xFF040711),
              ),
              child: Text(l.filter_apply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeMultiSelect(List<JobType> jobTypes) {
    final l = AppLocalizations.of(context)!;
    final selectedIds = _filter.typeIds ?? [];
    final allSelected =
        jobTypes.isNotEmpty && selectedIds.length == jobTypes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.filter_job_type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (jobTypes.length > 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _filter = _filter.copyWith(typeIds: []);
                    } else {
                      _filter = _filter.copyWith(
                        typeIds: jobTypes.map((j) => j.id).toList(),
                      );
                    }
                  });
                },
                child: Text(
                  allSelected ? l.filter_clear_all : l.filter_select_all,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: jobTypes.map((JobType job) {
                final isSelected = selectedIds.contains(job.id);
                return CheckboxListTile(
                  title: Text(job.name, style: const TextStyle(fontSize: 14)),
                  value: isSelected,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                  onChanged: (bool? value) {
                    setState(() {
                      final newList = List<String>.from(selectedIds);
                      if (value == true) {
                        newList.add(job.id);
                      } else {
                        newList.remove(job.id);
                      }
                      _filter = _filter.copyWith(typeIds: newList);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSection({
    required String title,
    required double min,
    required double max,
    required RangeValues values,
    required ValueChanged<RangeValues> onChanged,
    required String Function(double) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "${labelBuilder(values.start)} - ${labelBuilder(values.end)}",
              style: const TextStyle(
                color: AppTheme.electricCyan,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: max > min ? (max - min).toInt().clamp(1, 10000) : 1,
          activeColor: AppTheme.electricCyan,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ActiveFiltersBar extends StatelessWidget {
  const ActiveFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();
    final filter = provider.activeFilter;
    if (filter == null || !filter.isActive) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
        children: [
          Center(
            child: Text(
              l.filter_active_filters,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          if (filter.minWage != null || filter.maxWage != null)
            _ActiveFilterChip(
              label: l.filter_chip_wage
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minWage ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxWage ?? 5000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinWage: true, clearMaxWage: true),
              ),
            ),
          if (filter.minTips != null || filter.maxTips != null)
            _ActiveFilterChip(
              label: l.filter_chip_tips
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minTips ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxTips ?? 1000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinTips: true, clearMaxTips: true),
              ),
            ),
          if (filter.minExpenses != null || filter.maxExpenses != null)
            _ActiveFilterChip(
              label: l.filter_chip_expenses
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(
                      filter.minExpenses ?? 0,
                      symbol: symbol,
                    ),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxExpenses ?? 500,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinExpenses: true, clearMaxExpenses: true),
              ),
            ),
          if (filter.minDuration != null || filter.maxDuration != null)
            _ActiveFilterChip(
              label: l.filter_chip_duration
                  .replaceFirst(
                    '[[min]]',
                    (filter.minDuration ?? 0).toStringAsFixed(1),
                  )
                  .replaceFirst(
                    '[[max]]',
                    (filter.maxDuration ?? 24).toStringAsFixed(1),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinDuration: true, clearMaxDuration: true),
              ),
            ),
          if (filter.startDate != null || filter.endDate != null)
            _ActiveFilterChip(
              label: l.filter_chip_date
                  .replaceFirst(
                    '[[start]]',
                    filter.startDate != null
                        ? DateFormat('dd/MM').format(filter.startDate!)
                        : '...',
                  )
                  .replaceFirst(
                    '[[end]]',
                    filter.endDate != null
                        ? DateFormat('dd/MM').format(filter.endDate!)
                        : '...',
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearStartDate: true, clearEndDate: true),
              ),
            ),
          if (filter.typeIds != null && filter.typeIds!.isNotEmpty)
            _ActiveFilterChip(
              label: l.filter_chip_job.replaceFirst(
                '[[name]]',
                filter.typeIds!.length == 1
                    ? provider.getJobTypeById(filter.typeIds!.first)?.name ??
                          '?'
                    : '${filter.typeIds!.length} ${l.common_shifts_count}',
              ),
              onDeleted: () =>
                  provider.setFilter(filter.copyWith(clearTypeIds: true)),
            ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => provider.clearFilter(),
            child: Text(
              l.filter_clear_all,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _ActiveFilterChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppTheme.electricCyan.withValues(alpha: 0.12),
        side: BorderSide(color: AppTheme.electricCyan.withValues(alpha: 0.25)),
      ),
    );
  }
}
