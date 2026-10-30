import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';

/// Data point for daily or monthly earnings bar chart
class BarDataPoint {
  final String id;
  final String label;
  final String sublabel;
  final DateTime date;
  final double basePay;
  final double tips;
  final double extraIncomes;
  final double expenses;
  final double netHours;

  const BarDataPoint({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.date,
    required this.basePay,
    this.tips = 0,
    this.extraIncomes = 0,
    this.expenses = 0,
    required this.netHours,
  });

  double get netExtras => tips + extraIncomes - expenses;

  double get totalGross => basePay + tips + extraIncomes;

  double get totalNet => totalGross - expenses;

  double get effectiveHourlyRate => netHours > 0 ? (totalNet / netHours) : 0;
}

/// Interactive Bar Chart Widget
class EarningsBarChartWidget extends StatelessWidget {
  final List<BarDataPoint> data;
  final int? selectedIndex;
  final ValueChanged<int?> onSelected;
  final String currencySymbol;
  final double height;

  const EarningsBarChartWidget({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onSelected,
    required this.currencySymbol,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      final l = AppLocalizations.of(context)!;
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            l.analytics_no_data,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.electricCyan;
    final tipsColor = AppTheme.mintGreen;
    final textColor = isDark ? AppTheme.secondaryText : Colors.grey.shade700;
    final gridColor = isDark
        ? AppTheme.darkBorder
        : Theme.of(context).dividerColor.withValues(alpha: 0.15);

    double maxVal = 0;
    for (var dp in data) {
      if (dp.totalNet > maxVal) maxVal = dp.totalNet;
    }
    if (maxVal <= 0) maxVal = 100;

    final maxY = _calculateNiceMax(maxVal);

    final l = AppLocalizations.of(context)!;
    final totalChartEarnings = data.fold<double>(
      0,
      (sum, dp) => sum + dp.totalNet,
    );
    final chartSemanticSummary =
        '${l.nav_analytics}: ${data.length} ${l.common_shifts_count}, ${l.common_net}: ${totalChartEarnings.toStringAsFixed(0)} $currencySymbol';

    return Semantics(
      container: true,
      label: chartSemanticSummary,
      value: selectedIndex != null && selectedIndex! < data.length
          ? '${data[selectedIndex!].label}: ${data[selectedIndex!].totalNet.toStringAsFixed(0)} $currencySymbol'
          : null,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onTapDown: (details) {
                final x = details.localPosition.dx;
                const leftPadding = 48.0;
                const rightPadding = 16.0;
                final chartWidth = width - leftPadding - rightPadding;
                if (x >= leftPadding && x <= width - rightPadding) {
                  final barWidth = chartWidth / data.length;
                  final index = ((x - leftPadding) / barWidth).floor().clamp(
                    0,
                    data.length - 1,
                  );
                  onSelected(index == selectedIndex ? null : index);
                } else {
                  onSelected(null);
                }
              },
              child: CustomPaint(
                size: Size(width, height),
                painter: _BarChartPainter(
                  data: data,
                  selectedIndex: selectedIndex,
                  maxY: maxY,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  tipsColor: tipsColor,
                  textColor: textColor,
                  gridColor: gridColor,
                  currencySymbol: currencySymbol,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _calculateNiceMax(double value) {
    if (value <= 50) return 50;
    if (value <= 100) return 100;
    if (value <= 250) return 250;
    if (value <= 500) return 500;
    if (value <= 1000) return 1000;
    if (value <= 2500) return 2500;
    if (value <= 5000) return 5000;
    if (value <= 10000) return 10000;
    return (value / 1000).ceil() * 1000.0;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarDataPoint> data;
  final int? selectedIndex;
  final double maxY;
  final bool isDark;
  final Color primaryColor;
  final Color tipsColor;
  final Color textColor;
  final Color gridColor;
  final String currencySymbol;

  _BarChartPainter({
    required this.data,
    required this.selectedIndex,
    required this.maxY,
    required this.isDark,
    required this.primaryColor,
    required this.tipsColor,
    required this.textColor,
    required this.gridColor,
    required this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 48.0;
    const rightPadding = 12.0;
    const topPadding = 20.0;
    const bottomPadding = 28.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Draw Gridlines and Y-axis labels
    const steps = 3;
    final textPainter = TextPainter(textDirection: TextDirection.rtl);

    for (int i = 0; i <= steps; i++) {
      final yRatio = i / steps;
      final yPos = topPadding + chartHeight * (1 - yRatio);
      final val = maxY * yRatio;

      final linePaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      _drawDashedLine(
        canvas,
        Offset(leftPadding, yPos),
        Offset(size.width - rightPadding, yPos),
        linePaint,
      );

      final labelStr = '${val.round()}';
      textPainter.text = TextSpan(
        text: labelStr,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 6,
          yPos - textPainter.height / 2,
        ),
      );
    }

    // 2. Draw Bars
    final numBars = data.length;
    final barSlotWidth = chartWidth / numBars;
    final barGap = (barSlotWidth * 0.25).clamp(2.0, 12.0);
    final actualBarWidth = (barSlotWidth - barGap).clamp(4.0, 36.0);

    for (int i = 0; i < numBars; i++) {
      final dp = data[i];
      final isSelected = selectedIndex == i;
      final centerX = leftPadding + i * barSlotWidth + barSlotWidth / 2;
      final barLeft = centerX - actualBarWidth / 2;
      final barRight = centerX + actualBarWidth / 2;

      final netVal = dp.totalNet.clamp(0.0, maxY);
      final baseVal = dp.basePay.clamp(0.0, netVal);
      final tipsVal = (dp.tips + dp.extraIncomes - dp.expenses).clamp(
        0.0,
        netVal - baseVal,
      );

      final totalHeightRatio = netVal / maxY;
      final baseHeightRatio = baseVal / maxY;

      final totalBarHeight = chartHeight * totalHeightRatio;
      final baseBarHeight = chartHeight * baseHeightRatio;

      final groundY = topPadding + chartHeight;
      final barTopY = groundY - totalBarHeight;

      if (isSelected) {
        final glowRect = Rect.fromLTRB(
          centerX - barSlotWidth / 2 + 1,
          topPadding,
          centerX + barSlotWidth / 2 - 1,
          groundY,
        );
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(8)),
          glowPaint,
        );
      }

      if (netVal > 0) {
        final baseRect = Rect.fromLTRB(
          barLeft,
          groundY - baseBarHeight,
          barRight,
          groundY,
        );
        final baseGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, AppTheme.brightCyan],
        );

        final basePaint = Paint()..shader = baseGradient.createShader(baseRect);

        final tipsRect = Rect.fromLTRB(
          barLeft,
          barTopY,
          barRight,
          groundY - baseBarHeight,
        );
        final tipsGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tipsColor, AppTheme.profitSoft],
        );
        final tipsPaint = Paint()..shader = tipsGradient.createShader(tipsRect);

        final totalRRect = RRect.fromRectAndCorners(
          Rect.fromLTRB(barLeft, barTopY, barRight, groundY),
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        );

        canvas.save();
        canvas.clipRRect(totalRRect);
        canvas.drawRect(baseRect, basePaint);
        if (tipsVal > 0) {
          canvas.drawRect(tipsRect, tipsPaint);
        }
        canvas.restore();

        if (isSelected) {
          final borderPaint = Paint()
            ..color = AppTheme.electricCyan
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawRRect(totalRRect, borderPaint);
        }
      }

      if (numBars <= 12 || i % (numBars > 20 ? 3 : 2) == 0 || isSelected) {
        textPainter.text = TextSpan(
          text: dp.label,
          style: TextStyle(
            color: isSelected ? primaryColor : textColor,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2, groundY + 6),
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(math.min(startX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.maxY != maxY ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Data for Donut Chart segment
class DonutSegment {
  final String id;
  final String name;
  final double amount;
  final double hours;
  final Color color;
  final double percentage;

  const DonutSegment({
    required this.id,
    required this.name,
    required this.amount,
    required this.hours,
    required this.color,
    required this.percentage,
  });
}

/// Donut / Pie Chart Widget
class JobDonutChartWidget extends StatelessWidget {
  final List<DonutSegment> segments;
  final String centerTitle;
  final String centerSubtitle;
  final double size;

  const JobDonutChartWidget({
    super.key,
    required this.segments,
    required this.centerTitle,
    required this.centerSubtitle,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      final l = AppLocalizations.of(context)!;
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            l.analytics_no_job_data,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _DonutPainter(segments: segments, isDark: isDark),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  centerSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.secondaryText
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final bool isDark;

  _DonutPainter({required this.segments, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 24.0;
    final drawRadius = radius - strokeWidth / 2;

    double startAngle = -math.pi / 2;

    for (var seg in segments) {
      final sweepAngle = (seg.percentage / 100.0) * 2 * math.pi;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        startAngle,
        sweepAngle - 0.03,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.isDark != isDark;
  }
}

/// Data for Cumulative Growth Line Chart
class CumulativeGrowthData {
  final DateTime date;
  final String label;
  final double cumulativeGross;
  final double cumulativeNet;

  const CumulativeGrowthData({
    required this.date,
    required this.label,
    required this.cumulativeGross,
    required this.cumulativeNet,
  });
}

/// Cumulative Growth Line Chart Widget
class CumulativeEarningsLineChartWidget extends StatefulWidget {
  final List<CumulativeGrowthData> data;
  final String currencySymbol;
  final double height;

  const CumulativeEarningsLineChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    this.height = 225,
  });

  @override
  State<CumulativeEarningsLineChartWidget> createState() =>
      _CumulativeEarningsLineChartWidgetState();
}

class _CumulativeEarningsLineChartWidgetState
    extends State<CumulativeEarningsLineChartWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.length < 2) {
      final l = AppLocalizations.of(context)!;
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            l.analytics_min_shifts_growth,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const grossColor = AppTheme.neonViolet;
    const netColor = AppTheme.electricCyan;
    final textColor = isDark ? AppTheme.secondaryText : Colors.grey.shade700;

    double maxVal = 0;
    for (var d in widget.data) {
      if (d.cumulativeGross > maxVal) maxVal = d.cumulativeGross;
      if (d.cumulativeNet > maxVal) maxVal = d.cumulativeNet;
    }
    if (maxVal <= 0) maxVal = 100;
    final maxY = (maxVal * 1.18).ceilToDouble();

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const yAxisWidth = 48.0;
          final availableChartWidth = constraints.maxWidth - yAxisWidth;
          const pointSpacing = 54.0;
          final contentWidth = math.max(
            availableChartWidth,
            widget.data.length * pointSpacing,
          );

          return Row(
            children: [
              SizedBox(
                width: yAxisWidth,
                height: widget.height,
                child: CustomPaint(
                  painter: _CumulativeYAxisScalePainter(
                    maxY: maxY,
                    textColor: textColor,
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: contentWidth,
                      height: widget.height,
                      child: CustomPaint(
                        size: Size(contentWidth, widget.height),
                        painter: _CumulativeLineChartPainter(
                          data: widget.data,
                          maxY: maxY,
                          isDark: isDark,
                          grossColor: grossColor,
                          netColor: netColor,
                          textColor: textColor,
                          currencySymbol: widget.currencySymbol,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CumulativeYAxisScalePainter extends CustomPainter {
  final double maxY;
  final Color textColor;

  _CumulativeYAxisScalePainter({required this.maxY, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 32.0;
    const bottomPadding = 38.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    const steps = 3;

    final tp = TextPainter(textDirection: TextDirection.rtl);

    for (int i = 0; i <= steps; i++) {
      final ratio = i / steps;
      final y = topPadding + chartHeight * (1 - ratio);
      final val = maxY * ratio;

      tp.text = TextSpan(
        text: '${val.round()}',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(size.width - tp.width - 4, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CumulativeYAxisScalePainter oldDelegate) =>
      false;
}

class _CumulativeLineChartPainter extends CustomPainter {
  final List<CumulativeGrowthData> data;
  final double maxY;
  final bool isDark;
  final Color grossColor;
  final Color netColor;
  final Color textColor;
  final String currencySymbol;

  _CumulativeLineChartPainter({
    required this.data,
    required this.maxY,
    required this.isDark,
    required this.grossColor,
    required this.netColor,
    required this.textColor,
    required this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 20.0;
    const rightPadding = 20.0;
    const topPadding = 32.0;
    const bottomPadding = 38.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    const steps = 3;
    final gridPaint = Paint()
      ..color = isDark
          ? AppTheme.darkBorder
          : Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= steps; i++) {
      final ratio = i / steps;
      final y = topPadding + chartHeight * (1 - ratio);

      _drawDashedLine(
        canvas,
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final stepX = chartWidth / (data.length - 1);

    final grossPoints = <Offset>[];
    final netPoints = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + i * stepX;
      final grossY =
          topPadding + chartHeight * (1 - data[i].cumulativeGross / maxY);
      final netY =
          topPadding + chartHeight * (1 - data[i].cumulativeNet / maxY);

      grossPoints.add(Offset(x, grossY));
      netPoints.add(Offset(x, netY));
    }

    _drawCurvedLineAndFill(
      canvas,
      netPoints,
      chartHeight,
      topPadding,
      leftPadding,
      size.width - rightPadding,
      netColor,
      0.25,
    );

    _drawCurvedLineAndFill(
      canvas,
      grossPoints,
      chartHeight,
      topPadding,
      leftPadding,
      size.width - rightPadding,
      grossColor,
      0.12,
    );

    final textPainter = TextPainter(textDirection: TextDirection.rtl);

    for (int i = 0; i < data.length; i++) {
      final pNet = netPoints[i];
      final netVal = data[i].cumulativeNet;

      textPainter.text = TextSpan(
        text: UIUtils.formatCurrency(
          netVal,
          symbol: currencySymbol,
          decimals: 0,
        ),
        style: TextStyle(
          color: netColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pNet.dx - textPainter.width / 2, pNet.dy - 16),
      );

      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pNet.dx - textPainter.width / 2, topPadding + chartHeight + 8),
      );
    }
  }

  void _drawCurvedLineAndFill(
    Canvas canvas,
    List<Offset> points,
    double chartHeight,
    double topPadding,
    double leftPadding,
    double rightX,
    Color color,
    double fillOpacity,
  ) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final c1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final c2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPadding + chartHeight)
      ..lineTo(points.first.dx, topPadding + chartHeight)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: fillOpacity),
        color.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(
          Rect.fromLTRB(
            leftPadding,
            topPadding,
            rightX,
            topPadding + chartHeight,
          ),
        ),
    );

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    for (var p in points) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
      canvas.drawCircle(p, 2.5, Paint()..color = color);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(math.min(startX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _CumulativeLineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.isDark != isDark;
  }
}

/// Data for Time of Day Segment
class TimeOfDaySegment {
  final String name;
  final String timeRange;
  final double hours;
  final Color color;
  final IconData icon;

  const TimeOfDaySegment({
    required this.name,
    required this.timeRange,
    required this.hours,
    required this.color,
    required this.icon,
  });
}

/// Time of Day Breakdown Widget
class TimeOfDayChartWidget extends StatelessWidget {
  final List<TimeOfDaySegment> segments;
  final String currencySymbol;

  const TimeOfDayChartWidget({
    super.key,
    required this.segments,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double totalHours = 0;
    for (var s in segments) {
      totalHours += s.hours;
    }

    if (totalHours <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l.analytics_no_shift_data_period,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 16,
            child: Row(
              children: segments.map((seg) {
                final flex = (seg.hours / totalHours * 1000).round();
                if (flex <= 0) return const SizedBox.shrink();
                return Expanded(
                  flex: flex,
                  child: Container(color: seg.color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: segments.map((seg) {
            final pct = totalHours > 0 ? (seg.hours / totalHours * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: seg.color.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: seg.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: seg.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(seg.icon, size: 16, color: seg.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seg.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            seg.timeRange,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.secondaryText
                                  : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l.analytics_hours_suffix_format(
                            seg.hours.toStringAsFixed(1),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: seg.color,
                          ),
                        ),
                        Text(
                          l.analytics_utilization_format(
                            pct.toStringAsFixed(0),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.secondaryText
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Data for Shift Duration Category
class ShiftDurationCategory {
  final String label;
  final String durationRange;
  final int count;
  final double hours;
  final double avgEarnings;
  final Color color;
  final IconData icon;

  const ShiftDurationCategory({
    required this.label,
    required this.durationRange,
    required this.count,
    required this.hours,
    required this.avgEarnings,
    required this.color,
    required this.icon,
  });
}

/// Shift Duration & Fatigue Distribution Widget
class ShiftDurationDistributionWidget extends StatelessWidget {
  final List<ShiftDurationCategory> categories;
  final String currencySymbol;

  const ShiftDurationDistributionWidget({
    super.key,
    required this.categories,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int totalCount = 0;
    for (var c in categories) {
      totalCount += c.count;
    }

    if (totalCount == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l.analytics_no_shift_data_period,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: categories.map((cat) {
        final pct = totalCount > 0 ? (cat.count / totalCount * 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cat.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${cat.durationRange})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppTheme.secondaryText
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100.0,
                          backgroundColor: cat.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.analytics_shifts_format('${cat.count}'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: cat.color,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.secondaryText : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
