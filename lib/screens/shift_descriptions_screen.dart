import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';

class ShiftDescriptionsScreen extends StatefulWidget {
  const ShiftDescriptionsScreen({super.key});

  @override
  State<ShiftDescriptionsScreen> createState() =>
      _ShiftDescriptionsScreenState();
}

class _ShiftDescriptionsScreenState extends State<ShiftDescriptionsScreen> {
  DateTime? _selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final l = AppLocalizations.of(context)!;

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

    // Group by date (formatted as string or year-month-day)
    final groupedShifts = groupBy(
      shiftsWithDesc,
      (s) => DateFormat('yyyy-MM-dd').format(s.date),
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
                margin: const EdgeInsets.all(AppTheme.spaceSm),
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
                      '${l.common_filter_date}: ${DateFormat('dd/MM/yyyy').format(_selectedDateFilter!)}',
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
              child: groupedShifts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.shift_descriptions_empty,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryDark,
                                    ),
                              ),
                            ),
                            ...dateShifts.map((shift) {
                              final job = shiftProvider.getJobTypeById(
                                shift.jobTypeId,
                              );
                              final jobName = job?.name ?? l.common_unknown_job;
                              final timeStr =
                                  '${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      AppPageRoute.slideHorizontal(
                                        AddShiftScreen(shiftToEdit: shift),
                                      ),
                                    );
                                  },
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      AppTheme.iconForJobName(jobName),
                                      color: AppTheme.primaryDark,
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
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      shift.description ?? '',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
