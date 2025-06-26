import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

enum FightingPhase { selection, drawing, ready, fighting, finished }
enum FighterSide { left, right }
enum PresetFighter { ninja, warrior, robot, dragon, wizard, archer }

class AnimatedFightingScreen extends StatefulWidget {
  final List<Color>? initialColors;

  const AnimatedFightingScreen({
    Key? key,
    this.initialColors,
  }) : super(key: key);

  @override
  State<AnimatedFightingScreen> createState() => _AnimatedFightingScreenState();
}

class _AnimatedFightingScreenState extends State<AnimatedFightingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fightController;
  late AnimationController _shakeController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  
  late Animation<double> _leftFighterAnimation;
  late Animation<double> _rightFighterAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  FightingPhase _phase = FightingPhase.selection;
  FighterSide _currentDrawing = FighterSide.left;
  
  final List<DrawnPath> _leftFighterPaths = [];
  final List<DrawnPath> _rightFighterPaths = [];
  PresetFighter? _leftPreset;
  PresetFighter? _rightPreset;
  
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  
  double _leftFighterX = 50;
  double _rightFighterX = 300;
  double _leftFighterY = 0;
  double _rightFighterY = 0;
  double _leftHealth = 100;
  double _rightHealth = 100;
  String _fightStatus = '';
  List<Particle> _particles = [];
  List<EnergyWave> _energyWaves = [];
  
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    _selectedColor = widget.initialColors?.first ?? Colors.black;
    
    _fightController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _leftFighterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fightController,
      curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
    ));
    
    _rightFighterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fightController,
      curve: const Interval(0.65, 1.0, curve: Curves.elasticOut),
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 25.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF87CEEB),
      end: const Color(0xFFFF6B6B),
    ).animate(CurvedAnimation(
      parent: _fightController,
      curve: Curves.easeInOut,
    ));
    
    _fightController.addListener(_updateFight);
    _particleController.addListener(_updateParticles);
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _fightController.dispose();
    _shakeController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _updateFight() {
    if (_phase != FightingPhase.fighting) return;
    
    setState(() {
      final progress = _fightController.value;
      
      if (progress < 0.15) {
        _fightStatus = 'Fighters approach...';
        _leftFighterX = 50 + (progress * 6 * 25);
        _rightFighterX = 300 - (progress * 6 * 25);
        _leftFighterY = math.sin(progress * 30) * 5;
        _rightFighterY = math.sin(progress * 30) * 5;
      } else if (progress < 0.35) {
        _fightStatus = 'Left fighter unleashes fury!';
        _leftFighterX = 50 + ((_leftFighterAnimation.value) * 80);
        _leftFighterY = math.sin(_leftFighterAnimation.value * math.pi * 6) * 15;
        
        if (_leftFighterAnimation.value > 0.6) {
          _rightHealth = math.max(0, 100 - ((_leftFighterAnimation.value - 0.6) * 250));
          _createEnhancedImpactParticles(const Offset(250, 200));
          _createEnergyWave(const Offset(250, 200), Colors.blue);
          _shakeController.forward().then((_) => _shakeController.reset());
          _scaleController.forward().then((_) => _scaleController.reset());
        }
      } else if (progress < 0.5) {
        _fightStatus = 'Recovery phase...';
        final resetProgress = (progress - 0.35) / 0.15;
        _leftFighterX = 50 + (80 * (1 - resetProgress));
        _rightFighterX = 300 - (80 * (1 - resetProgress));
        _leftFighterY = math.sin(resetProgress * math.pi) * 10;
        _rightFighterY = math.sin(resetProgress * math.pi) * 10;
      } else if (progress < 0.65) {
        _fightStatus = 'Preparing for counter-attack...';
        final chargeProgress = (progress - 0.5) / 0.15;
        _leftFighterY = math.sin(chargeProgress * math.pi * 8) * 3;
        _rightFighterY = math.sin(chargeProgress * math.pi * 8) * 3;
      } else if (progress < 1.0) {
        _fightStatus = 'Right fighter strikes back!';
        _rightFighterX = 300 - ((_rightFighterAnimation.value) * 80);
        _rightFighterY = math.sin(_rightFighterAnimation.value * math.pi * 6) * 15;
        
        if (_rightFighterAnimation.value > 0.6) {
          _leftHealth = math.max(0, 100 - ((_rightFighterAnimation.value - 0.6) * 250));
          _createEnhancedImpactParticles(const Offset(150, 200));
          _createEnergyWave(const Offset(150, 200), Colors.red);
          _shakeController.forward().then((_) => _shakeController.reset());
          _scaleController.forward().then((_) => _scaleController.reset());
        }
      }
      
      if (_fightController.isCompleted) {
        _phase = FightingPhase.finished;
        if (_leftHealth > _rightHealth) {
          _fightStatus = '🏆 Left fighter claims victory!';
        } else if (_rightHealth > _leftHealth) {
          _fightStatus = '🏆 Right fighter emerges triumphant!';
        } else {
          _fightStatus = '🤝 An epic stalemate!';
        }
      }
    });
  }

  void _updateParticles() {
    setState(() {
      _particles = _particles.where((p) => p.life > 0).toList();
      _energyWaves = _energyWaves.where((w) => w.life > 0).toList();
      
      for (var particle in _particles) {
        particle.update();
      }
      
      for (var wave in _energyWaves) {
        wave.update();
      }
    });
  }

  void _createEnhancedImpactParticles(Offset position) {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        position: position + Offset(
          (math.Random().nextDouble() - 0.5) * 20,
          (math.Random().nextDouble() - 0.5) * 20,
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 300,
          (math.Random().nextDouble() - 0.5) * 300,
        ),
        color: [Colors.yellow, Colors.orange, Colors.red, Colors.white][math.Random().nextInt(4)],
        life: 1.0,
        size: 2.0 + math.Random().nextDouble() * 6,
      ));
    }
    
    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(
        position: position,
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 150,
          -math.Random().nextDouble() * 200 - 50,
        ),
        color: Colors.white,
        life: 1.5,
        size: 8.0 + math.Random().nextDouble() * 4,
      ));
    }
    
    _particleController.reset();
    _particleController.forward();
  }

  void _createEnergyWave(Offset position, Color color) {
    _energyWaves.add(EnergyWave(
      position: position,
      color: color,
      life: 1.0,
      radius: 0.0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _phase == FightingPhase.fighting ? _pulseAnimation.value : 1.0,
              child: const Text('Epic Fighting Arena'),
            );
          },
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_phase == FightingPhase.drawing)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearCurrentFighter,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPhaseIndicator(),
          _buildHealthBars(),
          Expanded(
            child: _buildFightingArena(),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: _phase == FightingPhase.fighting 
            ? Colors.red.withOpacity(0.1) 
            : AppConstants.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _phase == FightingPhase.fighting ? Colors.red : AppConstants.textPrimary,
            ),
            child: Text(_getPhaseTitle()),
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseSubtitle(),
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_phase == FightingPhase.fighting || _phase == FightingPhase.finished)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _phase == FightingPhase.fighting ? _pulseAnimation.value : 1.0,
                    child: Text(
                      _fightStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _phase == FightingPhase.finished ? Colors.green : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthBars() {
    if (_phase == FightingPhase.selection || _phase == FightingPhase.drawing || _phase == FightingPhase.ready) {
      return const SizedBox.shrink();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _leftHealth < 50 ? _scaleAnimation.value : 1.0,
                          child: Icon(
                            _getPresetIcon(_leftPreset),
                            size: 16,
                            color: _getHealthColor(_leftHealth),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Left Fighter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getHealthColor(_leftHealth),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: LinearProgressIndicator(
                    value: _leftHealth / 100,
                    backgroundColor: Colors.red[100],
                    valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(_leftHealth)),
                  ),
                ),
                Text(
                  '${_leftHealth.round()}/100 HP',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingLarge),
          
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _phase == FightingPhase.fighting ? _rotationAnimation.value : 0,
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: AppConstants.paddingLarge),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Right Fighter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getHealthColor(_rightHealth),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _rightHealth < 50 ? _scaleAnimation.value : 1.0,
                          child: Icon(
                            _getPresetIcon(_rightPreset),
                            size: 16,
                            color: _getHealthColor(_rightHealth),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: LinearProgressIndicator(
                    value: _rightHealth / 100,
                    backgroundColor: Colors.red[100],
                    valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(_rightHealth)),
                  ),
                ),
                Text(
                  '${_rightHealth.round()}/100 HP',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFightingArena() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _phase == FightingPhase.fighting
              ? [_backgroundAnimation.value ?? const Color(0xFF87CEEB), const Color(0xFF98FB98)]
              : [const Color(0xFF87CEEB), const Color(0xFF98FB98)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_phase == FightingPhase.fighting ? 0.2 : 0.1),
            blurRadius: _phase == FightingPhase.fighting ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: _buildCanvas(),
      ),
    );
  }

  Widget _buildCanvas() {
    return RepaintBoundary(
      key: _canvasKey,
      child: GestureDetector(
        onPanStart: _phase == FightingPhase.drawing ? _onPanStart : null,
        onPanUpdate: _phase == FightingPhase.drawing ? _onPanUpdate : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _fightController, 
            _shakeAnimation, 
            _particleAnimation,
            _pulseAnimation,
            _scaleAnimation,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shakeAnimation.value * (math.Random().nextDouble() - 0.5),
                _shakeAnimation.value * (math.Random().nextDouble() - 0.5),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: EnhancedFightingCanvasPainter(
                    leftFighterPaths: _leftFighterPaths,
                    rightFighterPaths: _rightFighterPaths,
                    leftPreset: _leftPreset,
                    rightPreset: _rightPreset,
                    leftFighterX: _leftFighterX,
                    rightFighterX: _rightFighterX,
                    leftFighterY: _leftFighterY,
                    rightFighterY: _rightFighterY,
                    phase: _phase,
                    currentDrawing: _currentDrawing,
                    fightProgress: _fightController.value,
                    particles: _particles,
                    energyWaves: _energyWaves,
                    pulseValue: _pulseAnimation.value,
                    scaleValue: _scaleAnimation.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_phase == FightingPhase.selection) ...[
            _buildPresetSelection(),
          ] else if (_phase == FightingPhase.drawing) ...[
            _buildDrawingControls(),
          ],
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getActionButtonCallback(),
              icon: Icon(_getActionButtonIcon()),
              label: Text(_getActionButtonText()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getActionButtonColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                elevation: _phase == FightingPhase.ready ? 8 : 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Fighters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        
        Text(
          'Left Fighter: ${_leftPreset?.toString().split('.').last.toUpperCase() ?? 'None'}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PresetFighter.values.map((preset) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _leftPreset = preset;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _leftPreset == preset 
                      ? AppConstants.primaryColor 
                      : AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _leftPreset == preset 
                        ? AppConstants.primaryColor 
                        : Colors.grey[300]!,
                  ),
                  boxShadow: _leftPreset == preset ? [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _getPresetIcon(preset),
                      color: _leftPreset == preset ? Colors.white : AppConstants.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.toString().split('.').last,
                      style: TextStyle(
                        fontSize: 10,
                        color: _leftPreset == preset ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Text(
          'Right Fighter: ${_rightPreset?.toString().split('.').last.toUpperCase() ?? 'None'}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PresetFighter.values.map((preset) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rightPreset = preset;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _rightPreset == preset 
                      ? Colors.red 
                      : AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _rightPreset == preset 
                        ? Colors.red 
                        : Colors.grey[300]!,
                  ),
                  boxShadow: _rightPreset == preset ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _getPresetIcon(preset),
                      color: _rightPreset == preset ? Colors.white : AppConstants.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.toString().split('.').last,
                      style: TextStyle(
                        fontSize: 10,
                        color: _rightPreset == preset ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrawingControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentDrawing = FighterSide.left;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentDrawing == FighterSide.left
                        ? AppConstants.primaryColor
                        : Colors.grey[300],
                    foregroundColor: _currentDrawing == FighterSide.left
                        ? Colors.white
                        : Colors.black,
                    elevation: _currentDrawing == FighterSide.left ? 6 : 2,
                  ),
                  child: const Text('Draw Left Fighter'),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentDrawing = FighterSide.right;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentDrawing == FighterSide.right
                        ? AppConstants.primaryColor
                        : Colors.grey[300],
                    foregroundColor: _currentDrawing == FighterSide.right
                        ? Colors.white
                        : Colors.black,
                    elevation: _currentDrawing == FighterSide.right ? 6 : 2,
                  ),
                  child: const Text('Draw Right Fighter'),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Row(
          children: [
            Wrap(
              spacing: 8,
              children: (widget.initialColors ?? [
                Colors.black, Colors.red, Colors.blue, Colors.green
              ]).map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? AppConstants.primaryColor
                            : Colors.grey,
                        width: _selectedColor == color ? 3 : 1,
                      ),
                      boxShadow: _selectedColor == color ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const Spacer(),
            
            Text('Size: ${_strokeWidth.round()}'),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: Slider(
                value: _strokeWidth,
                min: 1.0,
                max: 10.0,
                onChanged: (value) {
                  setState(() {
                    _strokeWidth = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getPresetIcon(PresetFighter? preset) {
    switch (preset) {
      case PresetFighter.ninja:
        return Icons.person;
      case PresetFighter.warrior:
        return Icons.shield;
      case PresetFighter.robot:
        return Icons.smart_toy;
      case PresetFighter.dragon:
        return Icons.pets;
      case PresetFighter.wizard:
        return Icons.auto_fix_high;
      case PresetFighter.archer:
        return Icons.sports_cricket;
      default:
        return Icons.help;
    }
  }

  Color _getHealthColor(double health) {
    if (health > 60) return Colors.green;
    if (health > 30) return Colors.orange;
    return Colors.red;
  }

  void _onPanStart(DragStartDetails details) {
    final currentPaths = _currentDrawing == FighterSide.left
        ? _leftFighterPaths
        : _rightFighterPaths;
    
    currentPaths.add(DrawnPath(
      path: Path()..moveTo(details.localPosition.dx, details.localPosition.dy),
      color: _selectedColor,
      strokeWidth: _strokeWidth,
    ));
    
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final currentPaths = _currentDrawing == FighterSide.left
        ? _leftFighterPaths
        : _rightFighterPaths;
    
    if (currentPaths.isNotEmpty) {
      currentPaths.last.path.lineTo(
        details.localPosition.dx,
        details.localPosition.dy,
      );
      setState(() {});
    }
  }

  void _clearCurrentFighter() {
    setState(() {
      if (_currentDrawing == FighterSide.left) {
        _leftFighterPaths.clear();
      } else {
        _rightFighterPaths.clear();
      }
    });
  }

  void _startFight() {
    if ((_leftFighterPaths.isEmpty && _leftPreset == null) || 
        (_rightFighterPaths.isEmpty && _rightPreset == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose or draw both fighters first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _phase = FightingPhase.fighting;
      _leftHealth = 100;
      _rightHealth = 100;
      _fightStatus = 'Epic battle begins!';
      _particles.clear();
      _energyWaves.clear();
    });
    
    _fightController.forward();
  }

  void _resetFight() {
    setState(() {
      _phase = FightingPhase.selection;
      _currentDrawing = FighterSide.left;
      _leftFighterPaths.clear();
      _rightFighterPaths.clear();
      _leftPreset = null;
      _rightPreset = null;
      _leftFighterX = 50;
      _rightFighterX = 300;
      _leftFighterY = 0;
      _rightFighterY = 0;
      _leftHealth = 100;
      _rightHealth = 100;
      _fightStatus = '';
      _particles.clear();
      _energyWaves.clear();
    });
    
    _fightController.reset();
  }

  String _getPhaseTitle() {
    switch (_phase) {
      case FightingPhase.selection:
        return 'Choose Your Fighters';
      case FightingPhase.drawing:
        return 'Customize Your Fighters';
      case FightingPhase.ready:
        return 'Ready for Epic Battle!';
      case FightingPhase.fighting:
        return 'EPIC BATTLE IN PROGRESS!';
      case FightingPhase.finished:
        return 'Battle Complete!';
    }
  }

  String _getPhaseSubtitle() {
    switch (_phase) {
      case FightingPhase.selection:
        return 'Select preset fighters or choose "Custom" to draw your own';
      case FightingPhase.drawing:
        return 'Draw custom details for your fighters. Currently drawing: ${_currentDrawing == FighterSide.left ? "Left" : "Right"} fighter';
      case FightingPhase.ready:
        return 'Both fighters are ready. Press fight to begin the epic battle!';
      case FightingPhase.fighting:
        return 'Watch your fighters battle with enhanced animations and effects!';
      case FightingPhase.finished:
        return 'The epic battle is over. Choose new fighters or fight again!';
    }
  }

  VoidCallback? _getActionButtonCallback() {
    switch (_phase) {
      case FightingPhase.selection:
        return (_leftPreset != null || _leftFighterPaths.isNotEmpty) && 
               (_rightPreset != null || _rightFighterPaths.isNotEmpty)
            ? () {
                setState(() {
                  _phase = FightingPhase.ready;
                });
              }
            : () {
                setState(() {
                  _phase = FightingPhase.drawing;
                });
              };
      case FightingPhase.drawing:
        return () {
          setState(() {
            _phase = FightingPhase.ready;
          });
        };
      case FightingPhase.ready:
        return _startFight;
      case FightingPhase.fighting:
        return null;
      case FightingPhase.finished:
        return _resetFight;
    }
  }

  IconData _getActionButtonIcon() {
    switch (_phase) {
      case FightingPhase.selection:
        return (_leftPreset != null || _leftFighterPaths.isNotEmpty) && 
               (_rightPreset != null || _rightFighterPaths.isNotEmpty)
            ? Icons.check
            : Icons.draw;
      case FightingPhase.drawing:
        return Icons.check;
      case FightingPhase.ready:
        return Icons.sports_mma;
      case FightingPhase.fighting:
        return Icons.hourglass_empty;
      case FightingPhase.finished:
        return Icons.refresh;
    }
  }

  String _getActionButtonText() {
    switch (_phase) {
      case FightingPhase.selection:
        return (_leftPreset != null || _leftFighterPaths.isNotEmpty) && 
               (_rightPreset != null || _rightFighterPaths.isNotEmpty)
            ? 'Ready to Fight'
            : 'Draw Custom Fighters';
      case FightingPhase.drawing:
        return 'Finish Drawing';
      case FightingPhase.ready:
        return 'START EPIC BATTLE!';
      case FightingPhase.fighting:
        return 'Fighting...';
      case FightingPhase.finished:
        return 'New Battle';
    }
  }

  Color _getActionButtonColor() {
    switch (_phase) {
      case FightingPhase.selection:
        return AppConstants.primaryColor;
      case FightingPhase.drawing:
        return AppConstants.primaryColor;
      case FightingPhase.ready:
        return Colors.red;
      case FightingPhase.fighting:
        return Colors.grey;
      case FightingPhase.finished:
        return Colors.green;
    }
  }
}

class DrawnPath {
  final Path path;
  final Color color;
  final double strokeWidth;

  DrawnPath({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  double size;
  double gravity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
    this.size = 4.0,
    this.gravity = 0.5,
  });

  void update() {
    position += velocity * 0.016;
    velocity = Offset(velocity.dx * 0.98, velocity.dy + gravity);
    life -= 0.015;
    size *= 0.995;
  }
}

class EnergyWave {
  Offset position;
  Color color;
  double life;
  double radius;

  EnergyWave({
    required this.position,
    required this.color,
    required this.life,
    required this.radius,
  });

  void update() {
    radius += 3.0;
    life -= 0.03;
  }
}

class EnhancedFightingCanvasPainter extends CustomPainter {
  final List<DrawnPath> leftFighterPaths;
  final List<DrawnPath> rightFighterPaths;
  final PresetFighter? leftPreset;
  final PresetFighter? rightPreset;
  final double leftFighterX;
  final double rightFighterX;
  final double leftFighterY;
  final double rightFighterY;
  final FightingPhase phase;
  final FighterSide currentDrawing;
  final double fightProgress;
  final List<Particle> particles;
  final List<EnergyWave> energyWaves;
  final double pulseValue;
  final double scaleValue;

  EnhancedFightingCanvasPainter({
    required this.leftFighterPaths,
    required this.rightFighterPaths,
    required this.leftPreset,
    required this.rightPreset,
    required this.leftFighterX,
    required this.rightFighterX,
    required this.leftFighterY,
    required this.rightFighterY,
    required this.phase,
    required this.currentDrawing,
    required this.fightProgress,
    required this.particles,
    required this.energyWaves,
    required this.pulseValue,
    required this.scaleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawArenaBackground(canvas, size);
    _drawCenterLine(canvas, size);
    
    if (phase == FightingPhase.drawing) {
      _drawFighterZones(canvas, size);
    }
    
    _drawEnergyWaves(canvas);
    _drawFighter(canvas, size, true);
    _drawFighter(canvas, size, false);
    _drawParticles(canvas);
    
    if (phase == FightingPhase.fighting) {
      _drawFightingEffects(canvas, size);
    }
  }

  void _drawArenaBackground(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..color = Colors.brown[300]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      groundPaint,
    );
    
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * 0.1;
      _drawCloud(canvas, Offset(x, y), cloudPaint);
    }
    
    if (phase == FightingPhase.fighting) {
      final lightningPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < 5; i++) {
        final x = math.Random().nextDouble() * size.width;
        final y = math.Random().nextDouble() * size.height * 0.3;
        _drawLightning(canvas, Offset(x, y), lightningPaint);
      }
    }
  }

  void _drawCloud(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 20, paint);
    canvas.drawCircle(center + const Offset(-15, 5), 15, paint);
    canvas.drawCircle(center + const Offset(15, 5), 15, paint);
    canvas.drawCircle(center + const Offset(0, -10), 18, paint);
  }

  void _drawLightning(Canvas canvas, Offset start, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    for (int i = 0; i < 3; i++) {
      final x = start.dx + (math.Random().nextDouble() - 0.5) * 30;
      final y = start.dy + (i + 1) * 20;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawCenterLine(Canvas canvas, Size size) {
    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(phase == FightingPhase.fighting ? 0.8 : 0.5)
      ..strokeWidth = phase == FightingPhase.fighting ? 3 : 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerLinePaint,
    );
  }

  void _drawFighterZones(Canvas canvas, Size size) {
    final zonePaint = Paint()
      ..color = (currentDrawing == FighterSide.left
          ? Colors.blue
          : Colors.red).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    if (currentDrawing == FighterSide.left) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width / 2 - 10, size.height),
        zonePaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(size.width / 2 + 10, 0, size.width / 2 - 10, size.height),
        zonePaint,
      );
    }
  }

  void _drawFighter(Canvas canvas, Size size, bool isLeft) {
    canvas.save();
    
    final fighterX = isLeft ? leftFighterX : rightFighterX;
    final fighterY = isLeft ? leftFighterY : rightFighterY;
    final preset = isLeft ? leftPreset : rightPreset;
    final paths = isLeft ? leftFighterPaths : rightFighterPaths;
    
    canvas.translate(fighterX, fighterY);
    
    if (phase == FightingPhase.fighting) {
      final rotation = math.sin(fightProgress * 25) * 0.15;
      final scale = 1.0 + math.sin(fightProgress * 30) * 0.1;
      
      canvas.translate(25, size.height * 0.3);
      canvas.rotate(rotation * (isLeft ? 1 : -1));
      canvas.scale(scale);
      canvas.translate(-25, -size.height * 0.3);
    }
    
    if (preset != null) {
      _drawPresetFighter(canvas, size, preset, isLeft);
    } else {
      for (final path in paths) {
        final paint = Paint()
          ..color = path.color
          ..strokeWidth = path.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path.path, paint);
      }
    }
    
    canvas.restore();
  }

  void _drawPresetFighter(Canvas canvas, Size size, PresetFighter preset, bool isLeft) {
    final paint = Paint()
      ..color = isLeft ? Colors.blue : Colors.red
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    const centerX = 50.0;
    final centerY = size.height * 0.6;
    
    final glowPaint = Paint()
      ..color = (isLeft ? Colors.blue : Colors.red).withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    switch (preset) {
      case PresetFighter.ninja:
        _drawNinja(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
      case PresetFighter.warrior:
        _drawWarrior(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
      case PresetFighter.robot:
        _drawRobot(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
      case PresetFighter.dragon:
        _drawDragon(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
      case PresetFighter.wizard:
        _drawWizard(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
      case PresetFighter.archer:
        _drawArcher(canvas, Offset(centerX, centerY), paint, strokePaint, glowPaint);
        break;
    }
  }

  void _drawNinja(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    if (phase == FightingPhase.fighting) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 25, height: 45),
        glowPaint,
      );
    }
    
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 20, height: 40),
      fillPaint,
    );
    
    canvas.drawCircle(center - const Offset(0, 30), 12, fillPaint);
    
    canvas.drawRect(
      Rect.fromCenter(center: center - const Offset(0, 10), width: 40, height: 8),
      fillPaint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(-8, 25), width: 8, height: 20),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(8, 25), width: 8, height: 20),
      fillPaint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(center: center - const Offset(0, 30), width: 20, height: 8),
      Paint()..color = Colors.black,
    );
    
    if (phase == FightingPhase.fighting) {
      final swordPaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 3;
      canvas.drawLine(
        center + const Offset(20, -20),
        center + const Offset(35, -35),
        swordPaint,
      );
    }
  }

  void _drawWarrior(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    if (phase == FightingPhase.fighting) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 30, height: 50),
        glowPaint,
      );
    }
    
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 25, height: 45),
      fillPaint,
    );
    
    canvas.drawCircle(center - const Offset(0, 35), 15, fillPaint);
    
    canvas.drawOval(
      Rect.fromCenter(center: center - const Offset(20, 5), width: 15, height: 25),
      Paint()..color = Colors.brown,
    );
    
    canvas.drawRect(
      Rect.fromCenter(center: center - const Offset(-25, -10), width: 4, height: 30),
      Paint()..color = Colors.grey,
    );
    
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(-10, 30), width: 10, height: 25),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(10, 30), width: 10, height: 25),
      fillPaint,
    );
  }

  void _drawRobot(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    if (phase == FightingPhase.fighting) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 35, height: 45),
          const Radius.circular(5),
        ),
        glowPaint,
      );
    }
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 30, height: 40),
        const Radius.circular(5),
      ),
      fillPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center - const Offset(0, 30), width: 25, height: 20),
        const Radius.circular(3),
      ),
      fillPaint,
    );
    
    final eyeColor = phase == FightingPhase.fighting ? Colors.yellow : Colors.red;
    canvas.drawCircle(center - const Offset(-5, 30), 3, Paint()..color = eyeColor);
    canvas.drawCircle(center - const Offset(5, 30), 3, Paint()..color = eyeColor);
    
    canvas.drawRect(
      Rect.fromCenter(center: center - const Offset(0, 10), width: 50, height: 10),
      fillPaint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(-8, 30), width: 12, height: 25),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(8, 30), width: 12, height: 25),
      fillPaint,
    );
  }

  void _drawDragon(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    final path = Path();
    path.moveTo(center.dx - 20, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - 20, center.dx + 20, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + 20, center.dx - 20, center.dy + 40);
    
    if (phase == FightingPhase.fighting) {
      canvas.drawPath(path, glowPaint..strokeWidth = 20..style = PaintingStyle.stroke);
    }
    
    canvas.drawPath(path, fillPaint..strokeWidth = 15..style = PaintingStyle.stroke);
    
    canvas.drawOval(
      Rect.fromCenter(center: center - const Offset(0, 35), width: 25, height: 20),
      fillPaint..style = PaintingStyle.fill,
    );
    
    final wingPath = Path();
    wingPath.moveTo(center.dx - 30, center.dy - 10);
    wingPath.lineTo(center.dx - 50, center.dy - 30);
    wingPath.lineTo(center.dx - 20, center.dy + 10);
    wingPath.close();
    
    canvas.drawPath(wingPath, Paint()..color = Colors.orange);
    
    canvas.save();
    canvas.scale(-1, 1);
    canvas.translate(-center.dx * 2, 0);
    canvas.drawPath(wingPath, Paint()..color = Colors.orange);
    canvas.restore();
    
    if (phase == FightingPhase.fighting) {
      final firePaint = Paint()
        ..color = Colors.orange.withOpacity(0.7)
        ..strokeWidth = 3;
      canvas.drawLine(
        center + const Offset(25, -35),
        center + const Offset(40, -40),
        firePaint,
      );
    }
  }

  void _drawWizard(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    final robePath = Path();
    robePath.moveTo(center.dx - 20, center.dy + 40);
    robePath.lineTo(center.dx - 15, center.dy - 10);
    robePath.lineTo(center.dx + 15, center.dy - 10);
    robePath.lineTo(center.dx + 20, center.dy + 40);
    robePath.close();
    
    if (phase == FightingPhase.fighting) {
      canvas.drawPath(robePath, glowPaint);
    }
    
    canvas.drawPath(robePath, Paint()..color = Colors.purple);
    
    canvas.drawCircle(center - const Offset(0, 30), 12, fillPaint);
    
    final hatPath = Path();
    hatPath.moveTo(center.dx - 15, center.dy - 40);
    hatPath.lineTo(center.dx - 5, center.dy - 60);
    hatPath.lineTo(center.dx + 15, center.dy - 40);
    hatPath.close();
    
    canvas.drawPath(hatPath, Paint()..color = Colors.indigo);
    
    canvas.drawLine(
      center + const Offset(25, -20),
      center + const Offset(25, 40),
      Paint()..color = Colors.brown..strokeWidth = 4,
    );
    
    _drawStar(canvas, center + const Offset(25, -25), 8, Paint()..color = Colors.yellow);
    
    if (phase == FightingPhase.fighting) {
      final magicPaint = Paint()
        ..color = Colors.purple.withOpacity(0.5)
        ..strokeWidth = 2;
      
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          center + const Offset(25, -25) + Offset(i * 10.0, 0),
          5 + i * 2.0,
          magicPaint,
        );
      }
    }
  }

  void _drawArcher(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint, Paint glowPaint) {
    if (phase == FightingPhase.fighting) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 25, height: 45),
        glowPaint,
      );
    }
    
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 20, height: 40),
      fillPaint,
    );
    
    canvas.drawCircle(center - const Offset(0, 30), 12, fillPaint);
    
    final bowPath = Path();
    bowPath.moveTo(center.dx - 30, center.dy - 20);
    bowPath.quadraticBezierTo(center.dx - 35, center.dy, center.dx - 30, center.dy + 20);
    
    canvas.drawPath(bowPath, Paint()..color = Colors.brown..strokeWidth = 3..style = PaintingStyle.stroke);
    
    canvas.drawLine(
      center + const Offset(-30, 0),
      center + const Offset(-10, 0),
      Paint()..color = Colors.brown..strokeWidth = 2,
    );
    
    final arrowTip = Path();
    arrowTip.moveTo(center.dx - 10, center.dy);
    arrowTip.lineTo(center.dx - 5, center.dy - 3);
    arrowTip.lineTo(center.dx - 5, center.dy + 3);
    arrowTip.close();
    
    canvas.drawPath(arrowTip, Paint()..color = Colors.grey);
    
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(-8, 25), width: 8, height: 20),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center + const Offset(8, 25), width: 8, height: 20),
      fillPaint,    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      final innerAngle = ((i + 0.5) * 2 * math.pi / 5) - math.pi / 2;
      final innerX = center.dx + (radius * 0.4) * math.cos(innerAngle);
      final innerY = center.dy + (radius * 0.4) * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      if (particle.life > 0) {
        final paint = Paint()
          ..color = particle.color.withOpacity(particle.life)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(particle.position, particle.size, paint);
      }
    }
  }

  void _drawEnergyWaves(Canvas canvas) {
    for (final wave in energyWaves) {
      if (wave.life > 0) {
        final paint = Paint()
          ..color = wave.color.withOpacity(wave.life * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        
        canvas.drawCircle(wave.position, wave.radius, paint);
        
        final innerPaint = Paint()
          ..color = wave.color.withOpacity(wave.life * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        canvas.drawCircle(wave.position, wave.radius * 0.7, innerPaint);
      }
    }
  }

  void _drawFightingEffects(Canvas canvas, Size size) {
    if (fightProgress > 0.15 && fightProgress < 0.5) {
      final attackIntensity = math.sin(fightProgress * 50) * 0.5 + 0.5;
      
      final energyPaint = Paint()
        ..color = Colors.blue.withOpacity(attackIntensity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(leftFighterX + 40, size.height * 0.6),
          20.0 + (i * 12) + (attackIntensity * 10),
          energyPaint,
        );
      }
      
      final sparkPaint = Paint()
        ..color = Colors.yellow.withOpacity(attackIntensity)
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) + (fightProgress * 20);
        final sparkX = leftFighterX + 40 + math.cos(angle) * 30;
        final sparkY = size.height * 0.6 + math.sin(angle) * 30;
        canvas.drawCircle(Offset(sparkX, sparkY), 3, sparkPaint);
      }
    }
    
    if (fightProgress > 0.65 && fightProgress < 1.0) {
      final attackIntensity = math.sin(fightProgress * 50) * 0.5 + 0.5;
      
      final energyPaint = Paint()
        ..color = Colors.red.withOpacity(attackIntensity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(rightFighterX - 40, size.height * 0.6),
          20.0 + (i * 12) + (attackIntensity * 10),
          energyPaint,
        );
      }
      
      final sparkPaint = Paint()
        ..color = Colors.orange.withOpacity(attackIntensity)
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) + (fightProgress * 20);
        final sparkX = rightFighterX - 40 + math.cos(angle) * 30;
        final sparkY = size.height * 0.6 + math.sin(angle) * 30;
        canvas.drawCircle(Offset(sparkX, sparkY), 3, sparkPaint);
      }
    }
    
    if (phase == FightingPhase.fighting) {
      final intensity = math.sin(fightProgress * 30) * 0.3 + 0.7;
      
      final auraPaint = Paint()
        ..color = Colors.white.withOpacity(intensity * 0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        Offset(leftFighterX + 25, size.height * 0.6),
        40 * intensity,
        auraPaint,
      );
      
      canvas.drawCircle(
        Offset(rightFighterX + 25, size.height * 0.6),
        40 * intensity,
        auraPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

