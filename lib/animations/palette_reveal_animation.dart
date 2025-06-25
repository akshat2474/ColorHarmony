import 'package:flutter/material.dart';

class PaletteRevealAnimation extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final Function(int)? onColorRevealed;

  const PaletteRevealAnimation({
    Key? key,
    required this.colors,
    this.duration = const Duration(milliseconds: 300),
    this.onColorRevealed,
  }) : super(key: key);

  @override
  State<PaletteRevealAnimation> createState() => _PaletteRevealAnimationState();
}

class _PaletteRevealAnimationState extends State<PaletteRevealAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.colors.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _startRevealAnimation();
  }

  void _startRevealAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100 * i));
      _controllers[i].forward();
      widget.onColorRevealed?.call(i);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.colors.asMap().entries.map((entry) {
        final index = entry.key;
        final color = entry.value;

        return Expanded(
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
