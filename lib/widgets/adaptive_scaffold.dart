import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/screens/analytics_screen.dart';
import 'package:shiftly/screens/calendar_screen.dart';
import 'package:shiftly/screens/expenses_screen.dart';
import 'package:shiftly/screens/home_screen.dart';
import 'package:shiftly/screens/settings_screen.dart';
import 'package:shiftly/theme/app_theme.dart';

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

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const HomeScreen();
        break;
      case 1:
        targetScreen = const CalendarScreen();
        break;
      case 2:
        targetScreen = const AnalyticsScreen();
        break;
      case 3:
        targetScreen = const ExpensesScreen();
        break;
      case 4:
        targetScreen = const SettingsScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  static void _openAddShiftScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddShiftScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWide = screenWidth >= 768;

    // 4 items on mobile bottom bar so text never truncates
    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_rounded, size: 22),
        label: l.common_app_name,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_month_rounded, size: 22),
        label: l.home_action_calendar,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bar_chart_rounded, size: 22),
        label: l.analytics_title,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt_long_rounded, size: 22),
        label: l.expenses_title,
      ),
    ];

    if (isDesktopOrWide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: Border(
                  right: Theme.of(context).brightness == Brightness.dark
                      ? const BorderSide(color: AppTheme.darkBorder)
                      : const BorderSide(color: AppTheme.lightBorder),
                ),
              ),
              child: _SideMenuContent(
                currentIndex: currentIndex,
                onSelectTab: (index) => _onItemTapped(context, index),
                onAddShift: () => _openAddShiftScreen(context),
              ),
            ),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title:
                      titleWidget ??
                      (title != null
                          ? Text(
                              title!,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              l.common_app_name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            )),
                  bottom: bottom,
                  actions: actions,
                ),
                body: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: body,
                  ),
                ),
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            titleWidget ??
            (title != null ? Text(title!) : Text(l.common_app_name)),
        bottom: bottom,
        actions: actions,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardTheme.color,
        child: _SideMenuContent(
          currentIndex: currentIndex,
          onSelectTab: (index) {
            Navigator.pop(context);
            _onItemTapped(context, index);
          },
          onAddShift: () {
            Navigator.pop(context);
            _openAddShiftScreen(context);
          },
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex > 3 ? 0 : currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: navItems,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class _SideMenuContent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onAddShift;

  const _SideMenuContent({
    required this.currentIndex,
    required this.onSelectTab,
    required this.onAddShift,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 24),
        // App Logo & Brand Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.access_time_filled_rounded, size: 38),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.common_app_name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 12),
        // New Shift Action Item
        _SideNavItem(
          icon: Icons.add_rounded,
          label: l.home_action_new_shift,
          isSelected: false,
          onTap: onAddShift,
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, indent: 16, endIndent: 16),
        const SizedBox(height: 4),
        // Nav items
        _SideNavItem(
          icon: Icons.home_rounded,
          label: l.common_app_name,
          isSelected: currentIndex == 0,
          onTap: () => onSelectTab(0),
        ),
        _SideNavItem(
          icon: Icons.calendar_month_rounded,
          label: l.home_action_calendar,
          isSelected: currentIndex == 1,
          onTap: () => onSelectTab(1),
        ),
        _SideNavItem(
          icon: Icons.bar_chart_rounded,
          label: l.analytics_title,
          isSelected: currentIndex == 2,
          onTap: () => onSelectTab(2),
        ),
        _SideNavItem(
          icon: Icons.receipt_long_rounded,
          label: l.expenses_title,
          isSelected: currentIndex == 3,
          onTap: () => onSelectTab(3),
        ),
        const Spacer(),
        const Divider(height: 1),
        // Settings separated at the bottom
        _SideNavItem(
          icon: Icons.settings_outlined,
          label: l.settings_title,
          isSelected: currentIndex == 4,
          onTap: () => onSelectTab(4),
        ),
        const SizedBox(height: 16),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
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
