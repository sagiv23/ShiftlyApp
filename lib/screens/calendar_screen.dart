import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/secret_screen.dart';
import 'package:shiftly/services/shabbat_holiday_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/app_page_route.dart';
import 'package:shiftly/utils/page_entrance_animation.dart';
import 'package:shiftly/widgets/adaptive_scaffold.dart';
import 'package:shiftly/widgets/empty_state_widget.dart';
import 'package:shiftly/widgets/magen_david_icon.dart';
import 'package:shiftly/widgets/shift_tile.dart';
import 'package:shiftly/widgets/skeleton_loaders.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String? _activeBannerMessage;
  AnimationController? _bannerController;
  Animation<double>? _bannerAnimation;
  List<SpecialPeriodBoundary> _monthBoundaries = [];

  Timer? _easterEggProgressTimer;
  OverlayEntry? _easterEggOverlay;
  double _easterEggProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _bannerAnimation = CurvedAnimation(
      parent: _bannerController!,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthBoundaries(_focusedDay);
    });
  }

  Future<void> _loadMonthBoundaries(DateTime focusedDay) async {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final start = DateTime(focusedDay.year, focusedDay.month, 1);
    final end = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final boundaries = await ShabbatHolidayService.fetchBoundariesFromApi(
      start,
      end,
      settings.shabbatHolidayRules,
    );
    if (mounted) {
      setState(() {
        _monthBoundaries = boundaries;
      });
    }
  }

  @override
  void dispose() {
    _cancelEasterEggHold();
    _bannerController?.dispose();
    super.dispose();
  }

  void _startEasterEggHold(BuildContext context) {
    _cancelEasterEggHold();

    _easterEggProgress = 0.0;
    const totalDurationMs = 5000;
    const tickMs = 50;
    int elapsedMs = 0;

    _showEasterEggOverlay(context);

    _easterEggProgressTimer = Timer.periodic(
      const Duration(milliseconds: tickMs),
          (timer) {
        elapsedMs += tickMs;
        if (mounted) {
          setState(() {
            _easterEggProgress = elapsedMs / totalDurationMs;
            _easterEggOverlay?.markNeedsBuild();
          });
        }
        if (elapsedMs >= totalDurationMs) {
          timer.cancel();
          _completeEasterEggHold(context);
        }
      },
    );
  }

  void _cancelEasterEggHold() {
    _easterEggProgressTimer?.cancel();
    _easterEggProgressTimer = null;
    _easterEggProgress = 0.0;
    _removeEasterEggOverlay();
  }

  void _removeEasterEggOverlay() {
    _easterEggOverlay?.remove();
    _easterEggOverlay = null;
  }

  void _showEasterEggOverlay(BuildContext context) {
    _removeEasterEggOverlay();
    _easterEggOverlay = OverlayEntry(
      builder: (context) {
        final secondsLeft = ((1.0 - _easterEggProgress) * 5.0).ceil();
        final isDark = Theme
            .of(context)
            .brightness == Brightness.dark;

        return Positioned(
          top: MediaQuery
              .of(context)
              .padding
              .top + 60,
          left: 32,
          right: 32,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkCard : Colors.white)
                    .withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.electricCyan, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricCyan.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'מחזיק לפתיחת סוד... ${secondsLeft > 0 ? secondsLeft : 1}s',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _easterEggProgress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                      AppTheme.electricCyan.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.electricCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_easterEggOverlay!);
  }

  void _completeEasterEggHold(BuildContext context) {
    _cancelEasterEggHold();
    if (!mounted) return;
    Navigator.of(context).push(
      AppPageRoute.fadeScale(const SecretScreen()),
    );
  }

  Widget _buildNovember23Cell(BuildContext context, DateTime day,
      DateTime focusedDay) {
    final isSelected = isSameDay(_selectedDay, day);
    final isToday = isSameDay(DateTime.now(), day);
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final isWeekend = day.weekday == DateTime.saturday;

    Color textStyleColor;
    BoxDecoration? decoration;

    if (isSelected) {
      decoration = const BoxDecoration(
        color: AppTheme.electricCyan,
        shape: BoxShape.circle,
      );
      textStyleColor = const Color(0xFF040711);
    } else if (isToday) {
      decoration = BoxDecoration(
        color: AppTheme.neonViolet.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.neonViolet),
      );
      textStyleColor = Colors.white;
    } else if (isWeekend) {
      textStyleColor = AppTheme.warmAmber;
    } else {
      textStyleColor =
      isDark ? AppTheme.secondaryText : const Color(0xFF475569);
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _startEasterEggHold(context),
      onPointerUp: (_) => _cancelEasterEggHold(),
      onPointerCancel: (_) => _cancelEasterEggHold(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(6.0),
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textStyleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showHolidayBanner(
    BuildContext context,
    String message,
    bool isHoliday,
  ) {
    setState(() {
      _activeBannerMessage = message;
    });
    _bannerController?.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (mounted) {
        await _bannerController?.reverse();
        if (mounted) {
          setState(() {
            _activeBannerMessage = null;
          });
        }
      }
    });
  }

  List<Shift> _getShiftsForDay(DateTime day, List<Shift> allShifts) {
    return allShifts.where((shift) {
      return isSameDay(shift.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final allShifts = shiftProvider.shifts;
    final l = AppLocalizations.of(context)!;
    final selectedShifts = _getShiftsForDay(
      _selectedDay ?? _focusedDay,
      allShifts,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      currentIndex: 0,
      title: l.home_action_calendar,
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            shiftProvider.isLoading && shiftProvider.shifts.isEmpty
                ? const CalendarScreenSkeleton()
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: PageEntranceAnimation(
                          delayFraction: 0.0,
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCard
                                    : Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLg,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.lightBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.04,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TableCalendar<Shift>(
                                    locale: l.localeName,
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: _focusedDay,
                                    calendarFormat: _calendarFormat,
                                    startingDayOfWeek: StartingDayOfWeek.sunday,
                                    weekendDays: const [DateTime.saturday],
                                    rowHeight: 52,
                                    daysOfWeekHeight: 40,
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.electricCyan,
                                      ),
                                      leftChevronIcon: const Icon(
                                        Icons.chevron_left,
                                        color: AppTheme.electricCyan,
                                      ),
                                      rightChevronIcon: const Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.electricCyan,
                                      ),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppTheme.secondaryText
                                            : const Color(0xFF475569),
                                        fontSize: 13,
                                      ),
                                      weekendStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.warmAmber,
                                        fontSize: 13,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warmAmber.withValues(
                                          alpha: isDark ? 0.08 : 0.05,
                                        ),
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      outsideDaysVisible: false,
                                      weekendTextStyle: const TextStyle(
                                        color: AppTheme.warmAmber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      selectedDecoration: const BoxDecoration(
                                        color: AppTheme.electricCyan,
                                        shape: BoxShape.circle,
                                      ),
                                      selectedTextStyle: const TextStyle(
                                        color: Color(0xFF040711),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: AppTheme.neonViolet.withValues(
                                          alpha: 0.35,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.neonViolet,
                                        ),
                                      ),
                                      todayTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      markerDecoration: const BoxDecoration(
                                        color: AppTheme.mintGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    calendarBuilders: CalendarBuilders(
                                      prioritizedBuilder:
                                          (context, day, focusedDay) {
                                        if (day.month == 11 && day.day == 23) {
                                          return _buildNovember23Cell(
                                            context,
                                            day,
                                            focusedDay,
                                          );
                                        }
                                        return null;
                                      },
                                      markerBuilder: (context, day, events) {
                                        final hasShift =
                                            events.isNotEmpty ||
                                                _getShiftsForDay(
                                                  day,
                                                  allShifts,
                                                ).isNotEmpty;

                                        if (!settings
                                            .shabbatHolidayRules
                                            .enabled) {
                                          if (hasShift) {
                                            return Positioned(
                                              bottom: 4,
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.mintGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            );
                                          }
                                          return null;
                                        }

                                        final dayStart = DateTime(
                                          day.year,
                                          day.month,
                                          day.day,
                                        );
                                        final dayEnd = dayStart.add(
                                          const Duration(days: 1),
                                        );

                                        final localBoundaries =
                                        ShabbatHolidayService
                                            .getBoundariesForRange(
                                          dayStart,
                                          dayEnd,
                                          settings.shabbatHolidayRules,
                                        );

                                        final allBoundaries = [
                                          ..._monthBoundaries,
                                          ...localBoundaries,
                                        ];
                                        final matchingBoundary = allBoundaries
                                            .firstWhereOrNull(
                                              (b) =>
                                          dayStart.isBefore(b.end) &&
                                              dayEnd.isAfter(b.start),
                                        );

                                        if (matchingBoundary != null) {
                                          final holidayName =
                                              matchingBoundary.name;
                                          final isHoliday =
                                              matchingBoundary.type ==
                                                  'holiday';

                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                top: 3,
                                                child: GestureDetector(
                                                  behavior:
                                                  HitTestBehavior.opaque,
                                                  onTap: () =>
                                                      _showHolidayBanner(
                                                        context,
                                                        holidayName,
                                                        isHoliday,
                                                      ),
                                                  child: const MagenDavidIcon(
                                                    size: 15,
                                                    color: AppTheme.warmAmber,
                                                  ),
                                                ),
                                              ),
                                              if (hasShift)
                                                Positioned(
                                                  bottom: 4,
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration:
                                                    const BoxDecoration(
                                                      color: AppTheme
                                                          .mintGreen,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }

                                        if (hasShift) {
                                          return Positioned(
                                            bottom: 4,
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.mintGreen,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          );
                                        }

                                        return null;
                                      },
                                    ),
                                    availableGestures: AvailableGestures.all,
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_selectedDay, day);
                                    },
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (!isSameDay(
                                        _selectedDay,
                                        selectedDay,
                                      )) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      }
                                    },
                                    onFormatChanged: (format) {
                                      if (_calendarFormat != format) {
                                        setState(() {
                                          _calendarFormat = format;
                                        });
                                      }
                                    },
                                    onPageChanged: (focusedDay) {
                                      setState(() {
                                        _focusedDay = focusedDay;
                                      });
                                      _loadMonthBoundaries(focusedDay);
                                    },
                                    eventLoader: (day) =>
                                        _getShiftsForDay(day, allShifts),
                                  ),
                                  _buildLegend(context, isDark, l, settings),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.list_alt_rounded,
                                size: 20,
                                color: AppTheme.electricCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDay == null
                                    ? l.home_shift_list_select_day
                                    : '${l.home_shift_list_shifts_on}${AppConstants.formatDateShort(_selectedDay)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppTheme.secondaryText
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedShifts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            icon: Icons.event_busy_rounded,
                            title: l.home_shift_list_no_shifts,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 120),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return ShiftTile(
                                shift: selectedShifts[index],
                                useCardDecoration: true,
                              );
                            }, childCount: selectedShifts.length),
                          ),
                        ),
                    ],
                  ),
            if (_activeBannerMessage != null)
              Positioned(
                top: 24,
                left: 32,
                right: 32,
                child: FadeTransition(
                  opacity: _bannerAnimation!,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    color: AppTheme.darkCard,
                    shadowColor: AppTheme.electricCyan.withValues(alpha: 0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.electricCyan),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MagenDavidIcon(
                            color: AppTheme.warmAmber,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _activeBannerMessage!,
                              style: const TextStyle(
                                color: AppTheme.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context,
      bool isDark,
      AppLocalizations l,
      SettingsProvider settings,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(
              icon: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonViolet, width: 2),
                  color: AppTheme.neonViolet.withValues(alpha: 0.3),
                ),
              ),
              label: l.calendar_legend_today,
              isDark: isDark,
            ),
            _buildLegendItem(
              icon: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.electricCyan,
                ),
              ),
              label: l.calendar_legend_selected,
              isDark: isDark,
            ),
            _buildLegendItem(
              icon: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.mintGreen,
                ),
              ),
              label: l.calendar_legend_shift,
              isDark: isDark,
            ),
            if (settings.shabbatHolidayRules.enabled) ...[
              _buildLegendItem(
                icon: const MagenDavidIcon(
                  size: 14,
                  color: AppTheme.warmAmber,
                ),
                label: l.calendar_legend_holiday,
                isDark: isDark,
              ),
              _buildLegendItem(
                icon: SizedBox(
                  width: 16,
                  height: 24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MagenDavidIcon(
                        size: 13,
                        color: AppTheme.warmAmber,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.mintGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                label: l.calendar_legend_holiday_shift,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Widget icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.secondaryText : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
