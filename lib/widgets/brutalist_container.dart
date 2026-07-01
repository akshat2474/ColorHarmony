import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BrutalistContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const BrutalistContainer({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderWidth = AppConstants.borderWidth,
    this.shadowOffset = AppConstants.shadowOffset,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    
    return container;
  }
}

class BrutalistButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  
  const BrutalistButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = AppConstants.accentCyan,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _isPressed ? AppConstants.shadowOffsetSmall : 0,
          left: _isPressed ? AppConstants.shadowOffsetSmall : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: Colors.black, width: AppConstants.borderWidth),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(AppConstants.shadowOffsetSmall, AppConstants.shadowOffsetSmall),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
