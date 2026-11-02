import 'package:flutter/gestures.dart';
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
        label: l.analytics_section_earnings,
        icon: Icons.payments_rounded,
      ),
      _NavSectionItem(
        index: 2,
        label: l.analytics_section_work_patterns,
        icon: Icons.schedule_rounded,
      ),
      _NavSectionItem(
        index: 3,
        label: l.analytics_section_pay_breakdown,
        icon: Icons.receipt_long_rounded,
      ),
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: sections.map((item) {
                      final isSelected = selectedIndex == item.index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ScalePress(
                          onTap: () => onSectionSelected(item.index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
                                const SizedBox(width: 5),
                                Text(
                                  item.label,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
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
