import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/screens/calendar_screen.dart';
import 'package:shiftly/screens/expenses_screen.dart';
import 'package:shiftly/screens/home_screen.dart';
import 'package:shiftly/screens/settings_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/widgets/export_bottom_sheet.dart';

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
        targetScreen = const ExpensesScreen();
        break;
      case 3:
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWide = screenWidth >= 768;

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_rounded),
        label: l.common_app_name,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_month_rounded),
        label: l.home_action_calendar,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt_long_rounded),
        label: l.expenses_title,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        label: l.settings_title,
      ),
    ];

    final topCenteredNav = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopNavButton(
          label: l.common_app_name,
          icon: Icons.home_rounded,
          isSelected: currentIndex == 0,
          onTap: () => _onItemTapped(context, 0),
        ),
        const SizedBox(width: 6),
        _TopNavButton(
          label: l.home_action_calendar,
          icon: Icons.calendar_month_rounded,
          isSelected: currentIndex == 1,
          onTap: () => _onItemTapped(context, 1),
        ),
        const SizedBox(width: 6),
        _TopNavButton(
          label: l.expenses_title,
          icon: Icons.receipt_long_rounded,
          isSelected: currentIndex == 2,
          onTap: () => _onItemTapped(context, 2),
        ),
        const SizedBox(width: 6),
        _TopNavButton(
          label: l.settings_title,
          icon: Icons.settings_outlined,
          isSelected: currentIndex == 3,
          onTap: () => _onItemTapped(context, 3),
        ),
      ],
    );

    PreferredSizeWidget? desktopBottomHeader;
    if (isDesktopOrWide) {
      final headerWidget = titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )
              : null);

      if (bottom != null) {
        desktopBottomHeader = bottom;
      } else if (headerWidget != null) {
        desktopBottomHeader = PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Center(child: headerWidget),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: isDesktopOrWide
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.access_time_filled_rounded),
                    ),
                  ),
                ),
              )
            : null,
        title: isDesktopOrWide
            ? topCenteredNav
            : (titleWidget ??
                (title != null ? Text(title!) : Text(l.common_app_name))),
        bottom: isDesktopOrWide ? desktopBottomHeader : bottom,
        actions: actions,
      ),
      // Side menu drawer for mobile or when desktop screen is shrunk below 768px
      drawer: isDesktopOrWide
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.access_time_filled_rounded,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.common_app_name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home_rounded),
                    title: Text(l.common_app_name),
                    selected: currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(context, 0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: Text(l.home_action_calendar),
                    selected: currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(context, 1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded),
                    title: Text(l.expenses_title),
                    selected: currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(context, 2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l.export_title),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ExportBottomSheet(),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l.settings_title),
                    selected: currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(context, 3);
                    },
                  ),
                ],
              ),
            ),
      body: isDesktopOrWide
          ? Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: body,
              ),
            )
          : body,
      // Bottom navigation bar for mobile (< 768px)
      bottomNavigationBar: isDesktopOrWide
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              items: navItems,
            ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class _TopNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppTheme.primary;

    return Material(
      color: isSelected ? primary.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primary : theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
