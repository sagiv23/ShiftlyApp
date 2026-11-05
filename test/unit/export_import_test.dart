import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/utils/import_utils.dart';

void main() {
  group('Export and Import Utils Unit Tests', () {
    final jobs = [
      JobType(id: 'j1', name: 'Barista'),
      JobType(id: 'j2', name: 'Shift Manager'),
    ];

    test('ImportUtils parses line-by-line text correctly', () {
      final rawText = '''
24.6.2026 - 09:00 - 17:00 none + 50
25.6.2026 - 17:00 - 01:00 45 דקות + 30 Barista
''';

      final result = ImportUtils.parseFromText(rawText, jobs, 'j1');
      expect(result.shifts.length, 2);
      expect(result.shifts[0].tips, 50.0);
      expect(result.shifts[0].jobTypeId, 'j1');
      expect(result.shifts[1].tips, 30.0);
      expect(result.shifts[1].jobTypeId, 'j1'); // Matched Barista
    });

    test('ImportUtils parses JSON array of shifts correctly', () {
      final shift1 = Shift(
        id: 's1',
        date: DateTime(2026, 7, 10),
        startTime: DateTime(2026, 7, 10, 9, 0),
        endTime: DateTime(2026, 7, 10, 17, 0),
        jobTypeId: 'j1',
        tips: 100.0,
        hourlyRate: 40.0,
      );

      final jsonRaw = jsonEncode([shift1.toJson()]);

      final result = ImportUtils.parseFromText(jsonRaw, jobs, 'j1');
      expect(result.shifts.length, 1);
      expect(result.shifts.first.id, 's1');
      expect(result.shifts.first.tips, 100.0);
      expect(result.shifts.first.hourlyRate, 40.0);
    });

    test('ImportUtils parses CSV text content correctly', () {
      final csvText = '''
Date,Job,Start Time,End Time,Net Hours,Hourly Rate,Tips,Incomes,Expenses,Total Pay
24.06.2026,"Barista",09:00,17:00,8.00,45.0,20.0,0.0,0.0,380.0
''';

      final result = ImportUtils.parseFromText(csvText, jobs, 'j1');
      expect(result.shifts.length, 1);
      expect(result.shifts.first.jobTypeId, 'j1');
      expect(result.shifts.first.tips, 20.0);
      expect(result.shifts.first.hourlyRate, 45.0);
    });
  });
}
