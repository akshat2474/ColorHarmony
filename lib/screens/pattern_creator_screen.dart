import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../utils/constants.dart';

enum PatternType { geometric, organic, grid, radial, spiral }

class PatternCreatorScreen extends StatefulWidget {
  final List<Color>? initialColors;

  const PatternCreatorScreen({
    Key? key,
    this.initialColors,
  }) : super(key: key);

  @override
  State<PatternCreatorScreen> createState() => _PatternCreatorScreenState();
}

class _PatternCreatorScreenState extends State<PatternCreatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  
  List<Color> _selectedColors = [];
  PatternType _selectedPattern = PatternType.geometric;
  double _patternSize = 50.0;
  double _spacing = 10.0;
  double _rotation = 0.0;
  bool _isAnimated = false;
  
  GlobalKey _patternKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedColors = widget.initialColors ?? [
      Colors.blue,
      Colors.white,
      Colors.lightBlue,
    ];
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Pattern Creator'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isAnimated ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAnimation,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePattern,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: _buildPatternCanvas(),
              ),
            ),
          ),
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: PatternType.values.map((type) {
              return _buildPatternTypeButton(type);
            }).toList(),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
        
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size: ${_patternSize.round()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _patternSize,
                      min: 20.0,
                      max: 100.0,
                      onChanged: (value) {
                        setState(() {
                          _patternSize = value;
                        });
                      },
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spacing: ${_spacing.round()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _spacing,
                      min: 0.0,
                      max: 50.0,
                      onChanged: (value) {
                        setState(() {
                          _spacing = value;
                        });
                      },
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rotation: ${(_rotation * 180 / math.pi).round()}°',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _rotation,
                      min: 0.0,
                      max: 2 * math.pi,
                      onChanged: (value) {
                        setState(() {
                          _rotation = value;
                        });
                      },
                      activeColor: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternTypeButton(PatternType type) {
    final isSelected = _selectedPattern == type;
    final icons = {
      PatternType.geometric: Icons.crop_square,
      PatternType.organic: Icons.bubble_chart,
      PatternType.grid: Icons.grid_4x4,
      PatternType.radial: Icons.radio_button_checked,
      PatternType.spiral: Icons.refresh,
    };
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPattern = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Column(
          children: [
            Icon(
              icons[type],
              color: isSelected ? Colors.white : AppConstants.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              type.toString().split('.').last,
              style: TextStyle(
                color: isSelected ? Colors.white : AppConstants.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCanvas() {
    return RepaintBoundary(
      key: _patternKey,
      child: AnimatedBuilder(
        animation: _isAnimated ? _rotationAnimation : const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: PatternPainter(
              colors: _selectedColors,
              patternType: _selectedPattern,
              size: _patternSize,
              spacing: _spacing,
              rotation: _rotation + (_isAnimated ? _rotationAnimation.value : 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pattern Colors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _addColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.shuffle, size: 20),
                    onPressed: _shuffleColors,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: _selectedColors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;
              
              return GestureDetector(
                onLongPress: () => _removeColor(index),
                child: CustomColorSwatch.ColorSwatch(
                  color: color,
                  showHex: false,
                  showCopyFeedback: false,
                  size: 45,
                  onTap: () => _editColor(index),
                ),
              );
            }).toList(),
          ),
          if (_selectedColors.length > 1)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Tap to edit • Long press to remove',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimated = !_isAnimated;
    });
    
    if (_isAnimated) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  void _addColor() {
    if (_selectedColors.length < 6) {
      setState(() {
        _selectedColors.add(Colors.primaries[
          math.Random().nextInt(Colors.primaries.length)
        ]);
      });
    }
  }

  void _removeColor(int index) {
    if (_selectedColors.length > 1) {
      setState(() {
        _selectedColors.removeAt(index);
      });
    }
  }

  void _editColor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Color'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: Colors.primaries.length,
            itemBuilder: (context, i) {
              final color = Colors.primaries[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColors[index] = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _shuffleColors() {
    setState(() {
      _selectedColors.shuffle();
    });
  }

  Future<void> _savePattern() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      RenderRepaintBoundary boundary = _patternKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${directory.path}/color_harmony_pattern_$timestamp.png');
      await tempFile.writeAsBytes(pngBytes);

      await Gal.putImage(tempFile.path, album: 'Color Harmony Patterns');
      await tempFile.delete();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pattern saved to Gallery! 🎨'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving pattern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class PatternPainter extends CustomPainter {
  final List<Color> colors;
  final PatternType patternType;
  final double size;
  final double spacing;
  final double rotation;

  PatternPainter({
    required this.colors,
    required this.patternType,
    required this.size,
    required this.spacing,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (colors.isEmpty) return;

    canvas.save();
    canvas.translate(canvasSize.width / 2, canvasSize.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-canvasSize.width / 2, -canvasSize.height / 2);

    switch (patternType) {
      case PatternType.geometric:
        _drawGeometricPattern(canvas, canvasSize);
        break;
      case PatternType.organic:
        _drawOrganicPattern(canvas, canvasSize);
        break;
      case PatternType.grid:
        _drawGridPattern(canvas, canvasSize);
        break;
      case PatternType.radial:
        _drawRadialPattern(canvas, canvasSize);
        break;
      case PatternType.spiral:
        _drawSpiralPattern(canvas, canvasSize);
        break;
    }

    canvas.restore();
  }

  void _drawGeometricPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;
    final step = size + spacing;
    
    for (double x = -step; x < canvasSize.width + step; x += step) {
      for (double y = -step; y < canvasSize.height + step; y += step) {
        final colorIndex = ((x / step).floor() + (y / step).floor()).abs() % colors.length;
        paint.color = colors[colorIndex];
        
        final rect = Rect.fromLTWH(x, y, size, size);
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawOrganicPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;
    final step = size + spacing;
    
    for (double x = -step; x < canvasSize.width + step; x += step) {
      for (double y = -step; y < canvasSize.height + step; y += step) {
        final colorIndex = ((x / step).floor() + (y / step).floor()).abs() % colors.length;
        paint.color = colors[colorIndex];
        
        final center = Offset(x + size / 2, y + size / 2);
        final radius = size / 2 * (0.8 + 0.4 * math.sin(x / 50) * math.cos(y / 50));
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  void _drawGridPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final step = size + spacing;
    
    for (double x = 0; x < canvasSize.width; x += step) {
      for (double y = 0; y < canvasSize.height; y += step) {
        final colorIndex = ((x / step).floor() + (y / step).floor()) % colors.length;
        paint.color = colors[colorIndex];
        
        final rect = Rect.fromLTWH(x, y, size, size);
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawRadialPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final maxRadius = math.max(canvasSize.width, canvasSize.height);
    
    for (double radius = size; radius < maxRadius; radius += size + spacing) {
      final colorIndex = (radius / (size + spacing)).floor() % colors.length;
      paint.color = colors[colorIndex].withOpacity(0.7);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawSpiralPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final maxRadius = math.max(canvasSize.width, canvasSize.height) / 2;
    
    for (double angle = 0; angle < 20 * math.pi; angle += 0.2) {
      final radius = (angle / (2 * math.pi)) * (maxRadius / 10);
      if (radius > maxRadius) break;
      
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      final colorIndex = (angle / (2 * math.pi)).floor() % colors.length;
      paint.color = colors[colorIndex];
      
      canvas.drawCircle(Offset(x, y), size / 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
