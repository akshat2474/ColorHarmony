import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/pokemon_model.dart';

class PokemonSprite extends StatefulWidget {
  final Pokemon pokemon;
  final bool isPlayer;
  final AnimationController attackController;
  final AnimationController hitController;
  final AnimationController faintController;

  const PokemonSprite({
    Key? key,
    required this.pokemon,
    required this.isPlayer,
    required this.attackController,
    required this.hitController,
    required this.faintController,
  }) : super(key: key);

  @override
  _PokemonSpriteState createState() => _PokemonSpriteState();
}

class _PokemonSpriteState extends State<PokemonSprite>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;
  late Animation<Offset> _attackAnimation;
  late Animation<double> _hitAnimation;
  late Animation<double> _faintAnimation;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
        duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
    _idleAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
        CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

    _attackAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.isPlayer ? const Offset(50, -20) : const Offset(-50, 20),
    ).animate(CurvedAnimation(
        parent: widget.attackController, curve: Curves.easeInOut));

    _hitAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 5),
    ]).animate(widget.hitController);

    _faintAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: widget.faintController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        widget.attackController,
        widget.hitController,
        widget.faintController
      ]),
      builder: (context, child) {
        final idleOffset = Offset(0, _idleAnimation.value);
        final attackOffset = widget.attackController.status == AnimationStatus.forward ||
                widget.attackController.status == AnimationStatus.reverse
            ? _attackAnimation.value
            : Offset.zero;

        Widget sprite = SvgPicture.asset(
          widget.pokemon.spriteAssetPath,
          width: 120,
          height: 120,
          placeholderBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        return Transform.translate(
          offset: idleOffset + attackOffset,
          child: Transform.translate(
            offset: Offset(0, _faintAnimation.value * 100),
            child: Opacity(
              opacity:
                  _hitAnimation.value > 0 ? 0.2 : 1.0 - _faintAnimation.value,
              child: sprite,
            ),
          ),
        );
      },
    );
  }
}
