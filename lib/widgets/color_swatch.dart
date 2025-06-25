import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

class ColorSwatch extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showHex;
  final double size;
  final bool showCopyFeedback;

  const ColorSwatch({
    Key? key,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.showHex = true,
    this.size = AppConstants.colorSwatchSize,
    this.showCopyFeedback = true,
  }) : super(key: key);

  @override
  State<ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<ColorSwatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: AppConstants.elevationLow,
      end: AppConstants.elevationHigh,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ColorSwatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
        if (widget.showCopyFeedback) {
          _copyToClipboard();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: widget.isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
              child: widget.showHex
                  ? Center(
                      child: Text(
                        ColorUtils.colorToHex(widget.color),
                        style: TextStyle(
                          color: ColorUtils.getContrastingTextColor(widget.color),
                          fontSize: widget.size > 50 ? 10 : 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _copyToClipboard() {
    final hex = ColorUtils.colorToHex(widget.color);
    Clipboard.setData(ClipboardData(text: hex));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied $hex to clipboard'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: widget.color,
        ),
      );
    }
  }
}
