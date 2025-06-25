import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class ColorWheel extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;
  final double size;

  const ColorWheel({
    Key? key,
    required this.onColorSelected,
    this.selectedColor,
    this.size = AppConstants.colorWheelSize,
  }) : super(key: key);

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  Offset? _selectedPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDragging = true);
        _handleColorSelection(details.localPosition);
      },
      onPanUpdate: (details) {
        _handleColorSelection(details.localPosition);
      },
      onPanEnd: (details) {
        setState(() => _isDragging = false);
      },
      onTapDown: (details) {
        _handleColorSelection(details.localPosition);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: ColorWheelPainter(
                selectedPosition: _selectedPosition,
                rotationAngle: _isDragging ? 0 : _rotationController.value * 2 * math.pi,
                isDragging: _isDragging,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleColorSelection(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (position - center).distance;
    final radius = widget.size / 2;

    if (distance <= radius) {
      setState(() {
        _selectedPosition = position;
      });

      final color = _getColorAtPosition(position, center, radius);
      widget.onColorSelected(color);
    }
  }

  Color _getColorAtPosition(Offset position, Offset center, double radius) {
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final hue = (math.atan2(dy, dx) * 180 / math.pi + 360) % 360;
    final saturation = (distance / radius).clamp(0.0, 1.0);
    const lightness = 0.5;

    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }
}

class ColorWheelPainter extends CustomPainter {
  final Offset? selectedPosition;
  final double rotationAngle;
  final bool isDragging;

  ColorWheelPainter({
    this.selectedPosition,
    required this.rotationAngle,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: const [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.cyan,
        Colors.blue,
        Colors.red,
      ],
      transform: GradientRotation(rotationAngle),
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);

    const innerGradient = RadialGradient(
      colors: [Colors.white, Colors.transparent],
      stops:  [0.0, 1.0],
    );
    final innerPaint = Paint()..shader = innerGradient.createShader(rect);
    canvas.drawCircle(center, radius, innerPaint);

    if (selectedPosition != null) {
      final indicatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      
      canvas.drawCircle(selectedPosition!, 12, indicatorPaint);
      
      final innerIndicatorPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(selectedPosition!, 12, innerIndicatorPaint);

      final crosshairPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;

      canvas.drawLine(
        selectedPosition! + const Offset(-8, 0),
        selectedPosition! + const Offset(8, 0),
        crosshairPaint,
      );
      canvas.drawLine(
        selectedPosition! + const Offset(0, -8),
        selectedPosition! + const Offset(0, 8),
        crosshairPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return selectedPosition != oldDelegate.selectedPosition ||
           rotationAngle != oldDelegate.rotationAngle ||
           isDragging != oldDelegate.isDragging;
  }
}
