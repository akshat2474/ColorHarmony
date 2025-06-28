import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

const Alignment kPlayerPlatformAnchor = Alignment(-0.55, 0.45);
const Alignment kEnemyPlatformAnchor = Alignment(0.55, -0.3);

class BattleBackgroundPainter extends CustomPainter {
  static const Color skyColorTop = Color(0xFF6dd5ed);
  static const Color skyColorBottom = Color(0xFFa2e2f0);
  static const Color skyColorHorizon = Color(0xFFe0f7fa);
  static const Color sunColor = Color(0xFFFFF9C4);
  static const Color cloudColor = Colors.white;
  static const Color distantHillsColor = Color(0xFF78bfa8);
  static const Color midHillsColor = Color(0xFF5ba07a);
  static const Color nearHillsColor = Color(0xFF4a7f5c);
  static const Color grassColorLight = Color(0xFFa2d274);
  static const Color grassColorDark = Color(0xFF8bc45c);
  static const Color bushColor = Color(0xFF3e7040);
  static const Color platformFillColor = Color(0xFFe9e0c3);
  static const Color platformBorderColor = Color(0xFFdcc994);
  static const Color platformShadowColor = Color(0xFFc9b98a);
  static const Color platformHighlightColor = Color(0xFFfaf6e7);

  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..style = PaintingStyle.fill;
    paint.shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height * 0.8),
      [skyColorTop, skyColorHorizon, skyColorBottom],
      [0.0, 0.7, 1.0],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    final sunCenter = Offset(size.width * 0.82, size.height * 0.18);
    paint.shader = ui.Gradient.radial(
      sunCenter,
      size.width * 0.13,
      [sunColor.withOpacity(0.8), sunColor.withOpacity(0.0)],
    );
    canvas.drawCircle(sunCenter, size.width * 0.13, paint);
    paint.shader = null;
    for (int i = 0; i < 8; i++) {
      final angle = pi / 8 * i;
      final rayLength = size.width * 0.22 + _random.nextDouble() * 10;
      final rayPaint = Paint()
        ..color = sunColor.withOpacity(0.13)
        ..strokeWidth = 5;
      final start = sunCenter;
      final end = sunCenter + Offset(cos(angle), sin(angle)) * rayLength;
      canvas.drawLine(start, end, rayPaint);
    }
    _drawCloud(canvas, size, 0.1, 0.13, 0.25, 0.08, 0.8, 16.0);
    _drawCloud(canvas, size, 0.6, 0.15, 0.4, 0.1, 0.7, 12.0);
    _drawCloud(canvas, size, 0.3, 0.22, 0.35, 0.09, 0.6, 18.0);
    _drawCloud(canvas, size, 0.7, 0.06, 0.22, 0.06, 0.5, 10.0);
    paint.color = distantHillsColor;
    final hillsPath = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(size.width * 0.2, size.height * 0.55, size.width * 0.3, size.height * 0.65, size.width * 0.5, size.height * 0.6)
      ..cubicTo(size.width * 0.7, size.height * 0.55, size.width * 0.85, size.height * 0.62, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillsPath, paint);
    paint.color = midHillsColor;
    final midHillsPath = Path()
      ..moveTo(0, size.height * 0.68)
      ..cubicTo(size.width * 0.18, size.height * 0.65, size.width * 0.4, size.height * 0.7, size.width * 0.6, size.height * 0.65)
      ..cubicTo(size.width * 0.8, size.height * 0.62, size.width * 0.95, size.height * 0.7, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(midHillsPath, paint);
    paint.color = nearHillsColor;
    final nearHillsPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(size.width * 0.2, size.height * 0.7, size.width * 0.45, size.height * 0.8, size.width * 0.7, size.height * 0.75)
      ..cubicTo(size.width * 0.9, size.height * 0.73, size.width, size.height * 0.8, size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearHillsPath, paint);
    paint.shader = ui.Gradient.linear(
      Offset(0, size.height * 0.7),
      Offset(0, size.height),
      [grassColorLight, grassColorDark],
    );
    final grassPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.7, size.width * 0.6, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.95, size.width, size.height * 0.9)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, paint);
    paint.shader = null;
    _drawPlatform(canvas, size, kEnemyPlatformAnchor);
    _drawPlatform(canvas, size, kPlayerPlatformAnchor);
    _drawVignette(canvas, size);
  }

  void _drawCloud(Canvas canvas, Size size, double x, double y, double w, double h, double opacity, double blur) {
    final cloudPaint = Paint()
      ..color = cloudColor.withOpacity(opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    final baseRect = Rect.fromLTWH(size.width * x, size.height * y, size.width * w, size.height * h);
    canvas.drawOval(baseRect, cloudPaint);
    for (int i = 0; i < 2; i++) {
      final dx = (i + 1) * size.width * w * 0.18;
      final dy = (i.isEven ? -1 : 1) * size.height * h * 0.15;
      final blobRect = baseRect.shift(Offset(dx, dy));
      canvas.drawOval(blobRect, cloudPaint);
    }
  }

  void _drawPlatform(Canvas canvas, Size size, Alignment alignment) {
    final paint = Paint();
    final center = alignment.alongSize(size);
    final platformRect = Rect.fromCenter(
      center: center,
      width: size.shortestSide * 0.5,
      height: size.shortestSide * 0.1,
    );
    paint.color = platformBorderColor;
    canvas.drawOval(platformRect, paint);
    paint.color = platformShadowColor;
    canvas.drawOval(platformRect.deflate(4.0), paint);
    paint.color = platformFillColor;
    canvas.drawOval(platformRect.deflate(7.0), paint);
    paint.color = platformHighlightColor.withOpacity(0.35);
    canvas.drawArc(platformRect.deflate(12.0), pi * 1.1, pi * 0.5, false, paint);
    paint.color = platformShadowColor.withOpacity(0.15);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    final top = platformRect.top;
    final bottom = platformRect.bottom;
    for (int i = 0; i < 6; i++) {
      final y = top + (bottom - top) * i / 6.0;
      canvas.drawLine(
        Offset(platformRect.left + 10, y),
        Offset(platformRect.right - 10, y),
        paint,
      );
    }
    paint.style = PaintingStyle.fill;
  }

  void _drawVignette(Canvas canvas, Size size) {
    final vignettePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height * 0.7),
        size.width * 0.7,
        [
          Colors.transparent,
          Colors.black.withOpacity(0.09),
          Colors.black.withOpacity(0.17),
        ],
        [0.7, 0.93, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
