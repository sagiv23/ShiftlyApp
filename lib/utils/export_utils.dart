import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/ui_utils.dart';

class ExportUtils {
  static Future<String?> exportShifts({
    required ShiftProvider shiftProvider,
    required List<Shift> shifts,
    required String format, // 'csv' or 'txt'
    required String currencySymbol,
  }) async {
    if (shifts.isEmpty) return null;

    String content = '';
    String extension = '';
    MimeType mimeType;
    if (format == 'csv') {
      extension = 'csv';
      content = _generateCsv(shiftProvider, shifts, currencySymbol);
      mimeType = MimeType.csv;
    } else {
      extension = 'txt';
      content = _generateText(shiftProvider, shifts, currencySymbol);
      mimeType = MimeType.text;
    }

    final timestamp = DateFormat(
      AppConstants.dateFormatFileTimestamp,
    ).format(DateTime.now());
    final fileName = 'shiftly_export_$timestamp';

    try {
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: utf8.encode(content),
        ext: extension,
        mimeType: mimeType,
      );
      return savedPath;
    } catch (_) {
      return null;
    }
  }

  static String _generateCsv(
    ShiftProvider shiftProvider,
    List<Shift> shifts,
    String symbol,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Job,Start Time,End Time,Net Hours,Hourly Rate,Tips,Incomes,Expenses,Total Pay',
    );

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
          job?.getRateForDate(shift.date) ??
          AppConstants.defaultHourlyRate;
      final pay = shift.calculateTotalPay(rate);
      final dateStr = AppConstants.formatDate(shift.date);
      final startStr = AppConstants.formatTime(shift.startTime);
      final endStr = AppConstants.formatTime(shift.endTime);
      final jobName = '"${job?.name ?? 'Unknown'}"';
      final netHours = shift.netHours.toStringAsFixed(2);
      final tips = shift.tips.toStringAsFixed(2);
      final incomes = shift.totalAutomaticIncomes.toStringAsFixed(2);
      final expenses = shift.totalAutomaticExpenses.toStringAsFixed(2);
      final totalPay = pay.toStringAsFixed(2);

      buffer.writeln(
        '$dateStr,$jobName,$startStr,$endStr,$netHours,$rate,$tips,$incomes,$expenses,$totalPay',
      );
    }
    return buffer.toString();
  }

  static String _generateText(
    ShiftProvider shiftProvider,
    List<Shift> shifts,
    String symbol,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('=== SHIFTLY EXPORT REPORT ===');
    buffer.writeln(
      'Generated: ${DateFormat(AppConstants.dateFormatFull).format(DateTime.now())}',
    );
    buffer.writeln('Total Shifts: ${shifts.length}');
    buffer.writeln('----------------------------------------\n');

    double totalHours = 0;
    double totalBase = 0;
    double totalTips = 0;
    double totalIncomes = 0;
    double totalExpenses = 0;
    double grandTotalNet = 0;

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
          job?.getRateForDate(shift.date) ??
          AppConstants.defaultHourlyRate;
      final pay = shift.calculateTotalPay(rate);
      totalHours += shift.netHours;
      totalBase += shift.calculateBaseSalary(rate);
      totalTips += shift.tips;
      totalIncomes += shift.totalAutomaticIncomes;
      totalExpenses += shift.totalAutomaticExpenses;
      grandTotalNet += pay;

      buffer.writeln('Date: ${AppConstants.formatDate(shift.date)}');
      buffer.writeln('Job: ${job?.name ?? 'Unknown'}');
      buffer.writeln(
        'Time: ${AppConstants.formatTime(shift.startTime)} - ${AppConstants.formatTime(shift.endTime)} (${shift.netHours.toStringAsFixed(2)} hrs)',
      );
      if (shift.tips > 0) {
        buffer.writeln(
          'Tips: +${UIUtils.formatCurrency(shift.tips, symbol: symbol)}',
        );
      }
      if (shift.totalAutomaticIncomes > 0) {
        buffer.writeln(
          'Incomes: +${UIUtils.formatCurrency(shift.totalAutomaticIncomes, symbol: symbol)}',
        );
      }
      if (shift.totalAutomaticExpenses > 0) {
        buffer.writeln(
          'Expenses: -${UIUtils.formatCurrency(shift.totalAutomaticExpenses, symbol: symbol)}',
        );
      }
      buffer.writeln(
        'Pay: ${UIUtils.formatCurrency(pay, symbol: symbol)} (Rate: $rate/hr)\n',
      );
      buffer.writeln('----------------------------------------');
    }

    buffer.writeln('\n=== SUMMARY ===');
    buffer.writeln('Total Hours: ${totalHours.toStringAsFixed(2)} hrs');
    buffer.writeln(
      'Base Salary: ${UIUtils.formatCurrency(totalBase, symbol: symbol)}',
    );
    if (totalTips > 0) {
      buffer.writeln(
        'Total Tips: +${UIUtils.formatCurrency(totalTips, symbol: symbol)}',
      );
    }
    if (totalIncomes > 0) {
      buffer.writeln(
        'Total Incomes: +${UIUtils.formatCurrency(totalIncomes, symbol: symbol)}',
      );
    }
    if (totalExpenses > 0) {
      buffer.writeln(
        'Total Expenses: -${UIUtils.formatCurrency(totalExpenses, symbol: symbol)}',
      );
    }
    buffer.writeln(
      'Grand Total Net: ${UIUtils.formatCurrency(grandTotalNet, symbol: symbol)}',
    );

    return buffer.toString();
  }
}
