import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';

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

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'shiftly_export_$timestamp';

    try {
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: utf8.encode(content),
        ext: extension,
        mimeType: mimeType,
      );
      return savedPath.isNotEmpty ? savedPath : 'saved';
    } catch (e) {
      return null;
    }
  }

  static String generateExportContent({
    required ShiftProvider shiftProvider,
    required List<Shift> shifts,
    required String format,
    required String currencySymbol,
  }) {
    if (format == 'csv') {
      return _generateCsv(shiftProvider, shifts, currencySymbol);
    } else {
      return _generateText(shiftProvider, shifts, currencySymbol);
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
          shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      final pay = shift.calculateTotalPay(rate);
      final dateStr = DateFormat('dd/MM/yyyy').format(shift.date);
      final startStr = DateFormat('HH:mm').format(shift.startTime);
      final endStr = DateFormat('HH:mm').format(shift.endTime);
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
      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
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
          shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      final pay = shift.calculateTotalPay(rate);
      totalHours += shift.netHours;
      totalBase += shift.netHours * rate;
      totalTips += shift.tips;
      totalIncomes += shift.totalAutomaticIncomes;
      totalExpenses += shift.totalAutomaticExpenses;
      grandTotalNet += pay;

      buffer.writeln('Date: ${DateFormat('dd/MM/yyyy').format(shift.date)}');
      buffer.writeln('Job: ${job?.name ?? 'Unknown'}');
      buffer.writeln(
        'Time: ${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)} (${shift.netHours.toStringAsFixed(2)} hrs)',
      );
      if (shift.tips > 0) {
        buffer.writeln('Tips: +$symbol${shift.tips.toStringAsFixed(2)}');
      }
      if (shift.totalAutomaticIncomes > 0) {
        buffer.writeln(
          'Incomes: +$symbol${shift.totalAutomaticIncomes.toStringAsFixed(2)}',
        );
      }
      if (shift.totalAutomaticExpenses > 0) {
        buffer.writeln(
          'Expenses: -$symbol${shift.totalAutomaticExpenses.toStringAsFixed(2)}',
        );
      }
      buffer.writeln('Total: $symbol${pay.toStringAsFixed(2)}');
      buffer.writeln('----------------------------------------');
    }

    buffer.writeln('\n=== SUMMARY ===');
    buffer.writeln('Total Hours: ${totalHours.toStringAsFixed(2)}');
    buffer.writeln('Base Salary: $symbol${totalBase.toStringAsFixed(2)}');
    buffer.writeln('Tips: $symbol${totalTips.toStringAsFixed(2)}');
    buffer.writeln('Incomes: $symbol${totalIncomes.toStringAsFixed(2)}');
    buffer.writeln('Expenses: $symbol${totalExpenses.toStringAsFixed(2)}');
    buffer.writeln('Net Total: $symbol${grandTotalNet.toStringAsFixed(2)}');

    return buffer.toString();
  }
}
