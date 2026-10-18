import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/services/shabbat_holiday_service.dart';
import 'package:shiftly/theme/app_theme.dart';
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
    _bannerController?.dispose();
    super.dispose();
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
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLg,
                                ),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.darkBorder
                                      : AppTheme.lightBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TableCalendar<Shift>(
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                  weekendStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.05),
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  weekendTextStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  markerDecoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (!settings.shabbatHolidayRules.enabled) {
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
                                        ShabbatHolidayService.getBoundariesForRange(
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
                                      final holidayName = matchingBoundary.name;
                                      final isHoliday =
                                          matchingBoundary.type == 'holiday';
                                      final isDark =
                                          Theme
                                              .of(context)
                                              .brightness ==
                                              Brightness.dark;
                                      final textColor = isDark
                                          ? Colors.white
                                          : Theme
                                          .of(
                                        context,
                                      )
                                          .colorScheme
                                          .onSurface;

                                      return Positioned(
                                        bottom: 1,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _showHolidayBanner(
                                            context,
                                            holidayName,
                                            isHoliday,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: textColor.withValues(
                                                alpha: 0.12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: MagenDavidIcon(
                                              size: 13,
                                              color: textColor,
                                            ),
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
                                  if (!isSameDay(_selectedDay, selectedDay)) {
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
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDay == null
                                    ? l.home_shift_list_select_day
                                    : '${l.home_shift_list_shifts_on}${DateFormat('dd/MM').format(_selectedDay!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey,
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
                    elevation: 8,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    color: AppTheme.primaryDark,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MagenDavidIcon(
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _activeBannerMessage!,
                              style: const TextStyle(
                                color: Colors.white,
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
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
