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
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/cookie_consent_banner.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';
import 'package:shiftly/services/update_service.dart';
import 'package:shiftly/widgets/update_dialog.dart';

class LazyTabPageWrapper extends StatefulWidget {
  final Widget child;
  final Widget skeleton;

  const LazyTabPageWrapper({
    super.key,
    required this.child,
    required this.skeleton,
  });

  @override
  State<LazyTabPageWrapper> createState() => _LazyTabPageWrapperState();
}

class _LazyTabPageWrapperState extends State<LazyTabPageWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.skeleton;
    }
    return widget.child;
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 2});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final Map<int, Widget> _cachedScreens = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Pre-cache only the initial screen for lightning-fast splash transition
    _cachedScreens[_currentIndex] = _getScreenForIndex(_currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdatesOnStartup();
    });
  }

  Future<void> _checkForUpdatesOnStartup() async {
    final updateInfo = await UpdateService.checkForUpdates();
    if (mounted && updateInfo != null && updateInfo.isNewer) {
      UpdateDialog.show(context, updateInfo, isForceUpdate: true);
    }
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const LazyTabPageWrapper(
          skeleton: CalendarScreenSkeleton(),
          child: CalendarScreen(),
        );
      case 1:
        return const LazyTabPageWrapper(
          skeleton: AnalyticsScreenSkeleton(),
          child: AnalyticsScreen(),
        );
      case 2:
        return const LazyTabPageWrapper(
          skeleton: HomeScreenSkeleton(),
          child: HomeScreen(),
        );
      case 3:
        return const LazyTabPageWrapper(
          skeleton: ExpensesScreenSkeleton(),
          child: ExpensesScreen(),
        );
      case 4:
        return const LazyTabPageWrapper(
          skeleton: HomeScreenSkeleton(),
          child: ShiftDescriptionsScreen(),
        );
      case 5:
        return const LazyTabPageWrapper(
          skeleton: ExpensesScreenSkeleton(),
          child: SettingsScreen(),
        );
      default:
        return const LazyTabPageWrapper(
          skeleton: HomeScreenSkeleton(),
          child: HomeScreen(),
        );
    }
  }

  Widget _buildScreen(int index) {
    if (!_cachedScreens.containsKey(index)) {
      return const SizedBox.shrink();
    }
    return _cachedScreens[index]!;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      if (!_cachedScreens.containsKey(index)) {
        _cachedScreens[index] = _getScreenForIndex(index);
      }
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

    final currentTabWidget = IndexedStack(
      index: _currentIndex,
      children: [
        _buildScreen(0),
        _buildScreen(1),
        _buildScreen(2),
        _buildScreen(3),
        _buildScreen(4),
        _buildScreen(5),
      ],
    );

    Widget content;
    if (isDesktopOrWide) {
      content = Scaffold(
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
    } else {
      content = MainScreenScope(
        currentIndex: activeIndex,
        onTabSelected: _onItemTapped,
        onAddShift: () => _openAddShiftScreen(context),
        child: currentTabWidget,
      );
    }

    return Stack(children: [content, const CookieConsentBanner()]);
  }
}
