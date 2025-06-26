import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../services/color_service.dart';
import '../models/color_harmony.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';


class DrawingPadScreen extends StatefulWidget {
  final List<Color>? initialColors;

  const DrawingPadScreen({
    Key? key,
    this.initialColors,
  }) : super(key: key);

  @override
  State<DrawingPadScreen> createState() => _DrawingPadScreenState();
}

class _DrawingPadScreenState extends State<DrawingPadScreen> {
  final List<DrawnPath> _paths = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  List<Color> _availableColors = [];
  bool _isErasing = false;

  @override
  void initState() {
    super.initState();
    _availableColors = widget.initialColors ?? [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Drawing Pad'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorHarmonyGenerator,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
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
                child: _buildDrawingArea(),
              ),
            ),
          ),
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
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
      child: Row(
        children: [
          // Brush/Eraser toggle
          Container(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.brush,
                    color: !_isErasing ? AppConstants.primaryColor : AppConstants.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isErasing = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.cleaning_services,
                    color: _isErasing ? AppConstants.primaryColor : AppConstants.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isErasing = true;
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Stroke width slider
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brush Size: ${_strokeWidth.round()}px',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  onChanged: (value) {
                    setState(() {
                      _strokeWidth = value;
                    });
                  },
                  activeColor: AppConstants.primaryColor,
                ),
              ],
            ),
          ),
          
          // Current color indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingArea() {
    return GestureDetector(
      onPanStart: (details) {
        if (!_isErasing) {
          setState(() {
            _paths.add(DrawnPath(
              path: Path()..moveTo(details.localPosition.dx, details.localPosition.dy),
              color: _selectedColor,
              strokeWidth: _strokeWidth,
            ));
          });
        }
      },
      onPanUpdate: (details) {
        if (_isErasing) {
          _eraseAtPosition(details.localPosition);
        } else {
          setState(() {
            if (_paths.isNotEmpty) {
              _paths.last.path.lineTo(details.localPosition.dx, details.localPosition.dy);
            }
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: DrawingPainter(_paths),
        ),
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
                'Color Palette',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _showColorHarmonyGenerator,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Generate'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          AnimationLimiter(
            child: Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: AppConstants.paddingSmall,
              children: AnimationConfiguration.toStaggeredList(
                duration: AppConstants.animationMedium,
                childAnimationBuilder: (widget) => ScaleAnimation(
                  child: FadeInAnimation(child: widget),
                ),
                children: _availableColors.map((color) {
                  return CustomColorSwatch.ColorSwatch(
                    color: color,
                    isSelected: _selectedColor == color,
                    showHex: false,
                    showCopyFeedback: false,
                    size: 45,
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _isErasing = false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _eraseAtPosition(Offset position) {
    setState(() {
      _paths.removeWhere((drawnPath) {
        return _isPointNearPath(position, drawnPath);
      });
    });
  }

  bool _isPointNearPath(Offset point, DrawnPath drawnPath) {
    // Simple collision detection - check if point is within stroke width of path
    final pathMetrics = drawnPath.path.computeMetrics();
    for (final metric in pathMetrics) {
      for (double distance = 0; distance < metric.length; distance += 5) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pathPoint = tangent.position;
          final distanceToPoint = (point - pathPoint).distance;
          if (distanceToPoint < drawnPath.strokeWidth + 10) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear your drawing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paths.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _saveDrawing() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Drawing saved! (Feature can be extended to save to gallery)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showColorHarmonyGenerator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildColorHarmonyGenerator(),
    );
  }

  Widget _buildColorHarmonyGenerator() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            const Text(
              'Generate Color Harmony',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.paddingMedium,
                  mainAxisSpacing: AppConstants.paddingMedium,
                  childAspectRatio: 1.5,
                ),
                itemCount: HarmonyType.values.length,
                itemBuilder: (context, index) {
                  final harmonyType = HarmonyType.values[index];
                  final harmony = ColorHarmony.harmonies[index];
                  
                  return GestureDetector(
                    onTap: () {
                      final newColors = ColorService.generateHarmony(
                        _selectedColor,
                        harmonyType,
                      );
                      setState(() {
                        _availableColors = [..._availableColors, ...newColors];
                        // Remove duplicates
                        _availableColors = _availableColors.toSet().toList();
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            harmony.icon,
                            color: AppConstants.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            harmony.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class DrawingPainter extends CustomPainter {
  final List<DrawnPath> paths;

  DrawingPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    for (final drawnPath in paths) {
      final paint = Paint()
        ..color = drawnPath.color
        ..strokeWidth = drawnPath.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(drawnPath.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
