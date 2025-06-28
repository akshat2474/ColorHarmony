import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/move_model.dart';

class AttackAnimationPainter extends CustomPainter {
  final Animation<double> animation;
  final AnimationType animationType;
  final MoveType moveType;
  final Offset startPosition;
  final Offset endPosition;

  AttackAnimationPainter({
    required this.animation,
    required this.animationType,
    required this.moveType,
    required this.startPosition,
    required this.endPosition,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0.0 || animation.value == 1.0) return;

    if (animationType == AnimationType.projectile) {
      _drawProjectile(canvas, size);
    } else if (animationType == AnimationType.physical) {
      _drawImpact(canvas, size);
    }
  }

  void _drawProjectile(Canvas canvas, Size size) {
    final progress = animation.value;
    final currentPosition = Offset.lerp(startPosition, endPosition, progress)!;
    final paint = Paint()..color = _getMoveColor();

    if (moveType == MoveType.fire) {
      for (int i = 0; i < 5; i++) {
        final randomOffset = Offset(
            (math.Random().nextDouble() - 0.5) * 20,
            (math.Random().nextDouble() - 0.5) * 20
        );
        canvas.drawCircle(currentPosition + randomOffset, 5 + math.Random().nextDouble() * 5, paint);
      }
    } else if (moveType == MoveType.water) {
      canvas.drawCircle(currentPosition, 15, paint..style = PaintingStyle.fill);
      canvas.drawCircle(currentPosition.translate(5, -10), 8, paint..color = Colors.white.withOpacity(0.5));
    }
  }

  void _drawImpact(Canvas canvas, Size size) {
    final progress = Curves.easeOut.transform(animation.value);
    final paint = Paint()
      ..color = _getMoveColor().withOpacity(1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * (1.0 - progress);
      
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 * math.pi / 180);
      final radius = 60 * progress;
      final x = endPosition.dx + math.cos(angle) * radius;
      final y = endPosition.dy + math.sin(angle) * radius;
      if (i == 0) starPath.moveTo(x, y);
      else starPath.lineTo(x, y);
    }
    starPath.close();
    canvas.drawPath(starPath, paint);
  }

  Color _getMoveColor() {
    switch (moveType) {
      case MoveType.fire: return Colors.orangeAccent;
      case MoveType.water: return Colors.blue.shade300;
      default: return Colors.grey.shade400;
    }
  }

  @override
  bool shouldRepaint(covariant AttackAnimationPainter oldDelegate) {
    return animation != oldDelegate.animation ||
           animationType != oldDelegate.animationType;
  }
}
