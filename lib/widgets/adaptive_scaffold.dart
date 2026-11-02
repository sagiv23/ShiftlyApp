import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/screens/profile_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
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
    final isDesktopOrWide = screenWidth >= AppConstants.wideScreenWidth;
    final scope = MainScreenScope.of(context);
    final effectiveIndex = scope?.currentIndex ?? currentIndex;
    final activeIndex = effectiveIndex > 4 ? 2 : effectiveIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      _NavModel(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: l.nav_calendar,
      ),
      _NavModel(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        label: l.nav_analytics,
      ),
      _NavModel(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l.nav_home,
      ),
      _NavModel(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: l.nav_expenses,
      ),
      _NavModel(
        icon: Icons.note_alt_outlined,
        activeIcon: Icons.note_alt_rounded,
        label: l.nav_summaries,
      ),
    ];

    Widget mainScaffold;
    if (!isDesktopOrWide) {
      mainScaffold = Scaffold(
        appBar: _buildAppBar(context, l),
        drawer: Drawer(
          backgroundColor: isDark
              ? AppTheme.darkSecondaryBackground
              : Theme.of(context).cardTheme.color,
          shadowColor: AppTheme.electricCyan.withValues(alpha: 0.2),
          elevation: 16,
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
        body: ResponsivePageBody(child: body),
        // Mobile Bottom Tab Bar (Apple HIG tab-bars.md: floating glass bar)
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _FrostedSurface(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = activeIndex == index;
                    return Expanded(
                      child: Center(
                        child: _CupertinoTabItem(
                          icon: item.icon,
                          activeIcon: item.activeIcon,
                          label: item.label,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => scope?.onTabSelected(index),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    } else {
      mainScaffold = Scaffold(
        appBar: _buildAppBar(context, l),
        body: ResponsivePageBody(child: body),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    }

    if (scope != null) {
      return mainScaffold;
    }

    return Stack(children: [mainScaffold, const CookieConsentBanner()]);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l) {
    return AppBar(
      centerTitle: true,
      title: Semantics(
        header: true,
        child:
            titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )
                : Text(
                    l.common_app_name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )),
      ),
      bottom: bottom,
      actions: actions,
      flexibleSpace: const _AppBarMaterial(),
    );
  }
}

class _NavModel {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavModel({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _CupertinoTabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CupertinoTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.electricCyan;
    final inactiveColor = isDark
        ? AppTheme.secondaryText
        : const Color(0xFF64748B);

    return ScalePress(
      onTap: onTap,
      scale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.22 : 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 21,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared translucent iOS chrome (`tab-bars.md`, `sidebars.md`).
class _FrostedSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const _FrostedSurface({required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highContrast = MediaQuery.of(context).highContrast;
    final opacity = highContrast ? 0.98 : (isDark ? 0.82 : 0.88);
    final color =
        (isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightCard)
            .withValues(alpha: opacity);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: highContrast ? 0 : 20,
          sigmaY: highContrast ? 0 : 20,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AppBarMaterial extends StatelessWidget {
  const _AppBarMaterial();

  @override
  Widget build(BuildContext context) => const _FrostedSurface(
    borderRadius: BorderRadius.zero,
    child: SizedBox.expand(),
  );
}

class ResponsivePageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsivePageBody({
    super.key,
    required this.child,
    this.maxWidth = 1180,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) return child;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// Desktop/Web Sidebar Menu (`sidebars.md`).
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
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Branding Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.electricCyan.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.access_time_filled_rounded,
                          size: 44,
                          color: AppTheme.electricCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.common_app_name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? AppTheme.primaryText : null,
                              ),
                        ),
                        Text(
                          l.common_tagline,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.electricCyan,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (Navigator.of(context).canPop())
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.secondaryText,
                      ),
                      tooltip: l.common_cancel,
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Profile Account Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ScalePress(
                onTap: () {
                  final nav = Navigator.of(context);
                  if (nav.canPop()) nav.pop();
                  nav.push(AppPageRoute.sharedAxis(const ProfileScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : AppTheme.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.neonViolet,
                        child: Text(
                          auth.isLoggedIn
                              ? (auth.userName?.isNotEmpty == true
                                        ? auth.userName![0]
                                        : (auth.userEmail?.isNotEmpty == true
                                              ? auth.userEmail![0]
                                              : 'U'))
                                    .toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isLoggedIn
                                  ? (auth.userName ?? l.side_menu_profile)
                                  : l.auth_guest_mode_title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              auth.isLoggedIn
                                  ? (auth.userEmail ?? '')
                                  : l.side_menu_profile,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppTheme.secondaryText
                                    : Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppTheme.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Primary Action Button (New Shift)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  gradient: AppTheme.cyanGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onAddShift,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: Color(0xFF040711),
                  ),
                  label: Text(
                    l.home_action_new_shift,
                    style: const TextStyle(
                      color: Color(0xFF040711),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),

            // Sidebar Navigation Items (`sidebars.md`)
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

            // Settings Section
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.electricCyan;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected
            ? primary.withValues(alpha: isDark ? 0.18 : 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primary.withValues(alpha: 0.35)),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? primary
                      : (isDark
                            ? AppTheme.secondaryText
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.neonViolet,
                      shape: BoxShape.circle,
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
