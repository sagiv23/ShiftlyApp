import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/models/shift_filter.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense toJson and fromJson conversion', () {
      final date = DateTime(2026, 9, 29, 12, 0);
      final expense = Expense(
        id: 'exp1',
        date: date,
        description: 'Parking',
        amount: 30.0,
        isIncome: false,
      );

      final json = expense.toJson();
      expect(json['id'], 'exp1');
      expect(json['description'], 'Parking');
      expect(json['amount'], 30.0);
      expect(json['isIncome'], false);

      final decoded = Expense.fromJson(json);
      expect(decoded.id, expense.id);
      expect(decoded.date, expense.date);
      expect(decoded.description, expense.description);
      expect(decoded.amount, expense.amount);
      expect(decoded.isIncome, expense.isIncome);
    });
  });

  group('ShiftFilter Tests', () {
    test('ShiftFilter isActive returns false when all fields are null', () {
      final filter = ShiftFilter();
      expect(filter.isActive, false);
    });

    test('ShiftFilter isActive returns true when any field is set', () {
      final filter = ShiftFilter(minWage: 40.0);
      expect(filter.isActive, true);
    });

    test('ShiftFilter copyWith works correctly', () {
      final filter = ShiftFilter(minWage: 30.0);
      final updated = filter.copyWith(maxWage: 50.0);

      expect(updated.minWage, 30.0);
      expect(updated.maxWage, 50.0);

      final cleared = updated.copyWith(clearMinWage: true);
      expect(cleared.minWage, null);
      expect(cleared.maxWage, 50.0);
    });
  });
}
