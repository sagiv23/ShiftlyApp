import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/export_bottom_sheet.dart';
import 'package:shiftly/widgets/filter_bottom_sheet.dart';
import 'package:shiftly/widgets/year_month_tab_layout.dart';

/// Dedicated screen for full shift history browsing with Year & Month TabLayout.
class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({super.key});

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {
  bool _useTabView = true;
  int? _targetYear;
  int? _targetMonth;

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;
    final currentMonthKey = DateTime.now().toString().substring(0, 7);
    final isFilterActive = shiftProvider.activeFilter?.isActive == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.export_range_all,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFilterActive
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: isFilterActive ? AppTheme.electricCyan : null,
            ),
            tooltip: l.filter_title,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: l.export_title,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const ExportBottomSheet(),
            ),
          ),
          IconButton(
            icon: Icon(
              _useTabView
                  ? Icons.format_list_bulleted_rounded
                  : Icons.calendar_view_month_rounded,
            ),
            tooltip: _useTabView
                ? l.analytics_period_monthly
                : l.analytics_period_all_time,
            onPressed: () {
              setState(() {
                _useTabView = !_useTabView;
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isFilterActive) const ActiveFiltersBar(),
            Expanded(
              child: groupedShifts.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.event_busy_rounded,
                      title: l.shift_history_empty_title,
                      subtitle: l.shift_history_empty_subtitle,
                    )
                  : (_useTabView
                        ? YearMonthTabLayout(
                            groupedShifts: groupedShifts,
                            currentMonthKey: currentMonthKey,
                            initialYear: _targetYear,
                            initialMonth: _targetMonth,
                          )
                        : _buildListView(context, groupedShifts, l)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    Map<String, List<dynamic>> groupedShifts,
    AppLocalizations l,
  ) {
    final entries = groupedShifts.entries.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceXl,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final parts = entry.key.split('-');
        int? year;
        int? month;
        String formattedTitle = entry.key;

        if (parts.length == 2) {
          year = int.tryParse(parts[0]);
          month = int.tryParse(parts[1]);
          if (year != null && month != null) {
            final date = DateTime(year, month);
            formattedTitle =
                '${DateFormat.MMMM(l.localeName).format(date)} $year';
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              onTap: () {
                if (year != null && month != null) {
                  setState(() {
                    _targetYear = year;
                    _targetMonth = month;
                    _useTabView = true;
                  });
                }
              },
              child: Ink(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.electricCyan.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppTheme.electricCyan,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? AppTheme.primaryText
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.value.length} ${l.common_shifts_count}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.electricCyan,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
