import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiftly/theme/app_theme.dart';

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
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'אין נתונים לתצוגה',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tipsColor = AppTheme.profit;
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);
    final gridColor = Theme.of(context).dividerColor.withValues(alpha: 0.15);

    double maxVal = 0;
    for (var dp in data) {
      if (dp.totalNet > maxVal) maxVal = dp.totalNet;
    }
    if (maxVal <= 0) maxVal = 100;

    // Round up maxVal for nice Y-axis steps
    final maxY = _calculateNiceMax(maxVal);

    return SizedBox(
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

      // Dotted Grid Line
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

      // Y Label
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
      final tipsVal = (dp.tips + dp.extraIncomes).clamp(0.0, netVal - baseVal);

      final totalHeightRatio = netVal / maxY;
      final baseHeightRatio = baseVal / maxY;

      final totalBarHeight = chartHeight * totalHeightRatio;
      final baseBarHeight = chartHeight * baseHeightRatio;

      final groundY = topPadding + chartHeight;
      final barTopY = groundY - totalBarHeight;

      // Selection Glow Background
      if (isSelected) {
        final glowRect = Rect.fromLTRB(
          centerX - barSlotWidth / 2 + 1,
          topPadding,
          centerX + barSlotWidth / 2 - 1,
          groundY,
        );
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(8)),
          glowPaint,
        );
      }

      if (netVal > 0) {
        // Base Pay Bar
        final baseRect = Rect.fromLTRB(
          barLeft,
          groundY - baseBarHeight,
          barRight,
          groundY,
        );
        final baseGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
        );

        final basePaint = Paint()..shader = baseGradient.createShader(baseRect);

        // Tips Bar
        final tipsRect = Rect.fromLTRB(
          barLeft,
          barTopY,
          barRight,
          groundY - baseBarHeight,
        );
        final tipsGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tipsColor, tipsColor.withValues(alpha: 0.75)],
        );
        final tipsPaint = Paint()..shader = tipsGradient.createShader(tipsRect);

        final totalRRect = RRect.fromRectAndCorners(
          Rect.fromLTRB(barLeft, barTopY, barRight, groundY),
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        );

        // Clip to rounded top
        canvas.save();
        canvas.clipRRect(totalRRect);
        canvas.drawRect(baseRect, basePaint);
        if (tipsVal > 0) {
          canvas.drawRect(tipsRect, tipsPaint);
        }
        canvas.restore();

        // Selected Border Highlight
        if (isSelected) {
          final borderPaint = Paint()
            ..color = isDark ? Colors.white : Colors.black87
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawRRect(totalRRect, borderPaint);
        }
      }

      // X Label
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
      return SizedBox(
        height: size,
        child: const Center(
          child: Text(
            'אין נתונים לפי תפקיד',
            style: TextStyle(color: Colors.grey),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
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

    double startAngle = -math.pi / 2; // Start from top 12 o'clock

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
        sweepAngle - 0.03, // Small gap
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

/// Data for Effective Hourly Wage Trend Line Chart
class HourlyWageTrendData {
  final DateTime date;
  final String label;
  final double effectiveRate;
  final double baseRate;

  const HourlyWageTrendData({
    required this.date,
    required this.label,
    required this.effectiveRate,
    required this.baseRate,
  });
}

/// Line chart widget showing wage trend
class HourlyWageLineChartWidget extends StatelessWidget {
  final List<HourlyWageTrendData> data;
  final String currencySymbol;
  final double height;

  const HourlyWageLineChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'דרושות לפחות 2 משמרות להצגת מגמה',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    const baseLineColor = AppTheme.warningSoft;
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _LineChartPainter(
          data: data,
          isDark: isDark,
          primaryColor: primaryColor,
          baseLineColor: baseLineColor,
          textColor: textColor,
          currencySymbol: currencySymbol,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<HourlyWageTrendData> data;
  final bool isDark;
  final Color primaryColor;
  final Color baseLineColor;
  final Color textColor;
  final String currencySymbol;

  _LineChartPainter({
    required this.data,
    required this.isDark,
    required this.primaryColor,
    required this.baseLineColor,
    required this.textColor,
    required this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 44.0;
    const rightPadding = 16.0;
    const topPadding = 16.0;
    const bottomPadding = 24.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    double maxVal = 0;
    double minVal = double.infinity;
    double avgBase = 0;

    for (var d in data) {
      if (d.effectiveRate > maxVal) maxVal = d.effectiveRate;
      if (d.baseRate > maxVal) maxVal = d.baseRate;
      if (d.effectiveRate < minVal) minVal = d.effectiveRate;
      if (d.baseRate < minVal) minVal = d.baseRate;
      avgBase += d.baseRate;
    }
    avgBase /= data.length;

    minVal = (minVal - 5).clamp(0.0, double.infinity);
    maxVal = maxVal + 10;
    final range = maxVal - minVal > 0 ? (maxVal - minVal) : 10.0;

    // 1. Draw Average Base Rate Line
    final baseLineY =
        topPadding + chartHeight * (1 - (avgBase - minVal) / range);
    final baseLinePaint = Paint()
      ..color = baseLineColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(leftPadding, baseLineY),
      Offset(size.width - rightPadding, baseLineY),
      baseLinePaint,
    );

    // 2. Draw Effective Rate Curve
    final points = <Offset>[];
    final stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + i * stepX;
      final y =
          topPadding +
          chartHeight * (1 - (data[i].effectiveRate - minVal) / range);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Fill Gradient under line
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPadding + chartHeight)
      ..lineTo(points.first.dx, topPadding + chartHeight)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.25),
        primaryColor.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(
          Rect.fromLTRB(
            leftPadding,
            topPadding,
            size.width - rightPadding,
            topPadding + chartHeight,
          ),
        ),
    );

    // Line Path
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Draw Dots on Points
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final dotPaint = Paint()..color = primaryColor;
      final haloPaint = Paint()..color = Colors.white;

      canvas.drawCircle(p, 5, haloPaint);
      canvas.drawCircle(p, 3.5, dotPaint);
    }

    // Y Axis Labels (Min, Base, Max)
    final textPainter = TextPainter(textDirection: TextDirection.rtl);
    _drawYLabel(
      canvas,
      textPainter,
      '${maxVal.round()}',
      topPadding,
      textColor,
      leftPadding,
    );
    _drawYLabel(
      canvas,
      textPainter,
      '${avgBase.round()}',
      baseLineY,
      baseLineColor,
      leftPadding,
    );
  }

  void _drawYLabel(
    Canvas canvas,
    TextPainter tp,
    String text,
    double y,
    Color color,
    double leftPadding,
  ) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
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
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.isDark != isDark;
  }
}

/// Data point for Cumulative Growth Line Chart
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
class CumulativeEarningsLineChartWidget extends StatelessWidget {
  final List<CumulativeGrowthData> data;
  final String currencySymbol;
  final double height;

  const CumulativeEarningsLineChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'דרושות לפחות 2 משמרות להצגת צמיחה מצטברת',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const grossColor = Color(0xFF6366F1); // Indigo
    const netColor = Color(0xFF10B981); // Emerald Green
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _CumulativeLineChartPainter(
          data: data,
          isDark: isDark,
          grossColor: grossColor,
          netColor: netColor,
          textColor: textColor,
          currencySymbol: currencySymbol,
        ),
      ),
    );
  }
}

class _CumulativeLineChartPainter extends CustomPainter {
  final List<CumulativeGrowthData> data;
  final bool isDark;
  final Color grossColor;
  final Color netColor;
  final Color textColor;
  final String currencySymbol;

  _CumulativeLineChartPainter({
    required this.data,
    required this.isDark,
    required this.grossColor,
    required this.netColor,
    required this.textColor,
    required this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 52.0;
    const rightPadding = 16.0;
    const topPadding = 16.0;
    const bottomPadding = 24.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    double maxVal = 0;
    for (var d in data) {
      if (d.cumulativeGross > maxVal) maxVal = d.cumulativeGross;
      if (d.cumulativeNet > maxVal) maxVal = d.cumulativeNet;
    }
    if (maxVal <= 0) maxVal = 100;

    final maxY = (maxVal * 1.1).ceilToDouble();

    // Draw 3 Gridlines
    final textPainter = TextPainter(textDirection: TextDirection.rtl);
    const steps = 3;
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= steps; i++) {
      final ratio = i / steps;
      final y = topPadding + chartHeight * (1 - ratio);
      final val = maxY * ratio;

      _drawDashedLine(
        canvas,
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '${val.round()}',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    final stepX = chartWidth / (data.length - 1);

    // Points for Gross Line & Net Line
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

    // Draw Net Fill Gradient & Line
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

    // Draw Gross Line
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

    // Gradient Fill
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

    // Line Path
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Node Dots
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

/// Data for Tips Trend Line Chart
class TipsTrendData {
  final DateTime date;
  final String label;
  final double tips;
  final double extraIncomes;

  const TipsTrendData({
    required this.date,
    required this.label,
    required this.tips,
    this.extraIncomes = 0,
  });

  double get totalTipsAndIncomes => tips + extraIncomes;
}

/// Tips & Special Incomes Trend Line Chart Widget
class TipsTrendLineChartWidget extends StatelessWidget {
  final List<TipsTrendData> data;
  final String currencySymbol;
  final double height;

  const TipsTrendLineChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'דרושות לפחות 2 משמרות להצגת מגמת טיפים',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tipsColor = Color(0xFFEC4899); // Vibrant Pink / Rose
    final textColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _TipsTrendLineChartPainter(
          data: data,
          isDark: isDark,
          tipsColor: tipsColor,
          textColor: textColor,
          currencySymbol: currencySymbol,
        ),
      ),
    );
  }
}

class _TipsTrendLineChartPainter extends CustomPainter {
  final List<TipsTrendData> data;
  final bool isDark;
  final Color tipsColor;
  final Color textColor;
  final String currencySymbol;

  _TipsTrendLineChartPainter({
    required this.data,
    required this.isDark,
    required this.tipsColor,
    required this.textColor,
    required this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 44.0;
    const rightPadding = 16.0;
    const topPadding = 16.0;
    const bottomPadding = 24.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    double maxVal = 0;
    double avgVal = 0;
    for (var d in data) {
      final total = d.totalTipsAndIncomes;
      if (total > maxVal) maxVal = total;
      avgVal += total;
    }
    avgVal /= data.length;

    if (maxVal <= 0) maxVal = 50;
    final maxY = (maxVal * 1.15).ceilToDouble();

    // Dotted Average Line
    final avgY = topPadding + chartHeight * (1 - avgVal / maxY);
    final avgPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(leftPadding, avgY),
      Offset(size.width - rightPadding, avgY),
      avgPaint,
    );

    // Tips Curve
    final stepX = chartWidth / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + i * stepX;
      final y =
          topPadding + chartHeight * (1 - data[i].totalTipsAndIncomes / maxY);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final c1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final c2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPadding + chartHeight)
      ..lineTo(points.first.dx, topPadding + chartHeight)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        tipsColor.withValues(alpha: 0.3),
        tipsColor.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(
          Rect.fromLTRB(
            leftPadding,
            topPadding,
            size.width - rightPadding,
            topPadding + chartHeight,
          ),
        ),
    );

    // Line Path
    final linePaint = Paint()
      ..color = tipsColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Dots
    for (var p in points) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = tipsColor);
    }

    // Y Axis Labels
    final textPainter = TextPainter(textDirection: TextDirection.rtl);
    _drawYLabel(
      canvas,
      textPainter,
      '${maxY.round()}',
      topPadding,
      textColor,
      leftPadding,
    );
    _drawYLabel(
      canvas,
      textPainter,
      '${avgVal.round()}',
      avgY,
      const Color(0xFFF59E0B),
      leftPadding,
    );
  }

  void _drawYLabel(
    Canvas canvas,
    TextPainter tp,
    String text,
    double y,
    Color color,
    double leftPadding,
  ) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
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
  bool shouldRepaint(covariant _TipsTrendLineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.isDark != isDark;
  }
}

/// Performance data per day of week
class DayOfWeekPerformance {
  final int dayIndex; // 1 = Sunday, 7 = Saturday
  final String dayName;
  final double totalEarnings;
  final double totalHours;
  final int shiftCount;

  const DayOfWeekPerformance({
    required this.dayIndex,
    required this.dayName,
    required this.totalEarnings,
    required this.totalHours,
    required this.shiftCount,
  });

  double get avgHourlyRate => totalHours > 0 ? (totalEarnings / totalHours) : 0;
}

/// Day of week comparison bar chart
class DayOfWeekChartWidget extends StatelessWidget {
  final List<DayOfWeekPerformance> days;
  final String currencySymbol;

  const DayOfWeekChartWidget({
    super.key,
    required this.days,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    double maxRate = 0;
    int bestDayIndex = -1;
    for (var d in days) {
      if (d.avgHourlyRate > maxRate) {
        maxRate = d.avgHourlyRate;
        bestDayIndex = d.dayIndex;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final isBest = day.dayIndex == bestDayIndex && day.avgHourlyRate > 0;
          final ratio = maxRate > 0
              ? (day.avgHourlyRate / maxRate).clamp(0.08, 1.0)
              : 0.08;
          final barHeight = 90.0 * ratio;

          final color = isBest
              ? AppTheme.primary
              : Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (day.avgHourlyRate > 0)
                Text(
                  '${day.avgHourlyRate.round()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                    color: isBest ? AppTheme.primaryDark : Colors.grey,
                  ),
                )
              else
                const SizedBox(height: 12),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 22,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isBest
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                day.dayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isBest ? FontWeight.bold : FontWeight.w500,
                  color: isBest
                      ? AppTheme.primaryDark
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
