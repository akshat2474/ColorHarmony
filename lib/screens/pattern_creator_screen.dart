import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/color_swatch.dart' as custom_color_swatch;
import '../utils/constants.dart';
import '../widgets/brutalist_container.dart';

enum PatternType { geometric, organic, grid, radial }

class PatternCreatorScreen extends StatefulWidget {
  final List<Color>? initialColors;

  const PatternCreatorScreen({
    super.key,
    this.initialColors,
  });

  @override
  State<PatternCreatorScreen> createState() => _PatternCreatorScreenState();
}

class _PatternCreatorScreenState extends State<PatternCreatorScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  List<Color> _selectedColors = [];
  PatternType _selectedPattern = PatternType.radial;
  double _patternScale = 50.0;
  double _patternComplexity = 25.0;
  bool _isAnimated = true;
  
  final GlobalKey _patternKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedColors = widget.initialColors ?? [
      AppConstants.accentCyan,
      AppConstants.accentPink,
      AppConstants.accentAmber,
    ];
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
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
        title: const Text('PATTERN CREATOR'),
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
            child: BrutalistContainer(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              padding: EdgeInsets.zero,
              color: Colors.white,
              child: ClipRect(
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
      decoration: const BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: AppConstants.borderWidth),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: PatternType.values.map((type) {
              return _buildPatternTypeButton(type);
            }).toList(),
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
        
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCALE: ${_patternScale.round()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _BrutalistSlider(
                      value: _patternScale,
                      min: 10.0,
                      max: 100.0,
                      onChanged: (value) {
                        setState(() {
                          _patternScale = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLEXITY: ${_patternComplexity.round()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _BrutalistSlider(
                      value: _patternComplexity,
                      min: 5.0,
                      max: 50.0,
                      onChanged: (value) {
                        setState(() {
                          _patternComplexity = value;
                        });
                      },
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
      PatternType.geometric: Icons.interests,
      PatternType.organic: Icons.water,
      PatternType.grid: Icons.grid_3x3,
      PatternType.radial: Icons.all_out,
    };
    
    final labels = {
      PatternType.geometric: 'MEMPHIS',
      PatternType.organic: 'WAVES',
      PatternType.grid: 'TARTAN',
      PatternType.radial: 'MANDALA',
    };
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPattern = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isSelected ? null : const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icons[type],
              color: isSelected ? Colors.white : Colors.black,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              labels[type]!,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
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
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: PatternPainter(
              colors: _selectedColors,
              patternType: _selectedPattern,
              scale: _patternScale,
              complexity: _patternComplexity,
              animationValue: _isAnimated ? _animationController.value : 0.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PALETTE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppConstants.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, size: 24, color: Colors.black),
                    onPressed: _addColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.shuffle, size: 24, color: Colors.black),
                    onPressed: _shuffleColors,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Wrap(
            spacing: AppConstants.paddingMedium,
            runSpacing: AppConstants.paddingMedium,
            children: _selectedColors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;
              
              return GestureDetector(
                onLongPress: () => _removeColor(index),
                child: custom_color_swatch.ColorSwatch(
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
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
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
    if (_selectedColors.length < 8) {
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
        title: const Text('Edit Color', style: TextStyle(fontWeight: FontWeight.w900)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 3),
        ),
        backgroundColor: AppConstants.backgroundColor,
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
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black)),
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

      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pattern saved to Gallery! 🎨'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving pattern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Custom Brutalist Slider
class _BrutalistSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _BrutalistSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localDx = details.localPosition.dx;
        final percentage = (localDx / box.size.width).clamp(0.0, 1.0);
        onChanged(min + (max - min) * percentage);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localDx = details.localPosition.dx;
        final percentage = (localDx / box.size.width).clamp(0.0, 1.0);
        onChanged(min + (max - min) * percentage);
      },
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: constraints.maxWidth * percentage,
                color: AppConstants.primaryColor,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class PatternPainter extends CustomPainter {
  final List<Color> colors;
  final PatternType patternType;
  final double scale;      
  final double complexity;   
  final double animationValue; 

  PatternPainter({
    required this.colors,
    required this.patternType,
    required this.scale,
    required this.complexity,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (colors.isEmpty) return;

    // Background color is always the surface cream color for neo-brutalism
    canvas.drawRect(
      Offset.zero & canvasSize, 
      Paint()..color = const Color(0xFFF3F2EF)
    );
    canvas.clipRect(Offset.zero & canvasSize);

    switch (patternType) {
      case PatternType.geometric:
        _drawMemphis(canvas, canvasSize);
        break;
      case PatternType.organic:
        _drawOrganicWaves(canvas, canvasSize);
        break;
      case PatternType.grid:
        _drawTartanGrid(canvas, canvasSize);
        break;
      case PatternType.radial:
        _drawSpirograph(canvas, canvasSize);
        break;
    }
  }

  void _drawMemphis(Canvas canvas, Size canvasSize) {
    final rand = math.Random(42); 
    final numShapes = (complexity * 2).clamp(10, 100).toInt();
    final baseScale = scale / 20; 

    for (int i = 0; i < numShapes; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final outlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      final shapeType = rand.nextInt(4); 
      
      final driftX = math.sin(animationValue * 2 * math.pi + i) * 20 * baseScale;
      final driftY = math.cos(animationValue * 2 * math.pi + i) * 20 * baseScale;

      final x = (rand.nextDouble() * canvasSize.width) + driftX;
      final y = (rand.nextDouble() * canvasSize.height) + driftY;
      final shapeSize = (20 + rand.nextDouble() * 60) * baseScale;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(animationValue * 2 * math.pi * (i % 2 == 0 ? 1 : -1) + rand.nextDouble() * math.pi);

      switch (shapeType) {
        case 0:
          canvas.drawCircle(Offset.zero, shapeSize / 2, paint);
          canvas.drawCircle(Offset.zero, shapeSize / 2, outlinePaint);
          break;
        case 1:
          final path = Path()
            ..moveTo(0, -shapeSize / 2)
            ..lineTo(shapeSize / 2, shapeSize / 2)
            ..lineTo(-shapeSize / 2, shapeSize / 2)
            ..close();
          canvas.drawPath(path, paint);
          canvas.drawPath(path, outlinePaint);
          break;
        case 2:
          final zigPaint = Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.square
            ..strokeWidth = 8 * baseScale;
          final path = Path()..moveTo(-shapeSize / 2, -shapeSize / 2);
          for(int j=1; j<=4; j++) {
             path.lineTo(-shapeSize / 2 + (shapeSize / 4) * j, j % 2 == 0 ? -shapeSize / 2 : shapeSize / 2);
          }
          canvas.drawPath(path, zigPaint);
          break;
        case 3:
          final rect = Rect.fromCenter(center: Offset.zero, width: shapeSize, height: shapeSize);
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, outlinePaint);
          break;
      }
      canvas.restore();
    }
  }

  void _drawOrganicWaves(Canvas canvas, Size canvasSize) {
    final waveCount = (complexity / 4).clamp(3, 12).toInt();
    final baseAmplitude = scale * 1.5;
    
    for (int i = 0; i < waveCount; i++) {
      final color = colors[i % colors.length];
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
        
      final outlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
        
      final path = Path();
      path.moveTo(0, canvasSize.height);
      
      final yOffset = canvasSize.height * (i / (waveCount - 1));
      
      for (double x = 0; x <= canvasSize.width + 10; x += 10) {
        final phase = animationValue * 2 * math.pi + (i * math.pi / 3);
        final freq = 0.003 + (i * 0.001);
        final y = yOffset - baseAmplitude + math.sin(x * freq + phase) * baseAmplitude + math.cos(x * freq * 0.5 - phase) * (baseAmplitude / 2);
        if (x == 0) {
          path.lineTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.lineTo(canvasSize.width + 10, canvasSize.height);
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.drawPath(path, outlinePaint);
    }
  }

  void _drawTartanGrid(Canvas canvas, Size canvasSize) {
    final bandCount = (complexity / 2).clamp(5, 25).toInt();
    final maxThickness = scale;
    
    final offsetAnim = animationValue * 200;
    
    for (int dir = 0; dir < 2; dir++) {
      for (int i = 0; i < bandCount; i++) {
        final color = colors[i % colors.length].withValues(alpha: 0.85);
        final paint = Paint()..color = color..style = PaintingStyle.fill;
        final outline = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
        
        final thickness = 10 + (i % 3) * (maxThickness / 3);
        final step = (canvasSize.width / bandCount);
        
        final position = ((i * step) + (dir == 0 ? offsetAnim : -offsetAnim)) % (canvasSize.width + 100) - 50;
        
        if (dir == 0) {
          // Vertical
          final rect = Rect.fromLTWH(position, -50, thickness, canvasSize.height + 100);
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, outline);
        } else {
          // Horizontal
          final rect = Rect.fromLTWH(-50, position, canvasSize.width + 100, thickness);
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, outline);
        }
      }
    }
  }

  void _drawSpirograph(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final R = scale * 2 + 30; // Outer radius
    final r = complexity + 10; // Inner radius
    final p = 40.0; // Pen offset
    
    final numPoints = 800;
    
    for(int layer = 0; layer < colors.length; layer++) {
       final path = Path();
       final paint = Paint()
        ..color = colors[layer]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
        
       final outlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;
       
       // Add continuous rotation
       final rotOffset = animationValue * 2 * math.pi * (layer % 2 == 0 ? 1 : -1) + (layer * math.pi / colors.length);
       
       final layerR = R - (layer * 15);
       final layer_r = r + (layer * 8);
       
       if (layerR <= layer_r) continue; // Prevent broken math
       
       for (int i = 0; i <= numPoints; i++) {
         final t = (i / numPoints) * 20 * math.pi; // Revolutions
         
         final x = (layerR - layer_r) * math.cos(t + rotOffset) + p * math.cos(((layerR - layer_r) / layer_r) * t + rotOffset);
         final y = (layerR - layer_r) * math.sin(t + rotOffset) - p * math.sin(((layerR - layer_r) / layer_r) * t + rotOffset);
         
         if (i == 0) {
           path.moveTo(center.dx + x, center.dy + y);
         } else {
           path.lineTo(center.dx + x, center.dy + y);
         }
       }
       
       canvas.drawPath(path, outlinePaint);
       canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.scale != scale ||
           oldDelegate.complexity != complexity ||
           oldDelegate.patternType != patternType ||
           oldDelegate.colors != colors;
  }
}
