import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/services/shift_parser.dart';
import 'package:uuid/uuid.dart';

class ImportResult {
  final List<Shift> shifts;
  final int totalFound;
  final int duplicatesCount;
  final String? errorMessage;

  ImportResult({
    required this.shifts,
    required this.totalFound,
    this.duplicatesCount = 0,
    this.errorMessage,
  });
}

class ParsedNotesResult {
  final String? description;
  final List<AutomaticExpense>? automaticIncomes;
  final List<AutomaticExpense>? automaticExpenses;

  ParsedNotesResult({
    this.description,
    this.automaticIncomes,
    this.automaticExpenses,
  });
}

class ImportUtils {
  static final Uuid _uuid = const Uuid();

  /// Parse shifts from a selected file (xlsx, csv, json, txt)
  static Future<ImportResult> importFromFile(
    PlatformFile file,
    List<JobType> availableJobs, {
    String? defaultJobId,
  }) async {
    final bytes =
        file.bytes ??
        (file.path != null ? await file.xFile.readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) {
      return ImportResult(
        shifts: [],
        totalFound: 0,
        errorMessage: 'Empty file',
      );
    }

    final ext = file.extension?.toLowerCase() ?? '';
    final fallbackJobId =
        defaultJobId ??
        (availableJobs.isNotEmpty ? availableJobs.first.id : 'default');

    if (ext == 'xlsx' || ext == 'xls') {
      return _parseExcel(bytes, availableJobs, fallbackJobId);
    } else if (ext == 'json') {
      final content = utf8.decode(bytes);
      return _parseJson(content, availableJobs, fallbackJobId);
    } else if (ext == 'csv') {
      final content = utf8.decode(bytes);
      return _parseCsv(content, availableJobs, fallbackJobId);
    } else {
      // Fallback text parsing line by line
      final content = utf8.decode(bytes);
      return parseFromText(content, availableJobs, fallbackJobId);
    }
  }

  /// Parse shifts from raw text (can be JSON, CSV, or line-by-line format)
  static ImportResult parseFromText(
    String content,
    List<JobType> availableJobs,
    String defaultJobId,
  ) {
    content = content.trim();
    if (content.isEmpty) {
      return ImportResult(shifts: [], totalFound: 0);
    }

    // Try parsing as JSON first
    if (content.startsWith('[') || content.startsWith('{')) {
      try {
        final jsonResult = _parseJson(content, availableJobs, defaultJobId);
        if (jsonResult.shifts.isNotEmpty) {
          return jsonResult;
        }
      } catch (_) {}
    }

    // Try CSV parsing if header or commas detected
    if (content.contains(',') &&
        (content.toLowerCase().contains('date') || content.contains('תאריך'))) {
      final csvResult = _parseCsv(content, availableJobs, defaultJobId);
      if (csvResult.shifts.isNotEmpty) {
        return csvResult;
      }
    }

    // Otherwise, parse line by line using ShiftParser
    final lines = content.split(RegExp(r'\r?\n'));
    final List<Shift> parsedShifts = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty ||
          line.startsWith('===') ||
          line.startsWith('---') ||
          line.startsWith('Date,')) {
        continue;
      }

      final parsed = ShiftParser.parseResult(
        line,
        defaultJobId,
        availableJobTypes: availableJobs,
      );

      if (parsed.shift != null) {
        parsedShifts.add(parsed.shift!);
      }
    }

    return ImportResult(shifts: parsedShifts, totalFound: parsedShifts.length);
  }

  static ParsedNotesResult _parseNotesAndAutomations(String rawNotes) {
    if (rawNotes.isEmpty) return ParsedNotesResult(description: null);

    String? mainDesc;
    List<AutomaticExpense>? incomes;
    List<AutomaticExpense>? expenses;

    final parts = rawNotes.split('|');
    for (var part in parts) {
      part = part.trim();
      final lower = part.toLowerCase();
      if (lower.startsWith('incomes:') ||
          part.startsWith('הכנסות:') ||
          lower.startsWith('inc:')) {
        final sub = part.substring(part.indexOf(':') + 1).trim();
        incomes = _parseExpenseListString(sub);
      } else if (lower.startsWith('expenses:') ||
          part.startsWith('הוצאות:') ||
          lower.startsWith('exp:') ||
          lower.startsWith('הוצ:')) {
        final sub = part.substring(part.indexOf(':') + 1).trim();
        expenses = _parseExpenseListString(sub);
      } else {
        if (mainDesc == null || mainDesc.isEmpty) {
          mainDesc = part;
        } else {
          mainDesc = '$mainDesc | $part';
        }
      }
    }

    return ParsedNotesResult(
      description: mainDesc?.isNotEmpty == true ? mainDesc : null,
      automaticIncomes: incomes,
      automaticExpenses: expenses,
    );
  }

  static List<AutomaticExpense> _parseExpenseListString(String sub) {
    final List<AutomaticExpense> list = [];
    final items = sub.split(';');
    for (var item in items) {
      item = item.trim();
      if (item.isEmpty) continue;
      final colonIdx = item.lastIndexOf(':');
      if (colonIdx > 0) {
        final name = item.substring(0, colonIdx).trim();
        final amount =
            double.tryParse(item.substring(colonIdx + 1).trim()) ?? 0.0;
        if (amount > 0 || name.isNotEmpty) {
          list.add(AutomaticExpense(description: name, amount: amount));
        }
      }
    }
    return list;
  }

  static ImportResult _parseExcel(
    Uint8List bytes,
    List<JobType> availableJobs,
    String defaultJobId,
  ) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.firstWhere(
        (name) =>
            name.toLowerCase().contains('shift') || name.contains('משמרות'),
        orElse: () => excel.tables.keys.first,
      );
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.maxRows <= 1) {
        return ImportResult(shifts: [], totalFound: 0);
      }

      final List<Shift> shifts = [];
      final headerRow = sheet.rows.first
          .map((c) => c?.value?.toString().toLowerCase().trim() ?? '')
          .toList();

      // Find column indices by header keyword
      int dateIdx = _findColIndex(headerRow, ['date', 'תאריך']);
      int jobIdx = _findColIndex(headerRow, ['job', 'תפקיד', 'סוג']);
      int startIdx = _findColIndex(headerRow, ['start time', 'התחלה', 'start']);
      int endIdx = _findColIndex(headerRow, ['end time', 'סיום', 'end']);
      int rateIdx = _findColIndex(headerRow, ['hourly rate', 'rate', 'תעריף']);
      int tipsIdx = _findColIndex(headerRow, ['tips', 'טיפים']);
      int descIdx = _findColIndex(headerRow, [
        'notes',
        'description',
        'תיאור',
        'הערות',
      ]);

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        final dateStr = _cellVal(row, dateIdx >= 0 ? dateIdx : 0);
        if (dateStr.isEmpty) continue;

        final date = _parseDate(dateStr);
        if (date == null) continue;

        final jobStr = _cellVal(row, jobIdx >= 0 ? jobIdx : 1);
        final matchedJob = availableJobs.firstWhere(
          (j) => j.name.trim().toLowerCase() == jobStr.toLowerCase(),
          orElse: () => JobType(id: defaultJobId, name: ''),
        );

        final startStr = _cellVal(row, startIdx >= 0 ? startIdx : 2);
        final endStr = _cellVal(row, endIdx >= 0 ? endIdx : 3);

        final start = _combineDateAndTime(date, startStr, fallbackHour: 9);
        var end = _combineDateAndTime(date, endStr, fallbackHour: 17);
        if (end.isBefore(start)) {
          end = end.add(const Duration(days: 1));
        }

        final rate = double.tryParse(_cellVal(row, rateIdx));
        final tips = double.tryParse(_cellVal(row, tipsIdx)) ?? 0.0;
        final rawDesc = _cellVal(row, descIdx);

        final parsedNotes = _parseNotesAndAutomations(rawDesc);

        shifts.add(
          Shift(
            id: _uuid.v4(),
            date: date,
            startTime: start,
            endTime: end,
            jobTypeId: matchedJob.name.isNotEmpty
                ? matchedJob.id
                : defaultJobId,
            hourlyRate: rate,
            tips: tips,
            description: parsedNotes.description,
            automaticIncomes: parsedNotes.automaticIncomes,
            automaticExpenses: parsedNotes.automaticExpenses,
          ),
        );
      }

      return ImportResult(shifts: shifts, totalFound: shifts.length);
    } catch (e) {
      return ImportResult(
        shifts: [],
        totalFound: 0,
        errorMessage: e.toString(),
      );
    }
  }

  static ImportResult _parseCsv(
    String content,
    List<JobType> availableJobs,
    String defaultJobId,
  ) {
    try {
      final lines = content.split(RegExp(r'\r?\n'));
      if (lines.length <= 1) return ImportResult(shifts: [], totalFound: 0);

      final List<Shift> shifts = [];
      final headerRow = lines.first
          .split(',')
          .map((e) => e.replaceAll('"', '').toLowerCase().trim())
          .toList();

      int dateIdx = _findColIndex(headerRow, ['date', 'תאריך']);
      int jobIdx = _findColIndex(headerRow, ['job', 'תפקיד', 'סוג']);
      int startIdx = _findColIndex(headerRow, ['start time', 'התחלה', 'start']);
      int endIdx = _findColIndex(headerRow, ['end time', 'סיום', 'end']);
      int rateIdx = _findColIndex(headerRow, ['hourly rate', 'rate', 'תעריף']);
      int tipsIdx = _findColIndex(headerRow, ['tips', 'טיפים']);
      int descIdx = _findColIndex(headerRow, [
        'notes',
        'description',
        'תיאור',
        'הערות',
      ]);

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Smart split taking quotes into account
        final parts = RegExp(r'(?:[^\s,"]|"(?:\\.|[^"])*")+')
            .allMatches(line)
            .map((m) => m.group(0)!.replaceAll('"', '').trim())
            .toList();

        if (parts.isEmpty) continue;

        final dateStr = dateIdx >= 0 && dateIdx < parts.length
            ? parts[dateIdx]
            : parts[0];
        final date = _parseDate(dateStr);
        if (date == null) continue;

        final jobStr = jobIdx >= 0 && jobIdx < parts.length
            ? parts[jobIdx]
            : (parts.length > 1 ? parts[1] : '');
        final matchedJob = availableJobs.firstWhere(
          (j) => j.name.trim().toLowerCase() == jobStr.toLowerCase(),
          orElse: () => JobType(id: defaultJobId, name: ''),
        );

        final startStr = startIdx >= 0 && startIdx < parts.length
            ? parts[startIdx]
            : (parts.length > 2 ? parts[2] : '09:00');
        final endStr = endIdx >= 0 && endIdx < parts.length
            ? parts[endIdx]
            : (parts.length > 3 ? parts[3] : '17:00');

        final start = _combineDateAndTime(date, startStr, fallbackHour: 9);
        var end = _combineDateAndTime(date, endStr, fallbackHour: 17);
        if (end.isBefore(start)) {
          end = end.add(const Duration(days: 1));
        }

        final rate = rateIdx >= 0 && rateIdx < parts.length
            ? double.tryParse(parts[rateIdx])
            : null;
        final tips = tipsIdx >= 0 && tipsIdx < parts.length
            ? (double.tryParse(parts[tipsIdx]) ?? 0.0)
            : 0.0;
        final rawDesc = descIdx >= 0 && descIdx < parts.length
            ? parts[descIdx]
            : '';

        final parsedNotes = _parseNotesAndAutomations(rawDesc);

        shifts.add(
          Shift(
            id: _uuid.v4(),
            date: date,
            startTime: start,
            endTime: end,
            jobTypeId: matchedJob.name.isNotEmpty
                ? matchedJob.id
                : defaultJobId,
            hourlyRate: rate,
            tips: tips,
            description: parsedNotes.description,
            automaticIncomes: parsedNotes.automaticIncomes,
            automaticExpenses: parsedNotes.automaticExpenses,
          ),
        );
      }

      return ImportResult(shifts: shifts, totalFound: shifts.length);
    } catch (e) {
      return ImportResult(
        shifts: [],
        totalFound: 0,
        errorMessage: e.toString(),
      );
    }
  }

  static ImportResult _parseJson(
    String content,
    List<JobType> availableJobs,
    String defaultJobId,
  ) {
    try {
      final decoded = jsonDecode(content);
      List list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('shifts')) {
        list = decoded['shifts'] as List;
      } else if (decoded is Map) {
        list = [decoded];
      } else {
        return ImportResult(shifts: [], totalFound: 0);
      }

      final List<Shift> shifts = [];
      for (var item in list) {
        if (item is Map) {
          final jsonMap = Map<String, dynamic>.from(item);
          // Check if id needs reassignment
          if (!jsonMap.containsKey('id') || (jsonMap['id'] as String).isEmpty) {
            jsonMap['id'] = _uuid.v4();
          }

          // Remap jobTypeId if job name matched
          if (jsonMap.containsKey('jobName')) {
            final matched = availableJobs.firstWhere(
              (j) =>
                  j.name.trim().toLowerCase() ==
                  (jsonMap['jobName'] as String).trim().toLowerCase(),
              orElse: () => JobType(id: defaultJobId, name: ''),
            );
            if (matched.name.isNotEmpty) {
              jsonMap['jobTypeId'] = matched.id;
            }
          }
          if (!jsonMap.containsKey('jobTypeId') ||
              (jsonMap['jobTypeId'] as String).isEmpty) {
            jsonMap['jobTypeId'] = defaultJobId;
          }

          shifts.add(Shift.fromJson(jsonMap));
        }
      }

      return ImportResult(shifts: shifts, totalFound: shifts.length);
    } catch (e) {
      return ImportResult(
        shifts: [],
        totalFound: 0,
        errorMessage: e.toString(),
      );
    }
  }

  // Helper utils
  static int _findColIndex(List<String> headers, List<String> keywords) {
    for (int i = 0; i < headers.length; i++) {
      for (var kw in keywords) {
        if (headers[i].contains(kw)) return i;
      }
    }
    return -1;
  }

  static String _cellVal(List<Data?> row, int idx) {
    if (idx < 0 || idx >= row.length || row[idx]?.value == null) return '';
    return row[idx]!.value.toString().trim();
  }

  static DateTime? _parseDate(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return null;
    try {
      // ISO format YYYY-MM-DD
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;

      // DD.MM.YYYY or DD/MM/YYYY
      final parts = raw.split(RegExp(r'[./-]'));
      if (parts.length >= 2) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = DateTime.now().year;
        if (parts.length >= 3) {
          year = int.parse(parts[2]);
          if (year < 100) year += 2000;
        }
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  static DateTime _combineDateAndTime(
    DateTime date,
    String timeStr, {
    int fallbackHour = 9,
  }) {
    timeStr = timeStr.trim();
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].replaceAll(RegExp(r'[^\d]'), ''));
        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    } catch (_) {}
    return DateTime(date.year, date.month, date.day, fallbackHour, 0);
  }
}
