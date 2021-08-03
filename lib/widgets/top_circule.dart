import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const curveHeight = 250.0;
const avatarRadius = curveHeight * 0.10;
const avatarDiameter = avatarRadius * 2;

class CurvedCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: curveHeight,
      child: CustomPaint(
        painter: _MyPainter(),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(
        const Offset(0.0, 1.0),
        const Offset(0.0, 1.0),
        const [
          Color(0xFFc3c5ff),
          Color(0xFFcfd1ff),
        ],
      );

    final Offset circleCenter =
        Offset(size.width / 2, size.height - avatarRadius);

    const Offset topLeft = Offset(0, 0);
    final Offset bottomLeft = Offset(0, size.height * 0.5);
    final Offset topRight = Offset(size.width, 0);
    final Offset bottomRight = Offset(size.width, size.height * 0.5);

    final Offset leftCurveControlPoint =
        Offset(circleCenter.dx * 0.3, size.height - avatarRadius * 1.5);
    final Offset rightCurveControlPoint =
        Offset(circleCenter.dx * 1.6, size.height - avatarRadius);

    final arcStartAngle = 200 / 180 * pi;
    final avatarLeftPointX =
        circleCenter.dx + avatarRadius * cos(arcStartAngle);
    final avatarLeftPointY =
        circleCenter.dy + avatarRadius * sin(arcStartAngle);
    final Offset avatarLeftPoint =
        Offset(avatarLeftPointX, avatarLeftPointY); // the left point of the arc

    final Path path = Path()
      ..moveTo(topLeft.dx,
          topLeft.dy) // this move isn't required since the start point is (0,0)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy,
          avatarLeftPoint.dx, avatarLeftPoint.dy)
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
