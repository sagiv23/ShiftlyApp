import 'package:flutter/material.dart';

class MagenDavidPainter extends CustomPainter {
  final Color color;

  const MagenDavidPainter({this.color = Colors.amber});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    Path path1 = Path();
    Path path2 = Path();

    // Triangle pointing up
    path1.moveTo(w / 2, 0);
    path1.lineTo(w, h * 0.78);
    path1.lineTo(0, h * 0.78);
    path1.close();

    // Triangle pointing down
    path2.moveTo(w / 2, h);
    path2.lineTo(0, h * 0.22);
    path2.lineTo(w, h * 0.22);
    path2.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant MagenDavidPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class MagenDavidIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MagenDavidIcon({super.key, this.size = 16, this.color = Colors.amber});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: MagenDavidPainter(color: color)),
    );
  }
}
