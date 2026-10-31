import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;
    final currentMonthKey = DateTime.now().toString().substring(0, 7);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.export_range_all,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          // View Mode Toggle (Tab View vs List View)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _useTabView = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _useTabView
                              ? (isDark
                                    ? AppTheme.electricCyan.withValues(
                                        alpha: 0.25,
                                      )
                                    : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: _useTabView
                              ? Border.all(
                                  color: AppTheme.electricCyan.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          Icons.calendar_view_month_rounded,
                          size: 18,
                          color: _useTabView
                              ? AppTheme.electricCyan
                              : (isDark
                                    ? AppTheme.secondaryText
                                    : Colors.grey.shade600),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _useTabView = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: !_useTabView
                              ? (isDark
                                    ? AppTheme.electricCyan.withValues(
                                        alpha: 0.25,
                                      )
                                    : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: !_useTabView
                              ? Border.all(
                                  color: AppTheme.electricCyan.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 18,
                          color: !_useTabView
                              ? AppTheme.electricCyan
                              : (isDark
                                    ? AppTheme.secondaryText
                                    : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _useTabView
            ? YearMonthTabLayout(
                groupedShifts: groupedShifts,
                currentMonthKey: currentMonthKey,
                initialYear: _targetYear,
                initialMonth: _targetMonth,
              )
            : _buildListView(context, groupedShifts, l),
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
