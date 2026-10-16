import 'package:shiftly/utils/number_utils.dart';

class OvertimeRules {
  final bool enabled;
  final double regularHoursThreshold;
  final double tier1HoursLimit;
  final double tier1Multiplier;
  final double tier2Multiplier;

  const OvertimeRules({
    this.enabled = true,
    this.regularHoursThreshold = 8.0,
    this.tier1HoursLimit = 2.0,
    this.tier1Multiplier = 1.25,
    this.tier2Multiplier = 1.50,
  });

  /// Validates the rules configuration. Returns an error key/message if invalid, or null if valid.
  String? validate() {
    if (regularHoursThreshold < 0) {
      return 'Regular hours threshold cannot be negative';
    }
    if (tier1HoursLimit < 0) {
      return 'First overtime tier duration cannot be negative';
    }
    if (tier1Multiplier < 1.0) {
      return 'Tier 1 multiplier must be at least 1.0 (100%)';
    }
    if (tier2Multiplier < 1.0) {
      return 'Tier 2 multiplier must be at least 1.0 (100%)';
    }
    return null;
  }

  bool get isValid => validate() == null;

  OvertimeRules copyWith({
    bool? enabled,
    double? regularHoursThreshold,
    double? tier1HoursLimit,
    double? tier1Multiplier,
    double? tier2Multiplier,
  }) {
    return OvertimeRules(
      enabled: enabled ?? this.enabled,
      regularHoursThreshold:
          regularHoursThreshold ?? this.regularHoursThreshold,
      tier1HoursLimit: tier1HoursLimit ?? this.tier1HoursLimit,
      tier1Multiplier: tier1Multiplier ?? this.tier1Multiplier,
      tier2Multiplier: tier2Multiplier ?? this.tier2Multiplier,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'regularHoursThreshold': regularHoursThreshold,
    'tier1HoursLimit': tier1HoursLimit,
    'tier1Multiplier': tier1Multiplier,
    'tier2Multiplier': tier2Multiplier,
  };

  factory OvertimeRules.fromJson(Map<String, dynamic> json) => OvertimeRules(
    enabled: NumberUtils.parseBool(json['enabled'], true),
    regularHoursThreshold: NumberUtils.parseDouble(
      json['regularHoursThreshold'] ?? json['regular_hours_threshold'],
      8.0,
    ),
    tier1HoursLimit: NumberUtils.parseDouble(
      json['tier1HoursLimit'] ?? json['tier1_hours_limit'],
      2.0,
    ),
    tier1Multiplier: NumberUtils.parseDouble(
      json['tier1Multiplier'] ?? json['tier1_multiplier'],
      1.25,
    ),
    tier2Multiplier: NumberUtils.parseDouble(
      json['tier2Multiplier'] ?? json['tier2_multiplier'],
      1.50,
    ),
  );
}
