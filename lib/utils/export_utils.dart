import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/l10n/app_localizations_en.dart';
import 'package:shiftly/l10n/app_localizations_he.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/ui_utils.dart';

class AnalyticsExportData {
  final double totalNetHours;
  final double totalBaseSalary;
  final double totalTips;
  final double totalIncomes;
  final double totalExpenses;
  final double grandTotalNet;
  final double avgEffectiveRate;
  final int shiftCount;
  final double totalRegularHours;
  final double totalRegularEarnings;
  final double totalTier1Hours;
  final double totalTier1Earnings;
  final double totalTier2Hours;
  final double totalTier2Earnings;
  final double totalShabbatHours;
  final double totalShabbatEarnings;
  final double totalHolidayHours;
  final double totalHolidayEarnings;
  final Map<String, JobExportSummary> jobBreakdown;

  AnalyticsExportData({
    required this.totalNetHours,
    required this.totalBaseSalary,
    required this.totalTips,
    required this.totalIncomes,
    required this.totalExpenses,
    required this.grandTotalNet,
    required this.avgEffectiveRate,
    required this.shiftCount,
    required this.totalRegularHours,
    required this.totalRegularEarnings,
    required this.totalTier1Hours,
    required this.totalTier1Earnings,
    required this.totalTier2Hours,
    required this.totalTier2Earnings,
    required this.totalShabbatHours,
    required this.totalShabbatEarnings,
    required this.totalHolidayHours,
    required this.totalHolidayEarnings,
    required this.jobBreakdown,
  });
}

class JobExportSummary {
  final String name;
  final int shiftCount;
  final double hours;
  final double pay;

  JobExportSummary({
    required this.name,
    required this.shiftCount,
    required this.hours,
    required this.pay,
  });
}

class ExportUtils {
  static Future<String?> exportShifts({
    required ShiftProvider shiftProvider,
    required List<Shift> shifts,
    required String format, // 'excel', 'pdf', 'csv', 'txt', 'json'
    required String currencySymbol,
    bool includeAnalytics = true,
    bool isHebrew = true,
    AppLocalizations? l,
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatRules = const ShabbatHolidayRules(),
  }) async {
    if (shifts.isEmpty) return null;

    final appLoc = l ??
        (isHebrew ? AppLocalizationsHe() : AppLocalizationsEn());

    Uint8List bytes;
    String extension = '';
    MimeType mimeType;

    final timestamp = DateFormat(
      AppConstants.dateFormatFileTimestamp,
    ).format(DateTime.now());
    final fileName = 'shiftly_export_$timestamp';

    final analyticsData = _calculateAnalyticsData(
      shiftProvider,
      shifts,
      rules,
      shabbatRules,
    );

    if (format == 'excel' || format == 'xlsx') {
      extension = 'xlsx';
      bytes = _generateExcel(
        shiftProvider,
        shifts,
        currencySymbol,
        rules,
        shabbatRules,
        analyticsData,
        includeAnalytics,
        isHebrew,
        appLoc,
      );
      mimeType = MimeType.microsoftExcel;
    } else if (format == 'pdf') {
      extension = 'pdf';
      bytes = await _generatePdf(
        shiftProvider,
        shifts,
        currencySymbol,
        rules,
        shabbatRules,
        analyticsData,
        includeAnalytics,
        isHebrew,
        appLoc,
      );
      mimeType = MimeType.pdf;
    } else if (format == 'csv') {
      extension = 'csv';
      final content = _generateCsv(
        shiftProvider,
        shifts,
        currencySymbol,
        rules,
        shabbatRules,
        isHebrew,
        appLoc,
      );
      bytes = Uint8List.fromList(utf8.encode(content));
      mimeType = MimeType.csv;
    } else if (format == 'json') {
      extension = 'json';
      final content = _generateJson(shifts);
      bytes = Uint8List.fromList(utf8.encode(content));
      mimeType = MimeType.json;
    } else {
      extension = 'txt';
      final content = _generateText(
        shiftProvider,
        shifts,
        currencySymbol,
        rules,
        shabbatRules,
        isHebrew,
        appLoc,
      );
      bytes = Uint8List.fromList(utf8.encode(content));
      mimeType = MimeType.text;
    }

    try {
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: extension,
        mimeType: mimeType,
      );
      return savedPath;
    } catch (_) {
      return null;
    }
  }

  static String _shapeRtlForPdf(String input, bool isHebrew) {
    if (!isHebrew || input.isEmpty) return input;
    if (!RegExp(r'[\u0590-\u05FF]').hasMatch(input)) {
      return input;
    }
    final words = input.split(' ');
    final reversedWords = words.map((word) {
      if (RegExp(r'[\u0590-\u05FF]').hasMatch(word)) {
        return word
            .split('')
            .reversed
            .join('');
      }
      return word;
    }).toList();
    return reversedWords.reversed.join(' ');
  }

  static AnalyticsExportData _calculateAnalyticsData(
      ShiftProvider shiftProvider,
      List<Shift> shifts,
      OvertimeRules rules,
      ShabbatHolidayRules shabbatRules,) {
    double totalNetHours = 0;
    double totalBaseSalary = 0;
    double totalTips = 0;
    double totalIncomes = 0;
    double totalExpenses = 0;
    double totalRegularHours = 0;
    double totalRegularEarnings = 0;
    double totalTier1Hours = 0;
    double totalTier1Earnings = 0;
    double totalTier2Hours = 0;
    double totalTier2Earnings = 0;
    double totalShabbatHours = 0;
    double totalShabbatEarnings = 0;
    double totalHolidayHours = 0;
    double totalHolidayEarnings = 0;

    final Map<String, JobExportSummary> jobBreakdown = {};

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final jobName = job?.name ?? 'Unknown';
      final rate =
          shift.hourlyRate ??
              job?.getRateForDate(shift.date) ??
              AppConstants.defaultHourlyRate;

      final pay = shift.calculateTotalPay(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );
      final base = shift.calculateBaseSalary(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );

      totalNetHours += shift.netHours;
      totalBaseSalary += base;
      totalTips += shift.tips;
      totalIncomes += shift.totalAutomaticIncomes;
      totalExpenses += shift.totalAutomaticExpenses;

      final bd = shift.getSalaryBreakdown(
        rules: rules,
        shabbatRules: shabbatRules,
      );

      totalRegularHours += bd.regularHours;
      totalRegularEarnings += bd.regularEarnings;
      totalTier1Hours += bd.tier1Hours;
      totalTier1Earnings += bd.tier1Earnings;
      totalTier2Hours += bd.tier2Hours;
      totalTier2Earnings += bd.tier2Earnings;
      totalShabbatHours += bd.shabbatHours;
      totalShabbatEarnings += bd.shabbatEarnings;
      totalHolidayHours += bd.holidayHours;
      totalHolidayEarnings += bd.holidayEarnings;

      final existing = jobBreakdown[jobName];
      if (existing != null) {
        jobBreakdown[jobName] = JobExportSummary(
          name: jobName,
          shiftCount: existing.shiftCount + 1,
          hours: existing.hours + shift.netHours,
          pay: existing.pay + pay,
        );
      } else {
        jobBreakdown[jobName] = JobExportSummary(
          name: jobName,
          shiftCount: 1,
          hours: shift.netHours,
          pay: pay,
        );
      }
    }

    final grandTotalNet = (totalBaseSalary + totalTips + totalIncomes) -
        totalExpenses;
    final avgEffectiveRate = totalNetHours > 0
        ? (grandTotalNet / totalNetHours)
        : 0.0;

    return AnalyticsExportData(
      totalNetHours: totalNetHours,
      totalBaseSalary: totalBaseSalary,
      totalTips: totalTips,
      totalIncomes: totalIncomes,
      totalExpenses: totalExpenses,
      grandTotalNet: grandTotalNet,
      avgEffectiveRate: avgEffectiveRate,
      shiftCount: shifts.length,
      totalRegularHours: totalRegularHours,
      totalRegularEarnings: totalRegularEarnings,
      totalTier1Hours: totalTier1Hours,
      totalTier1Earnings: totalTier1Earnings,
      totalTier2Hours: totalTier2Hours,
      totalTier2Earnings: totalTier2Earnings,
      totalShabbatHours: totalShabbatHours,
      totalShabbatEarnings: totalShabbatEarnings,
      totalHolidayHours: totalHolidayHours,
      totalHolidayEarnings: totalHolidayEarnings,
      jobBreakdown: jobBreakdown,
    );
  }

  // --- EXCEL GENERATOR ---

  static Uint8List _generateExcel(ShiftProvider shiftProvider,
      List<Shift> shifts,
      String symbol,
      OvertimeRules rules,
      ShabbatHolidayRules shabbatRules,
      AnalyticsExportData analytics,
      bool includeAnalytics,
      bool isHebrew,
      AppLocalizations l,) {
    final excel = Excel.createExcel();

    // Sheet 1: Shifts Log
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet1Name = l.excel_sheet_shifts;
    excel.rename(defaultSheet, sheet1Name);
    final sheet1 = excel[sheet1Name];

    // Headers from ARB with symbol placeholders (100% ARB-driven)
    final headers = [
      l.pdf_col_date,
      l.pdf_col_job,
      l.pdf_col_start_time,
      l.pdf_col_end_time,
      l.pdf_col_net_hours,
      l.pdf_col_hourly_rate_symbol(symbol),
      l.pdf_col_base_symbol(symbol),
      l.report_overtime_125_symbol(symbol),
      l.report_overtime_150_symbol(symbol),
      l.pdf_col_shabbat_symbol(symbol),
      l.pdf_col_tips_symbol(symbol),
      l.pdf_total_incomes_symbol(symbol),
      l.pdf_total_expenses_symbol(symbol),
      l.pdf_col_net_pay_symbol(symbol),
      l.pdf_col_notes,
    ];

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    sheet1.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet1.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    // Rows
    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
              job?.getRateForDate(shift.date) ??
              AppConstants.defaultHourlyRate;

      final pay = shift.calculateTotalPay(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );

      final bd = shift.getSalaryBreakdown(
        rules: rules,
        shabbatRules: shabbatRules,
      );

      // Format automatic expenses and incomes details for Excel
      final incDetails = shift.automaticIncomes?.map((i) => '${i
          .description}: ${i.amount}').join('; ') ?? '';
      final expDetails = shift.automaticExpenses?.map((e) => '${e
          .description}: ${e.amount}').join('; ') ?? '';
      final notesCombined = [
        if (shift.description != null && shift.description!.isNotEmpty) shift
            .description!,
        if (incDetails.isNotEmpty) 'Incomes: $incDetails',
        if (expDetails.isNotEmpty) 'Expenses: $expDetails',
      ].join(' | ');

      sheet1.appendRow([
        TextCellValue(AppConstants.formatDate(shift.date)),
        TextCellValue(job?.name ?? (isHebrew ? 'לא ידוע' : 'Unknown')),
        TextCellValue(AppConstants.formatTime(shift.startTime)),
        TextCellValue(AppConstants.formatTime(shift.endTime)),
        DoubleCellValue(shift.netHours),
        DoubleCellValue(rate),
        DoubleCellValue(bd.regularEarnings),
        DoubleCellValue(bd.tier1Earnings),
        DoubleCellValue(bd.tier2Earnings),
        DoubleCellValue(bd.shabbatEarnings + bd.holidayEarnings),
        DoubleCellValue(shift.tips),
        DoubleCellValue(shift.totalAutomaticIncomes),
        DoubleCellValue(shift.totalAutomaticExpenses),
        DoubleCellValue(pay),
        TextCellValue(notesCombined),
      ]);
    }

    // Totals Row
    sheet1.appendRow([
      TextCellValue(l.report_totals_row),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(analytics.totalNetHours),
      TextCellValue(''),
      DoubleCellValue(analytics.totalBaseSalary),
      DoubleCellValue(analytics.totalTier1Earnings),
      DoubleCellValue(analytics.totalTier2Earnings),
      DoubleCellValue(
          analytics.totalShabbatEarnings + analytics.totalHolidayEarnings),
      DoubleCellValue(analytics.totalTips),
      DoubleCellValue(analytics.totalIncomes),
      DoubleCellValue(analytics.totalExpenses),
      DoubleCellValue(analytics.grandTotalNet),
      TextCellValue(''),
    ]);

    // Sheet 2: Analytics & Summary (Optional)
    if (includeAnalytics) {
      final sheet2Name = l.excel_sheet_analytics;
      final sheet2 = excel[sheet2Name];

      sheet2.appendRow([TextCellValue(l.pdf_report_title)]);
      sheet2.appendRow([
        TextCellValue(l.report_generated_label(
            DateFormat(AppConstants.dateFormatFull).format(DateTime.now())))
      ]);
      sheet2.appendRow([TextCellValue('')]);

      sheet2.appendRow([
        TextCellValue(l.report_category_label),
        TextCellValue(isHebrew ? 'ערך' : 'Value')
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_shifts_count),
        IntCellValue(analytics.shiftCount)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_hours),
        DoubleCellValue(analytics.totalNetHours)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_base),
        DoubleCellValue(analytics.totalBaseSalary)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_tips),
        DoubleCellValue(analytics.totalTips)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_incomes),
        DoubleCellValue(analytics.totalIncomes)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_expenses),
        DoubleCellValue(analytics.totalExpenses)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_total_net_pay),
        DoubleCellValue(analytics.grandTotalNet)
      ]);
      sheet2.appendRow([
        TextCellValue(l.pdf_avg_rate),
        DoubleCellValue(analytics.avgEffectiveRate)
      ]);

      sheet2.appendRow([TextCellValue('')]);
      sheet2.appendRow([
        TextCellValue(isHebrew ? 'פירוט שכר' : 'PAY BREAKDOWN'),
        TextCellValue(l.report_hours_label),
        TextCellValue(l.report_earnings_label)
      ]);
      sheet2.appendRow([
        TextCellValue(l.report_regular_hours),
        DoubleCellValue(analytics.totalRegularHours),
        DoubleCellValue(analytics.totalRegularEarnings)
      ]);

      final disabledSuffix = l.report_disabled_status;
      final ot1Label = rules.enabled
          ? l.report_overtime_125
          : '${l.report_overtime_125}$disabledSuffix';
      sheet2.appendRow([
        TextCellValue(ot1Label),
        DoubleCellValue(analytics.totalTier1Hours),
        DoubleCellValue(analytics.totalTier1Earnings)
      ]);

      final ot2Label = rules.enabled
          ? l.report_overtime_150
          : '${l.report_overtime_150}$disabledSuffix';
      sheet2.appendRow([
        TextCellValue(ot2Label),
        DoubleCellValue(analytics.totalTier2Hours),
        DoubleCellValue(analytics.totalTier2Earnings)
      ]);

      final shabbatLabel = shabbatRules.enabled
          ? l.report_shabbat_hours
          : '${l.report_shabbat_hours}$disabledSuffix';
      sheet2.appendRow([
        TextCellValue(shabbatLabel),
        DoubleCellValue(analytics.totalShabbatHours),
        DoubleCellValue(analytics.totalShabbatEarnings)
      ]);

      final holidayLabel = shabbatRules.enabled
          ? l.report_holiday_hours
          : '${l.report_holiday_hours}$disabledSuffix';
      sheet2.appendRow([
        TextCellValue(holidayLabel),
        DoubleCellValue(analytics.totalHolidayHours),
        DoubleCellValue(analytics.totalHolidayEarnings)
      ]);

      sheet2.appendRow([TextCellValue('')]);
      sheet2.appendRow([
        TextCellValue(l.report_job_distribution),
        TextCellValue(l.pdf_shifts_count),
        TextCellValue(l.report_hours_label),
        TextCellValue(isHebrew ? 'סה״כ שכר' : 'Total Pay'),
      ]);
      analytics.jobBreakdown.forEach((_, jobSum) {
        sheet2.appendRow([
          TextCellValue(jobSum.name),
          IntCellValue(jobSum.shiftCount),
          DoubleCellValue(jobSum.hours),
          DoubleCellValue(jobSum.pay),
        ]);
      });
    }

    final encoded = excel.encode();
    return Uint8List.fromList(encoded ?? []);
  }

  // --- PDF GENERATOR ---

  static Future<Uint8List> _generatePdf(ShiftProvider shiftProvider,
      List<Shift> shifts,
      String symbol,
      OvertimeRules rules,
      ShabbatHolidayRules shabbatRules,
      AnalyticsExportData analytics,
      bool includeAnalytics,
      bool isHebrew,
      AppLocalizations l,) async {
    final pdf = pw.Document();

    // Load Hebrew Unicode Font from bundled app asset (guaranteed local & offline)
    pw.Font? ttfFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansHebrew.ttf');
      ttfFont = pw.Font.ttf(fontData);
    } catch (_) {}

    final theme = ttfFont != null
        ? pw.ThemeData.withFont(base: ttfFont, bold: ttfFont)
        : pw.ThemeData.base();

    final darkNavy = PdfColor.fromInt(0xFF0F172A);
    final cyan = PdfColor.fromInt(0xFF0284C7);
    final lightBg = PdfColor.fromInt(0xFFF8FAFC);
    final green = PdfColor.fromInt(0xFF10B981);

    // Helper widget for text with proper direction and RTL visual shaping
    pw.Widget pdfText(String text, {
      double fontSize = 10,
      pw.FontWeight fontWeight = pw.FontWeight.normal,
      PdfColor color = PdfColors.black,
    }) {
      final shapedText = _shapeRtlForPdf(text, isHebrew);
      final hasHeb = RegExp(r'[\u0590-\u05FF]').hasMatch(text);
      return pw.Text(
        shapedText,
        textDirection: (isHebrew || hasHeb) ? pw.TextDirection.rtl : pw
            .TextDirection.ltr,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      );
    }

    // Page 1: Analytics Summary Page
    if (includeAnalytics) {
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: isHebrew ? pw.CrossAxisAlignment.end : pw
                  .CrossAxisAlignment.start,
              children: [
                // Header Banner
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: darkNavy,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pdfText('SHIFTLY', fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white),
                          pdfText(
                            l.pdf_analytics_summary,
                            fontSize: 12,
                            color: PdfColors.cyan200,
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pdfText(
                            l.report_generated_label(DateFormat('dd/MM/yyyy')
                                .format(DateTime.now())),
                            fontSize: 10,
                            color: PdfColors.grey300,
                          ),
                          pdfText(
                            l.report_total_shifts_label(analytics.shiftCount),
                            fontSize: 11,
                            color: PdfColors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Key Metric Cards
                pw.Row(
                  children: [
                    _pdfMetricCard(
                      l.pdf_total_net_pay,
                      '${analytics.grandTotalNet.toStringAsFixed(2)} $symbol',
                      cyan,
                      pdfText,
                    ),
                    pw.SizedBox(width: 8),
                    _pdfMetricCard(
                      l.pdf_total_hours,
                      '${analytics.totalNetHours.toStringAsFixed(1)} ${isHebrew
                          ? "שעות"
                          : "hrs"}',
                      darkNavy,
                      pdfText,
                    ),
                    pw.SizedBox(width: 8),
                    _pdfMetricCard(
                      l.pdf_avg_rate,
                      '${analytics.avgEffectiveRate.toStringAsFixed(
                          2)} $symbol/${isHebrew ? "שעה" : "hr"}',
                      green,
                      pdfText,
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    _pdfMetricCard(
                      l.pdf_total_base,
                      '${analytics.totalBaseSalary.toStringAsFixed(2)} $symbol',
                      darkNavy,
                      pdfText,
                    ),
                    pw.SizedBox(width: 8),
                    _pdfMetricCard(
                      l.pdf_total_tips,
                      '+${analytics.totalTips.toStringAsFixed(2)} $symbol',
                      green,
                      pdfText,
                    ),
                    pw.SizedBox(width: 8),
                    _pdfMetricCard(
                      l.pdf_total_expenses,
                      '-${analytics.totalExpenses.toStringAsFixed(2)} $symbol',
                      PdfColor.fromInt(0xFFEF4444),
                      pdfText,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Pay Breakdown Section
                pdfText(
                  isHebrew
                      ? 'פירוט שכר ושעות נוספות'
                      : 'Salary & Overtime Breakdown',
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: darkNavy,
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(
                      color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: darkNavy),
                  rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                  headers: [
                    _shapeRtlForPdf(l.report_category_label, isHebrew),
                    _shapeRtlForPdf(l.report_rate_multiplier_label, isHebrew),
                    _shapeRtlForPdf(l.report_hours_label, isHebrew),
                    _shapeRtlForPdf(l.report_earnings_label, isHebrew),
                  ],
                  data: [
                    [
                      _shapeRtlForPdf(l.report_regular_hours, isHebrew),
                      '100%',
                      _shapeRtlForPdf(
                          '${analytics.totalRegularHours.toStringAsFixed(
                              2)} ${isHebrew ? "שעות" : "hrs"}', isHebrew),
                      '${analytics.totalRegularEarnings.toStringAsFixed(
                          2)} $symbol',
                    ],
                    [
                      _shapeRtlForPdf(
                        rules.enabled
                            ? l.report_overtime_125
                            : '${l.report_overtime_125} ${l
                            .report_disabled_status}',
                        isHebrew,
                      ),
                      rules.enabled ? '125%' : '-',
                      _shapeRtlForPdf(
                          '${analytics.totalTier1Hours.toStringAsFixed(
                              2)} ${isHebrew ? "שעות" : "hrs"}', isHebrew),
                      '${analytics.totalTier1Earnings.toStringAsFixed(
                          2)} $symbol',
                    ],
                    [
                      _shapeRtlForPdf(
                        rules.enabled
                            ? l.report_overtime_150
                            : '${l.report_overtime_150} ${l
                            .report_disabled_status}',
                        isHebrew,
                      ),
                      rules.enabled ? '150%' : '-',
                      _shapeRtlForPdf(
                          '${analytics.totalTier2Hours.toStringAsFixed(
                              2)} ${isHebrew ? "שעות" : "hrs"}', isHebrew),
                      '${analytics.totalTier2Earnings.toStringAsFixed(
                          2)} $symbol',
                    ],
                    [
                      _shapeRtlForPdf(
                        shabbatRules.enabled
                            ? l.report_shabbat_hours
                            : '${l.report_shabbat_hours} ${l
                            .report_disabled_status}',
                        isHebrew,
                      ),
                      shabbatRules.enabled ? 'מיוחד' : '-',
                      _shapeRtlForPdf(
                          '${analytics.totalShabbatHours.toStringAsFixed(
                              2)} ${isHebrew ? "שעות" : "hrs"}', isHebrew),
                      '${analytics.totalShabbatEarnings.toStringAsFixed(
                          2)} $symbol',
                    ],
                    [
                      _shapeRtlForPdf(
                        shabbatRules.enabled
                            ? l.report_holiday_hours
                            : '${l.report_holiday_hours} ${l
                            .report_disabled_status}',
                        isHebrew,
                      ),
                      shabbatRules.enabled ? 'מיוחד' : '-',
                      _shapeRtlForPdf(
                          '${analytics.totalHolidayHours.toStringAsFixed(
                              2)} ${isHebrew ? "שעות" : "hrs"}', isHebrew),
                      '${analytics.totalHolidayEarnings.toStringAsFixed(
                          2)} $symbol',
                    ],
                  ],
                ),
                pw.SizedBox(height: 20),

                // Job Distribution Section
                pdfText(
                  l.report_job_distribution,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: darkNavy,
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(
                      color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: cyan),
                  rowDecoration: pw.BoxDecoration(color: lightBg),
                  headers: [
                    _shapeRtlForPdf(l.report_job_name, isHebrew),
                    _shapeRtlForPdf(l.pdf_shifts_count, isHebrew),
                    _shapeRtlForPdf(l.pdf_total_hours, isHebrew),
                    _shapeRtlForPdf(
                        isHebrew ? 'סה״כ שכר' : 'Total Earnings', isHebrew),
                    _shapeRtlForPdf(l.report_pct_net_pay, isHebrew),
                  ],
                  data: analytics.jobBreakdown.values.map((j) {
                    final pct = analytics.grandTotalNet > 0 ? (j.pay /
                        analytics.grandTotalNet * 100) : 0.0;
                    return [
                      _shapeRtlForPdf(j.name, isHebrew),
                      '${j.shiftCount}',
                      _shapeRtlForPdf('${j.hours.toStringAsFixed(1)} ${isHebrew
                          ? "שעות"
                          : "hrs"}', isHebrew),
                      '${j.pay.toStringAsFixed(2)} $symbol',
                      '${pct.toStringAsFixed(1)}%',
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    }

    // Page 2+: Detailed Shifts Table
    final shiftRows = shifts.map((shift) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
              job?.getRateForDate(shift.date) ??
              AppConstants.defaultHourlyRate;

      final pay = shift.calculateTotalPay(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );

      final bd = shift.getSalaryBreakdown(
        rules: rules,
        shabbatRules: shabbatRules,
      );

      final dateStr = DateFormat('dd/MM/yy').format(shift.date);
      final timeStr = '${DateFormat('HH:mm').format(
          shift.startTime)}-${DateFormat('HH:mm').format(shift.endTime)}';

      String tags = '';
      if (bd.totalOvertimeHours > 0) tags += '${l.report_tag_overtime} ';
      if (bd.shabbatHours > 0) tags += '${l.report_tag_shabbat} ';
      if (bd.holidayHours > 0) tags += '${l.report_tag_holiday} ';

      // Include automatic expenses/incomes and descriptions in notes column
      final incDetails = shift.automaticIncomes?.map((i) => '${i
          .description}: ${i.amount}').join('; ') ?? '';
      final expDetails = shift.automaticExpenses?.map((e) => '${e
          .description}: ${e.amount}').join('; ') ?? '';
      final notesCombined = [
        if (shift.description != null && shift.description!.isNotEmpty) shift
            .description!,
        if (incDetails.isNotEmpty) 'Inc: $incDetails',
        if (expDetails.isNotEmpty) 'Exp: $expDetails',
      ].join(' | ');

      return [
        dateStr,
        _shapeRtlForPdf(
            job?.name ?? (isHebrew ? 'לא ידוע' : 'Unknown'), isHebrew),
        timeStr,
        shift.netHours.toStringAsFixed(1),
        rate.toStringAsFixed(1),
        bd.totalBaseSalary.toStringAsFixed(1),
        _shapeRtlForPdf(tags
            .trim()
            .isNotEmpty ? tags.trim() : '-', isHebrew),
        shift.tips.toStringAsFixed(1),
        _shapeRtlForPdf(
            notesCombined.isNotEmpty ? notesCombined : '-', isHebrew),
        '${pay.toStringAsFixed(2)} $symbol',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            alignment: isHebrew ? pw.Alignment.centerLeft : pw.Alignment
                .centerRight,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pdfText(
              l.pdf_report_title,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: isHebrew ? pw.Alignment.centerLeft : pw.Alignment
                .centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pdfText(
              l.report_page_number(context.pageNumber, context.pagesCount),
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pdfText(
              l.pdf_detailed_log,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: darkNavy,
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: darkNavy),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              headers: [
                _shapeRtlForPdf(l.pdf_col_date, isHebrew),
                _shapeRtlForPdf(l.pdf_col_job, isHebrew),
                _shapeRtlForPdf(l.pdf_col_time, isHebrew),
                _shapeRtlForPdf(l.pdf_col_net_hours, isHebrew),
                _shapeRtlForPdf(l.pdf_col_hourly_rate, isHebrew),
                _shapeRtlForPdf(l.pdf_col_base, isHebrew),
                _shapeRtlForPdf(l.pdf_col_tags, isHebrew),
                _shapeRtlForPdf(l.pdf_col_tips, isHebrew),
                _shapeRtlForPdf(l.pdf_col_notes, isHebrew),
                _shapeRtlForPdf(l.pdf_col_net_pay, isHebrew),
              ],
              data: shiftRows,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfMetricCard(String title,
      String value,
      PdfColor accentColor,
      pw.Widget Function(String, {double fontSize, pw
          .FontWeight fontWeight, PdfColor color}) textWidget,) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            textWidget(title, fontSize: 9, color: PdfColors.grey700),
            pw.SizedBox(height: 4),
            textWidget(value, fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: accentColor),
          ],
        ),
      ),
    );
  }

  // --- JSON, CSV & TEXT GENERATORS ---

  static String _generateJson(List<Shift> shifts) {
    final list = shifts.map((s) => s.toJson()).toList();
    return jsonEncode({
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'shifts': list,
    });
  }

  static String _generateCsv(
    ShiftProvider shiftProvider,
    List<Shift> shifts,
    String symbol,
    OvertimeRules rules,
    ShabbatHolidayRules shabbatRules,
      bool isHebrew,
      AppLocalizations l,
  ) {
    final buffer = StringBuffer();
    final hDate = l.pdf_col_date;
    final hJob = l.pdf_col_job;
    final hStart = l.pdf_col_start_time;
    final hEnd = l.pdf_col_end_time;
    final hNetHrs = l.pdf_col_net_hours;
    final hRate = l.pdf_col_hourly_rate;
    final hTips = l.pdf_col_tips;
    final hInc = l.pdf_total_incomes;
    final hExp = l.pdf_total_expenses;
    final hNetPay = l.pdf_col_net_pay;

    buffer.writeln(
        '$hDate,$hJob,$hStart,$hEnd,$hNetHrs,$hRate,$hTips,$hInc,$hExp,$hNetPay');

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate =
          shift.hourlyRate ??
          job?.getRateForDate(shift.date) ??
          AppConstants.defaultHourlyRate;
      final pay = shift.calculateTotalPay(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );
      final dateStr = AppConstants.formatDate(shift.date);
      final startStr = AppConstants.formatTime(shift.startTime);
      final endStr = AppConstants.formatTime(shift.endTime);
      final jobName = '"${job?.name ?? (isHebrew ? 'לא ידוע' : 'Unknown')}"';
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
    OvertimeRules rules,
    ShabbatHolidayRules shabbatRules,
      bool isHebrew,
      AppLocalizations l,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(l.pdf_report_title);
    buffer.writeln(
      l.report_generated_label(
          DateFormat(AppConstants.dateFormatFull).format(DateTime.now())),
    );
    buffer.writeln(l.report_total_shifts_label(shifts.length));
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
      final pay = shift.calculateTotalPay(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );
      totalHours += shift.netHours;
      totalBase += shift.calculateBaseSalary(
        rate,
        rules: rules,
        shabbatRules: shabbatRules,
      );
      totalTips += shift.tips;
      totalIncomes += shift.totalAutomaticIncomes;
      totalExpenses += shift.totalAutomaticExpenses;
      grandTotalNet += pay;

      buffer.writeln(
          '${l.pdf_col_date}: ${AppConstants.formatDate(shift.date)}');
      buffer.writeln('${l.pdf_col_job}: ${job?.name ??
          (isHebrew ? "לא ידוע" : "Unknown")}');
      buffer.writeln(
        '${l.pdf_col_time}: ${AppConstants.formatTime(
            shift.startTime)} - ${AppConstants.formatTime(
            shift.endTime)} (${shift.netHours.toStringAsFixed(2)} ${isHebrew
            ? "שעות"
            : "hrs"})',
      );
      if (shift.tips > 0) {
        buffer.writeln(
          '${l.pdf_col_tips}: +${UIUtils.formatCurrency(
              shift.tips, symbol: symbol)}',
        );
      }
      if (shift.totalAutomaticIncomes > 0) {
        buffer.writeln(
          '${l.pdf_total_incomes}: +${UIUtils.formatCurrency(
              shift.totalAutomaticIncomes, symbol: symbol)}',
        );
      }
      if (shift.totalAutomaticExpenses > 0) {
        buffer.writeln(
          '${l.pdf_total_expenses}: -${UIUtils.formatCurrency(
              shift.totalAutomaticExpenses, symbol: symbol)}',
        );
      }
      if (shift.description != null && shift.description!.isNotEmpty) {
        buffer.writeln('${l.pdf_col_notes}: ${shift.description}');
      }
      buffer.writeln(
        '${l.pdf_col_net_pay}: ${UIUtils.formatCurrency(
            pay, symbol: symbol)} (${l.pdf_col_hourly_rate}: ${UIUtils
            .formatCurrency(rate, symbol: symbol)}/${isHebrew
            ? "שעה"
            : "hr"})\n',
      );
      buffer.writeln('----------------------------------------');
    }

    buffer.writeln('\n=== ${l.report_totals_row} ===');
    buffer.writeln(
        '${l.pdf_total_hours}: ${totalHours.toStringAsFixed(2)} ${isHebrew
            ? "שעות"
            : "hrs"}');
    buffer.writeln(
      '${l.pdf_total_base}: ${UIUtils.formatCurrency(
          totalBase, symbol: symbol)}',
    );
    if (totalTips > 0) {
      buffer.writeln(
        '${l.pdf_total_tips}: +${UIUtils.formatCurrency(
            totalTips, symbol: symbol)}',
      );
    }
    if (totalIncomes > 0) {
      buffer.writeln(
        '${l.pdf_total_incomes}: +${UIUtils.formatCurrency(
            totalIncomes, symbol: symbol)}',
      );
    }
    if (totalExpenses > 0) {
      buffer.writeln(
        '${l.pdf_total_expenses}: -${UIUtils.formatCurrency(
            totalExpenses, symbol: symbol)}',
      );
    }
    buffer.writeln(
      '${l.pdf_total_net_pay}: ${UIUtils.formatCurrency(
          grandTotalNet, symbol: symbol)}',
    );

    return buffer.toString();
  }
}
