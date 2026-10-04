import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/screens/analytics_screen.dart';
import 'package:shiftly/screens/calendar_screen.dart';
import 'package:shiftly/screens/expenses_screen.dart';
import 'package:shiftly/screens/home_screen.dart';
import 'package:shiftly/screens/profile_screen.dart';
import 'package:shiftly/screens/settings_screen.dart';
import 'package:shiftly/screens/shift_descriptions_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 2});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CalendarScreen(),
    AnalyticsScreen(),
    HomeScreen(),
    ExpensesScreen(),
    ShiftDescriptionsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  static void _openAddShiftScreen(BuildContext context) {
    Navigator.push(
      context,
      AppPageRoute.slideUp(const AddShiftScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWide = screenWidth >= 768;
    final activeIndex = _currentIndex > 4 ? 2 : _currentIndex;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_month_rounded, size: 22),
        label: isHebrew ? 'לוח' : 'Calendar',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bar_chart_rounded, size: 22),
        label: isHebrew ? 'אנליטיקה' : 'Analytics',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_rounded, size: 26),
        label: isHebrew ? 'בית' : 'Home',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt_long_rounded, size: 22),
        label: isHebrew ? 'הוצאות' : 'Expenses',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.note_alt_rounded, size: 22),
        label: isHebrew ? 'סיכומים' : 'Summaries',
      ),
    ];

    if (isDesktopOrWide) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                currentIndex: activeIndex,
                onSelectTab: (index) => _onItemTapped(index),
                onAddShift: () => _openAddShiftScreen(context),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardTheme.color,
        child: SafeArea(
          child: _SideMenuContent(
            currentIndex: activeIndex,
            onSelectTab: (index) {
              Navigator.pop(context);
              _onItemTapped(index);
            },
            onAddShift: () {
              Navigator.pop(context);
              _openAddShiftScreen(context);
            },
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (index) => _onItemTapped(index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: navItems,
      ),
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
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // App Logo & Brand Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.access_time_filled_rounded,
                        size: 34,
                      ),
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),
            // New Shift Action Item
            _SideNavItem(
              icon: Icons.add_rounded,
              label: l.home_action_new_shift,
              isSelected: false,
              onTap: onAddShift,
            ),
            const SizedBox(height: 2),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 2),
            // Nav items
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
            if (auth.isLoggedIn) ...[
              _SideNavItem(
                icon: Icons.person_rounded,
                label: l.side_menu_profile,
                isSelected: false,
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.push(
                    context,
                    AppPageRoute.slideHorizontal(const ProfileScreen()),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),
            // Settings separated at the bottom
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
