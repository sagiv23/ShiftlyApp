class ShiftSalaryBreakdown {
  final double grossDurationHours;
  final double unpaidBreakHours;
  final double netPaidHours;
  final double hourlyRate;

  final double regularHours;
  final double regularEarnings;

  final double shabbatHours;
  final double shabbatMultiplier;
  final double shabbatEarnings;

  final double holidayHours;
  final double holidayMultiplier;
  final double holidayEarnings;
  final String? holidayName;

  final double tier1Hours;
  final double tier1Multiplier;
  final double tier1Earnings;

  final double tier2Hours;
  final double tier2Multiplier;
  final double tier2Earnings;

  // Granular breakdown fields
  final double weekdayRegularHours;
  final double weekdayTier1Hours;
  final double weekdayTier2Hours;

  final double shabbatRegularHours;
  final double shabbatTier1Hours;
  final double shabbatTier2Hours;

  final double holidayRegularHours;
  final double holidayTier1Hours;
  final double holidayTier2Hours;

  final double totalBaseSalary;
  final double tips;
  final double automaticIncomes;
  final double automaticExpenses;
  final double totalShiftPay;

  const ShiftSalaryBreakdown({
    required this.grossDurationHours,
    required this.unpaidBreakHours,
    required this.netPaidHours,
    required this.hourlyRate,
    required this.regularHours,
    required this.regularEarnings,
    this.shabbatHours = 0.0,
    this.shabbatMultiplier = 1.0,
    this.shabbatEarnings = 0.0,
    this.holidayHours = 0.0,
    this.holidayMultiplier = 1.0,
    this.holidayEarnings = 0.0,
    this.holidayName,
    required this.tier1Hours,
    required this.tier1Multiplier,
    required this.tier1Earnings,
    required this.tier2Hours,
    required this.tier2Multiplier,
    required this.tier2Earnings,
    this.weekdayRegularHours = 0.0,
    this.weekdayTier1Hours = 0.0,
    this.weekdayTier2Hours = 0.0,
    this.shabbatRegularHours = 0.0,
    this.shabbatTier1Hours = 0.0,
    this.shabbatTier2Hours = 0.0,
    this.holidayRegularHours = 0.0,
    this.holidayTier1Hours = 0.0,
    this.holidayTier2Hours = 0.0,
    required this.totalBaseSalary,
    this.tips = 0.0,
    this.automaticIncomes = 0.0,
    this.automaticExpenses = 0.0,
    required this.totalShiftPay,
  });

  bool get hasOvertime => (tier1Hours > 0.0001 || tier2Hours > 0.0001);

  bool get hasShabbat => shabbatHours > 0.0001;

  bool get hasHoliday => holidayHours > 0.0001;

  double get totalOvertimeHours => tier1Hours + tier2Hours;

  double get totalOvertimeEarnings => tier1Earnings + tier2Earnings;

  double get shabbatOvertimeHours => shabbatTier1Hours + shabbatTier2Hours;

  double get holidayOvertimeHours => holidayTier1Hours + holidayTier2Hours;

  double get weekdayOvertimeHours => weekdayTier1Hours + weekdayTier2Hours;
}
