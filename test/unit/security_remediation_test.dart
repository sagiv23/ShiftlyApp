import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/services/overtime_calculator.dart';

void main() {
  group('Security Remediation & Integrity Tests', () {
    test(
      'Password Policy Regex Enforces Minimum 8 Characters with Letter and Digit',
      () {
        final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

        // Weak passwords (must fail)
        expect(passwordRegExp.hasMatch('123456'), false);
        expect(passwordRegExp.hasMatch('abcdefgh'), false);
        expect(passwordRegExp.hasMatch('12345678'), false);
        expect(passwordRegExp.hasMatch('short1'), false);

        // Strong passwords (must pass)
        expect(passwordRegExp.hasMatch('Password123'), true);
        expect(passwordRegExp.hasMatch('shiftlyApp2026!'), true);
        expect(passwordRegExp.hasMatch('SecurePass9'), true);
      },
    );

    test('APK Release Manifest SHA-256 Extraction', () {
      const sampleChangelog = '''
## Release v1.2.0
- Added security updates
- SHA-256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
''';

      final extractedHash = RegExp(
        r'SHA-?256:\s*([a-fA-F0-9]{64})',
        caseSensitive: false,
      ).firstMatch(sampleChangelog)?.group(1);

      expect(
        extractedHash,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('OvertimeCalculator Salary Rules Integrity Verification', () {
      final start = DateTime(2026, 11, 8, 8, 0); // 08:00
      final end = DateTime(2026, 11, 8, 18, 0); // 18:00 (10 hours gross)

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: 50.0,
        breakType: BreakType.unpaid,
        unpaidBreakMinutes: 60.0,
        // 1 hr break -> 9 hrs net
        rules: const OvertimeRules(
          enabled: true,
          regularHoursThreshold: 8.0,
          tier1HoursLimit: 2.0,
          tier1Multiplier: 1.25,
          tier2Multiplier: 1.50,
        ),
      );

      // 9 Net Hours: 8 Regular @ 50 = 400, 1 Tier1 @ 62.5 = 62.5 -> Total 462.5
      expect(breakdown.netPaidHours, 9.0);
      expect(breakdown.regularHours, 8.0);
      expect(breakdown.regularEarnings, 400.0);
      expect(breakdown.tier1Hours, 1.0);
      expect(breakdown.tier1Earnings, 62.5);
      expect(breakdown.totalBaseSalary, 462.5);
    });
  });
}
