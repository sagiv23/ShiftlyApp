class ShiftSalaryBreakdown {
  final double grossDurationHours;
  final double unpaidBreakHours;
  final double netPaidHours;
  final double hourlyRate;

  final double regularHours;
  final double regularEarnings;

  final double tier1Hours;
  final double tier1Multiplier;
  final double tier1Earnings;

  final double tier2Hours;
  final double tier2Multiplier;
  final double tier2Earnings;

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
    required this.tier1Hours,
    required this.tier1Multiplier,
    required this.tier1Earnings,
    required this.tier2Hours,
    required this.tier2Multiplier,
    required this.tier2Earnings,
    required this.totalBaseSalary,
    this.tips = 0.0,
    this.automaticIncomes = 0.0,
    this.automaticExpenses = 0.0,
    required this.totalShiftPay,
  });

  bool get hasOvertime => (tier1Hours > 0.0001 || tier2Hours > 0.0001);

  double get totalOvertimeHours => tier1Hours + tier2Hours;

  double get totalOvertimeEarnings => tier1Earnings + tier2Earnings;
}
