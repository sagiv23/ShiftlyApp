import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';

class AnalyticsNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;

  const AnalyticsNav({
    super.key,
    required this.selectedIndex,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = [
      _NavSectionItem(
        index: 0,
        label: l.analytics_section_overview,
        icon: Icons.grid_view_rounded,
      ),
      _NavSectionItem(
        index: 1,
        label: l.analytics_section_pay_breakdown,
        icon: Icons.receipt_long_rounded,
      ),
      _NavSectionItem(
        index: 2,
        label: l.analytics_section_earnings,
        icon: Icons.payments_rounded,
      ),
      _NavSectionItem(
        index: 3,
        label: l.analytics_section_work_patterns,
        icon: Icons.schedule_rounded,
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final spacing = 8.0;
            final itemWidth = isWide
                ? 210.0
                : (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: sections.map((item) {
                final isSelected = selectedIndex == item.index;
                return SizedBox(
                  width: itemWidth,
                  child: ScalePress(
                    onTap: () => onSectionSelected(item.index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.electricCyan.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        )
                            : (isDark
                            ? AppTheme.darkSurfaceElevated
                            : AppTheme.lightSurfaceElevated),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSm,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.electricCyan.withValues(
                            alpha: 0.4,
                          )
                              : (isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 15,
                            color: isSelected
                                ? AppTheme.electricCyan
                                : (isDark
                                ? AppTheme.secondaryText
                                : Colors.grey.shade600),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.electricCyan
                                    : (isDark
                                    ? AppTheme.primaryText
                                    : const Color(0xFF334155)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _NavSectionItem {
  final int index;
  final String label;
  final IconData icon;

  const _NavSectionItem({
    required this.index,
    required this.label,
    required this.icon,
  });
}
