import 'package:flutter/material.dart';

class ColorMorphAnimation extends StatefulWidget {
  final Color startColor;
  final Color endColor;
  final Duration duration;
  final Widget child;
  final bool repeat;

  const ColorMorphAnimation({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.repeat = false,
  });

  @override
  State<ColorMorphAnimation> createState() => _ColorMorphAnimationState();
}

class _ColorMorphAnimationState extends State<ColorMorphAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: widget.startColor,
      end: widget.endColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          color: _colorAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
