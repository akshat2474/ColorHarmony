import 'package:flutter/material.dart';

class AnimatedColorTransition extends StatefulWidget {
  final Color fromColor;
  final Color toColor;
  final Duration duration;
  final Widget child;
  final Curve curve;

  const AnimatedColorTransition({
    super.key,
    required this.fromColor,
    required this.toColor,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedColorTransition> createState() => _AnimatedColorTransitionState();
}

class _AnimatedColorTransitionState extends State<AnimatedColorTransition>
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
      begin: widget.fromColor,
      end: widget.toColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedColorTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toColor != widget.toColor) {
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: widget.toColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.reset();
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
        return ColoredBox(
          color: _colorAnimation.value ?? widget.fromColor,
          child: widget.child,
        );
      },
    );
  }
}
