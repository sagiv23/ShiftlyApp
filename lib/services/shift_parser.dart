import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:uuid/uuid.dart';

class ParsedShiftResult {
  final Shift? shift;
  final String? trailingText;

  ParsedShiftResult({this.shift, this.trailingText});
}

class ShiftParser {
  static final Uuid _uuid = const Uuid();

  /// Parses strings like:
  /// "24.6.2026 - 17:00 - 23:00 none + 50"
  /// "24.6 - 17:00 - 23:00 45 minutes + 50"
  /// "24.6 - 17:00 - 23:00 45 דקות + 50"
  /// "3.9 - 15:00 - 18:10 20 דקות סדרן"
  /// "19.8 - 19:00 - 01:00 20 דקןת"
  static Shift? parse(
    String input,
    String jobTypeId, {
    double paidMinutes = 20.0,
    double unpaidMinutes = 45.0,
  }) {
    return parseResult(
      input,
      jobTypeId,
      paidMinutes: paidMinutes,
      unpaidMinutes: unpaidMinutes,
    ).shift;
  }

  static ParsedShiftResult parseResult(
    String input,
    String defaultJobTypeId, {
    double paidMinutes = 20.0,
    double unpaidMinutes = 45.0,
    List<JobType>? availableJobTypes,
  }) {
    try {
      input = input.trim();
      if (input.isEmpty) return ParsedShiftResult(shift: null);

      final baseRegex = RegExp(
        r'^(\d{1,2}\.\d{1,2}(?:\.\d{2,4})?)\s*-\s*(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})\s*(.*)$',
        caseSensitive: false,
      );

      final match = baseRegex.firstMatch(input);
      if (match == null) return ParsedShiftResult(shift: null);

      final dateStr = match.group(1)!;
      final startTimeStr = match.group(2)!;
      final endTimeStr = match.group(3)!;
      var remainder = match.group(4)?.trim() ?? '';

      // Extract tips if present
      double tips = 0.0;
      final tipsRegex = RegExp(r'\+\s*(\d+(?:\.\d+)?)');
      final tipsMatch = tipsRegex.firstMatch(remainder);
      if (tipsMatch != null) {
        tips = double.tryParse(tipsMatch.group(1)!) ?? 0.0;
        remainder = remainder.replaceFirst(tipsMatch.group(0)!, '').trim();
      }

      // Determine BreakType and break minutes from remainder
      BreakType breakType = BreakType.none;
      double currentUnpaidMins = unpaidMinutes;

      if (remainder.contains('ללא') ||
          remainder.toLowerCase().contains('none')) {
        breakType = BreakType.none;
        remainder = remainder
            .replaceAll(RegExp(r'ללא|none', caseSensitive: false), '')
            .trim();
      } else {
        final numRegex = RegExp(
          r'(\d+)\s*(?:דקות|דקןת|דק|min|minutes)',
          caseSensitive: false,
        );
        final numMatch = numRegex.firstMatch(remainder);
        if (numMatch != null) {
          final val = double.parse(numMatch.group(1)!);
          if (val == paidMinutes) {
            breakType = BreakType.paid;
          } else {
            breakType = BreakType.unpaid;
            currentUnpaidMins = val;
          }
          remainder = remainder.replaceFirst(numMatch.group(0)!, '').trim();
        } else if (remainder.contains(
              '${paidMinutes.toStringAsFixed(0)} דקות',
            ) ||
            remainder.contains('${paidMinutes.toStringAsFixed(0)} דקןת') ||
            remainder.contains('${paidMinutes.toStringAsFixed(0)} דק')) {
          breakType = BreakType.paid;
          remainder = remainder
              .replaceAll(
                RegExp(r'(\d+)\s*(?:דקות|דקןת|דק)', caseSensitive: false),
                '',
              )
              .trim();
        } else if (remainder.contains(
              '${unpaidMinutes.toStringAsFixed(0)} דקות',
            ) ||
            remainder.contains('${unpaidMinutes.toStringAsFixed(0)} דקןת') ||
            remainder.contains('${unpaidMinutes.toStringAsFixed(0)} דק')) {
          breakType = BreakType.unpaid;
          remainder = remainder
              .replaceAll(
                RegExp(r'(\d+)\s*(?:דקות|דקןת|דק)', caseSensitive: false),
                '',
              )
              .trim();
        }
      }

      String? trailingText = remainder.isNotEmpty ? remainder : null;

      String jobTypeId = defaultJobTypeId;
      if (trailingText != null &&
          availableJobTypes != null &&
          availableJobTypes.isNotEmpty) {
        final matched = availableJobTypes.firstWhere(
          (j) =>
              j.name.trim().toLowerCase() == trailingText!.trim().toLowerCase(),
          orElse: () => JobType(id: defaultJobTypeId, name: ''),
        );
        if (matched.name.isNotEmpty) {
          jobTypeId = matched.id;
          trailingText = null;
        }
      }

      final now = DateTime.now();
      final dateParts = dateStr.split('.');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      int year = now.year;
      if (dateParts.length == 3) {
        year = int.parse(dateParts[2]);
        if (year < 100) year += 2000;
      }

      final date = DateTime(year, month, day);

      final startTimeParts = startTimeStr.split(':');
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      final endTimeParts = endTimeStr.split(':');
      var end = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }

      final shift = Shift(
        id: _uuid.v4(),
        date: date,
        startTime: start,
        endTime: end,
        jobTypeId: jobTypeId,
        tips: tips,
        breakType: breakType,
        unpaidBreakMinutes: currentUnpaidMins,
        description: trailingText,
      );

      return ParsedShiftResult(shift: shift, trailingText: trailingText);
    } catch (e) {
      return ParsedShiftResult(shift: null);
    }
  }
}
