import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/screens/profile_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/widgets/cookie_consent_banner.dart';

class MainScreenScope extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddShift;

  const MainScreenScope({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddShift,
    required super.child,
  });

  static MainScreenScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainScreenScope>();
  }

  @override
  bool updateShouldNotify(MainScreenScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWide = screenWidth >= 768;
    final scope = MainScreenScope.of(context);
    final effectiveIndex = scope?.currentIndex ?? currentIndex;
    final activeIndex = effectiveIndex > 4 ? 2 : effectiveIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_month_rounded, size: 22),
        activeIcon: const Icon(Icons.calendar_month_rounded, size: 24),
        label: l.nav_calendar,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bar_chart_rounded, size: 22),
        activeIcon: const Icon(Icons.bar_chart_rounded, size: 24),
        label: l.nav_analytics,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_rounded, size: 24),
        activeIcon: const Icon(Icons.home_rounded, size: 26),
        label: l.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt_long_rounded, size: 22),
        activeIcon: const Icon(Icons.receipt_long_rounded, size: 24),
        label: l.nav_expenses,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.note_alt_rounded, size: 22),
        activeIcon: const Icon(Icons.note_alt_rounded, size: 24),
        label: l.nav_summaries,
      ),
    ];

    Widget mainScaffold;
    if (!isDesktopOrWide) {
      mainScaffold = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: titleWidget ??
              (title != null ? Text(title!) : Text(l.common_app_name)),
          bottom: bottom,
          actions: actions,
        ),
        drawer: Drawer(
          backgroundColor: Theme.of(context).cardTheme.color,
          child: SafeArea(
            child: SideMenuContent(
              currentIndex: activeIndex,
              onSelectTab: (index) {
                Navigator.pop(context);
                scope?.onTabSelected(index);
              },
              onAddShift: () {
                Navigator.pop(context);
                scope?.onAddShift();
              },
            ),
          ),
        ),
        body: body,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: (index) => scope?.onTabSelected(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Theme
                .of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: navItems,
          ),
        ),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    } else {
      mainScaffold = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: titleWidget ??
              (title != null ? Text(title!) : Text(l.common_app_name)),
          bottom: bottom,
          actions: actions,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    }

    if (scope != null) {
      return mainScaffold;
    }

    return Stack(children: [mainScaffold, const CookieConsentBanner()]);
  }
}

class SideMenuContent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onAddShift;

  const SideMenuContent({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.onAddShift,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // App Logo & Brand Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.common_app_name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        l.common_tagline,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // New Shift Action Item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: onAddShift,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l.home_action_new_shift),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),

            // Nav Items
            _SideNavItem(
              icon: Icons.home_rounded,
              label: l.common_app_name,
              isSelected: currentIndex == 2,
              onTap: () => onSelectTab(2),
            ),
            _SideNavItem(
              icon: Icons.calendar_month_rounded,
              label: l.home_action_calendar,
              isSelected: currentIndex == 0,
              onTap: () => onSelectTab(0),
            ),
            _SideNavItem(
              icon: Icons.bar_chart_rounded,
              label: l.analytics_title,
              isSelected: currentIndex == 1,
              onTap: () => onSelectTab(1),
            ),
            _SideNavItem(
              icon: Icons.note_alt_rounded,
              label: l.shift_descriptions_title,
              isSelected: currentIndex == 4,
              onTap: () => onSelectTab(4),
            ),
            _SideNavItem(
              icon: Icons.receipt_long_rounded,
              label: l.expenses_title,
              isSelected: currentIndex == 3,
              onTap: () => onSelectTab(3),
            ),
            _SideNavItem(
              icon: Icons.person_rounded,
              label: l.side_menu_profile,
              isSelected: false,
              onTap: () {
                final nav = Navigator.of(context);
                if (nav.canPop()) {
                  nav.pop();
                }
                nav.push(AppPageRoute.sharedAxis(const ProfileScreen()));
              },
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Settings
            _SideNavItem(
              icon: Icons.settings_outlined,
              label: l.settings_title,
              isSelected: currentIndex == 5,
              onTap: () => onSelectTab(5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? primary.withValues(alpha: 0.15) : Colors
            .transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight
                          .w600,
                      color: isSelected ? primary : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
