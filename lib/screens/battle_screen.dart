import 'package:flutter/material.dart';
import 'dart:math';
import '../models/pokemon_model.dart';
import '../models/move_model.dart';
import '../utils/pokemon_data.dart';
import '../widgets/pokemon_sprite.dart';
import '../widgets/health_bar.dart';
import '../widgets/battle_dialogue_box.dart';
import '../animations/attack_animation_painter.dart';
import '../widgets/battle_background_painter.dart';

enum BattlePhase { intro, playerTurn, playerAnimating, enemyTurn, enemyAnimating, finished }

class PokemonBattleScreen extends StatefulWidget {
  const PokemonBattleScreen({Key? key}) : super(key: key);

  @override
  _PokemonBattleScreenState createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> with TickerProviderStateMixin {
  late Pokemon _playerPokemon;
  late Pokemon _enemyPokemon;
  late AnimationController _playerAttackCtrl, _playerHitCtrl, _playerFaintCtrl;
  late AnimationController _enemyAttackCtrl, _enemyHitCtrl, _enemyFaintCtrl;
  late AnimationController _moveAnimationCtrl;
  BattlePhase _phase = BattlePhase.intro;
  String _dialogueText = '';
  Move? _currentMove;

  static const double spriteSize = 120.0;
  static const double dialogueBoxHeight = 205.0;

  @override
  void initState() {
    super.initState();
    _playerPokemon = Pokemon.clone(PokemonData.squirtle);
    _enemyPokemon = Pokemon.clone(PokemonData.charmander);
    _playerAttackCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _playerHitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _playerFaintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _enemyAttackCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _enemyHitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _enemyFaintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _moveAnimationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _startBattle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58A0D8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = constraints.biggest;
          final safeArea = MediaQuery.of(context).padding;
          final playerPos = kPlayerPlatformAnchor.alongSize(screenSize);
          final enemyPos = kEnemyPlatformAnchor.alongSize(screenSize);
          final bool isPlayerAttacking = _phase == BattlePhase.playerAnimating;
          final bool isEnemyAttacking = _phase == BattlePhase.enemyAnimating;
          Offset attackStartPos = playerPos;
          Offset attackEndPos = enemyPos;
          if (isEnemyAttacking) {
            attackStartPos = enemyPos;
            attackEndPos = playerPos;
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: BattleBackgroundPainter(),
                ),
              ),
              Positioned(
                top: safeArea.top + 20,
                left: screenSize.width * 0.05,
                child: SizedBox(
                  width: screenSize.width * 0.45,
                  child: HealthBar(pokemon: _enemyPokemon),
                ),
              ),
              Positioned(
                bottom: dialogueBoxHeight + 15,
                right: screenSize.width * 0.05,
                child: SizedBox(
                  width: screenSize.width * 0.45,
                  child: HealthBar(pokemon: _playerPokemon, isPlayer: true),
                ),
              ),
              Positioned(
                top: playerPos.dy - (spriteSize * 0.85),
                left: playerPos.dx - (spriteSize / 2),
                child: PokemonSprite(
                  pokemon: _playerPokemon, 
                  isPlayer: true, 
                  attackController: _playerAttackCtrl, 
                  hitController: _playerHitCtrl, 
                  faintController: _playerFaintCtrl
                ),
              ),
              Positioned(
                top: enemyPos.dy - (spriteSize * 0.85),
                left: enemyPos.dx - (spriteSize / 2),
                child: PokemonSprite(
                  pokemon: _enemyPokemon, 
                  isPlayer: false, 
                  attackController: _enemyAttackCtrl, 
                  hitController: _enemyHitCtrl, 
                  faintController: _enemyFaintCtrl
                ),
              ),
              if (_currentMove != null && (isPlayerAttacking || isEnemyAttacking))
                CustomPaint(
                  size: Size.infinite,
                  painter: AttackAnimationPainter(
                    animation: _moveAnimationCtrl,
                    animationType: _currentMove!.animationType,
                    moveType: _currentMove!.type,
                    // --- FIX: Use the dynamic positions we just calculated ---
                    startPosition: attackStartPos.translate(0, -spriteSize / 2),
                    endPosition: attackEndPos.translate(0, -spriteSize / 2),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0, 
                right: 0,
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: dialogueBoxHeight,
                    child: BattleDialogueBox(
                      text: _dialogueText,
                      moves: _playerPokemon.moves,
                      onMoveSelected: _handleMoveSelection,
                      isDisplayingMoves: _phase == BattlePhase.playerTurn,
                    ),
                  ),
                ),
              ),
              if (_phase == BattlePhase.finished)
                Positioned(
                  bottom: dialogueBoxHeight + 20, 
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _resetBattle, 
                    child: const Icon(Icons.refresh)
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  void _startBattle() {
    setState(() {
      _dialogueText = 'A wild ${_enemyPokemon.name} appeared!';
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _phase = BattlePhase.playerTurn;
        _dialogueText = 'What will ${_playerPokemon.name} do?';
      });
    });
  }

  void _handleMoveSelection(Move move) {
    if (_phase != BattlePhase.playerTurn) return;
    _currentMove = move;

    setState(() {
      _phase = BattlePhase.playerAnimating;
      _dialogueText = '${_playerPokemon.name} used ${move.name}!';
    });

    _playerAttackCtrl.forward(from: 0).whenComplete(() {
      _playerAttackCtrl.reverse();
    });

    _moveAnimationCtrl.forward(from: 0).whenComplete(() {
      _enemyHitCtrl.forward(from: 0);
      setState(() {
        _enemyPokemon.currentHealth =
            max(0, _enemyPokemon.currentHealth - move.power);
      });

      Future.delayed(const Duration(milliseconds: 800), _checkBattleStatus);
    });
  }

  void _enemyTurn() {
    setState(() {
      _phase = BattlePhase.enemyTurn;
    });

    Future.delayed(const Duration(seconds: 1), () {
      final move =
          _enemyPokemon.moves[Random().nextInt(_enemyPokemon.moves.length)];
      _currentMove = move;

      setState(() {
        _phase = BattlePhase.enemyAnimating;
        _dialogueText = 'Enemy ${_enemyPokemon.name} used ${move.name}!';
      });

      _enemyAttackCtrl.forward(from: 0).whenComplete(() {
        _enemyAttackCtrl.reverse();
      });

      // --- The hit logic now happens after the animation completes
      _moveAnimationCtrl.forward(from: 0).whenComplete(() {
        _playerHitCtrl.forward(from: 0);
        setState(() {
          _playerPokemon.currentHealth =
              max(0, _playerPokemon.currentHealth - move.power);
        });
        Future.delayed(const Duration(milliseconds: 800), _checkBattleStatus);
      });
    });
  }
  
  void _checkBattleStatus() {
    if (_enemyPokemon.currentHealth <= 0) {
      _enemyFaintCtrl.forward();
      setState(() {
        _phase = BattlePhase.finished;
        _dialogueText = 'Enemy ${_enemyPokemon.name} fainted! You win!';
      });
    } else if (_playerPokemon.currentHealth <= 0) {
      _playerFaintCtrl.forward();
      setState(() {
        _phase = BattlePhase.finished;
        _dialogueText = '${_playerPokemon.name} fainted! You lose!';
      });
    } else {
      // Logic to switch turns
      if (_phase == BattlePhase.playerAnimating) {
        _enemyTurn();
      } else {
        setState(() {
          _phase = BattlePhase.playerTurn;
          _dialogueText = 'What will ${_playerPokemon.name} do?';
        });
      }
    }
  }

  void _resetBattle() {
    _playerPokemon = Pokemon.clone(PokemonData.squirtle);
    _enemyPokemon = Pokemon.clone(PokemonData.charmander);
    _playerFaintCtrl.reset();
    _enemyFaintCtrl.reset();
    _hitAndAttackControllersReset();
    setState(() {
      _phase = BattlePhase.intro;
    });
    _startBattle();
  }

  void _hitAndAttackControllersReset() {
    _playerAttackCtrl.reset();
    _playerHitCtrl.reset();
    _enemyAttackCtrl.reset();
    _enemyHitCtrl.reset();
    _moveAnimationCtrl.reset();
  }
  
  @override
  void dispose() {
    _playerAttackCtrl.dispose();
    _playerHitCtrl.dispose();
    _playerFaintCtrl.dispose();
    _enemyAttackCtrl.dispose();
    _enemyHitCtrl.dispose();
    _enemyFaintCtrl.dispose();
    _moveAnimationCtrl.dispose();
    super.dispose();
  }
}
