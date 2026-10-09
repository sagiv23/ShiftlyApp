import 'package:flutter/material.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/screens/analytics_screen.dart';
import 'package:shiftly/screens/calendar_screen.dart';
import 'package:shiftly/screens/expenses_income_screen.dart';
import 'package:shiftly/screens/home_screen.dart';
import 'package:shiftly/screens/settings_screen.dart';
import 'package:shiftly/screens/shift_descriptions_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';

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
    Navigator.push(context, AppPageRoute.slideUp(const AddShiftScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWide = screenWidth >= 768;
    final activeIndex = _currentIndex > 4 ? 2 : _currentIndex;

    final currentTabWidget = PageEntranceAnimation(
      key: ValueKey(_currentIndex),
      child: IndexedStack(index: _currentIndex, children: _screens),
    );

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
              child: SideMenuContent(
                currentIndex: activeIndex,
                onSelectTab: (index) => _onItemTapped(index),
                onAddShift: () => _openAddShiftScreen(context),
              ),
            ),
            Expanded(
              child: MainScreenScope(
                currentIndex: activeIndex,
                onTabSelected: _onItemTapped,
                onAddShift: () => _openAddShiftScreen(context),
                child: currentTabWidget,
              ),
            ),
          ],
        ),
      );
    }

    return MainScreenScope(
      currentIndex: activeIndex,
      onTabSelected: _onItemTapped,
      onAddShift: () => _openAddShiftScreen(context),
      child: currentTabWidget,
    );
  }
}
