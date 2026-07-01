import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math' as math;
import '../widgets/color_swatch.dart' as custom_color_swatch;
import '../services/color_service.dart';
import '../models/color_harmony.dart';
import '../utils/constants.dart';
import 'package:gal/gal.dart';

enum DrawingTool { brush, eraser, line, rectangle, circle, text, fill }

class DrawingPadScreen extends StatefulWidget {
  final List<Color>? initialColors;

  const DrawingPadScreen({
    super.key,
    this.initialColors,
  });

  @override
  State<DrawingPadScreen> createState() => _DrawingPadScreenState();
}

class _DrawingPadScreenState extends State<DrawingPadScreen> {
  final List<DrawnElement> _elements = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  List<Color> _availableColors = [];
  DrawingTool _selectedTool = DrawingTool.brush;
  
  Offset? _shapeStartPoint;
  Offset? _shapeEndPoint;
  bool _isDrawingShape = false;
  
  String _currentText = '';
  String _selectedFont = 'Roboto';
  double _fontSize = 20.0;
  final TextEditingController _textController = TextEditingController();
  
  DrawnText? _draggingText;
  Offset? _dragStartOffset;
  
  final List<String> _availableFonts = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
    'Comic Sans MS',
    'Impact',
  ];

  final GlobalKey _canvasKey = GlobalKey();

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
      Colors.yellow,
      Colors.cyan,
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRAWING PAD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorHarmonyGenerator,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
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
          if (_selectedTool == DrawingTool.text) _buildTextToolbar(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: Offset(6, 6),
                  ),
                ],
              ),
              child: ClipRect(
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
      decoration: const BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(DrawingTool.brush, Icons.brush, 'Brush'),
              _buildToolButton(DrawingTool.eraser, Icons.cleaning_services, 'Eraser'),
              _buildToolButton(DrawingTool.fill, Icons.format_color_fill, 'Fill'),
              _buildToolButton(DrawingTool.line, Icons.remove, 'Line'),
              _buildToolButton(DrawingTool.rectangle, Icons.crop_square, 'Rectangle'),
              _buildToolButton(DrawingTool.circle, Icons.circle_outlined, 'Circle'),
              _buildToolButton(DrawingTool.text, Icons.text_fields, 'Text'),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Row(
            children: [
              const Text(
                'Size:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Slider(
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
              ),
              Text(
                '${_strokeWidth.round()}px',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    final isSelected = _selectedTool == tool;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTool = tool;
        });
        
        if (tool == DrawingTool.fill) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap on any closed shape to fill it with selected color'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppConstants.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppConstants.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextToolbar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor.withValues(alpha:0.9),
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: _selectedFont,
              isExpanded: true,
              items: _availableFonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                );
              }).toList(),
              onChanged: (font) {
                setState(() {
                  _selectedFont = font!;
                });
              },
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          const Text('Size:'),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Slider(
              value: _fontSize,
              min: 12.0,
              max: 48.0,
              divisions: 18,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
              activeColor: AppConstants.primaryColor,
            ),
          ),
          Text('${_fontSize.round()}'),
          
          const SizedBox(width: AppConstants.paddingMedium),
          ElevatedButton.icon(
            onPressed: _showTextDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Text'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingArea() {
    return RepaintBoundary(
      key: _canvasKey,
      child: GestureDetector(
        onTapDown: (details) {
          if (_selectedTool == DrawingTool.fill) {
            _fillShapeAtPosition(details.localPosition);
          } else if (_selectedTool == DrawingTool.text) {
            bool foundText = false;
            for (final element in _elements.reversed) {
              if (element is DrawnText) {
                final distance = (details.localPosition - element.position).distance;
                if (distance < 50) {
                  foundText = true;
                  break;
                }
              }
            }
            if (!foundText) {
              _addTextAtPosition(details.localPosition);
            }
          }
        },
        onPanStart: (details) {
          if (_selectedTool == DrawingTool.text) {
            for (final element in _elements.reversed) {
              if (element is DrawnText) {
                final distance = (details.localPosition - element.position).distance;
                if (distance < 50) {
                  _draggingText = element;
                  _dragStartOffset = details.localPosition - element.position;
                  break;
                }
              }
            }
          } else if (_selectedTool == DrawingTool.brush || _selectedTool == DrawingTool.eraser) {
            setState(() {
              _elements.add(DrawnPath(
                path: Path()..moveTo(details.localPosition.dx, details.localPosition.dy),
                color: _selectedTool == DrawingTool.eraser ? Colors.white : _selectedColor,
                strokeWidth: _strokeWidth,
              ));
            });
          } else if (_isShapeTool(_selectedTool)) {
            _shapeStartPoint = details.localPosition;
            _isDrawingShape = true;
          }
        },
        onPanUpdate: (details) {
          if (_draggingText != null) {
            setState(() {
              final newPos = details.localPosition - _dragStartOffset!;
              final index = _elements.indexOf(_draggingText!);
              if (index != -1) {
                _elements[index] = DrawnText(
                  position: newPos,
                  text: _draggingText!.text,
                  color: _draggingText!.color,
                  fontSize: _draggingText!.fontSize,
                  fontFamily: _draggingText!.fontFamily,
                );
                _draggingText = _elements[index] as DrawnText;
              }
            });
          } else if (_selectedTool == DrawingTool.brush || _selectedTool == DrawingTool.eraser) {
            setState(() {
              if (_elements.isNotEmpty && _elements.last is DrawnPath) {
                (_elements.last as DrawnPath).path.lineTo(
                  details.localPosition.dx, 
                  details.localPosition.dy
                );
              }
            });
          } else if (_isDrawingShape && _shapeStartPoint != null) {
            setState(() {
              _shapeEndPoint = details.localPosition;
            });
          }
        },
        onPanEnd: (details) {
          _draggingText = null;
          _dragStartOffset = null;
          
          if (_isDrawingShape && _shapeStartPoint != null && _shapeEndPoint != null) {
            _addShape();
            _isDrawingShape = false;
            _shapeStartPoint = null;
            _shapeEndPoint = null;
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: EnhancedDrawingPainter(
              _elements,
              _isDrawingShape ? _shapeStartPoint : null,
              _isDrawingShape ? _shapeEndPoint : null,
              _selectedTool,
              _selectedColor,
              _strokeWidth,
            ),
          ),
        ),
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
                  return custom_color_swatch.ColorSwatch(
                    color: color,
                    isSelected: _selectedColor == color,
                    showHex: false,
                    showCopyFeedback: false,
                    size: 45,
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
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

  bool _isShapeTool(DrawingTool tool) {
    return tool == DrawingTool.line || 
           tool == DrawingTool.rectangle || 
           tool == DrawingTool.circle;
  }

  void _addShape() {
    if (_shapeStartPoint == null || _shapeEndPoint == null) return;

    setState(() {
      switch (_selectedTool) {
        case DrawingTool.line:
          _elements.add(DrawnLine(
            start: _shapeStartPoint!,
            end: _shapeEndPoint!,
            color: _selectedColor,
            strokeWidth: _strokeWidth,
          ));
          break;
        case DrawingTool.rectangle:
          _elements.add(DrawnRectangle(
            topLeft: Offset(
              math.min(_shapeStartPoint!.dx, _shapeEndPoint!.dx),
              math.min(_shapeStartPoint!.dy, _shapeEndPoint!.dy),
            ),
            bottomRight: Offset(
              math.max(_shapeStartPoint!.dx, _shapeEndPoint!.dx),
              math.max(_shapeStartPoint!.dy, _shapeEndPoint!.dy),
            ),
            color: _selectedColor,
            strokeWidth: _strokeWidth,
            fillColor: Colors.transparent,
          ));
          break;
        case DrawingTool.circle:
          final center = Offset(
            (_shapeStartPoint!.dx + _shapeEndPoint!.dx) / 2,
            (_shapeStartPoint!.dy + _shapeEndPoint!.dy) / 2,
          );
          final radius = (_shapeStartPoint! - _shapeEndPoint!).distance / 2;
          _elements.add(DrawnCircle(
            center: center,
            radius: radius,
            color: _selectedColor,
            strokeWidth: _strokeWidth,
            fillColor: Colors.transparent,
          ));
          break;
        default:
          break;
      }
    });
  }

  void _fillShapeAtPosition(Offset position) {
    setState(() {
      for (int i = _elements.length - 1; i >= 0; i--) {
        final element = _elements[i];
        
        if (element is DrawnRectangle) {
          final rect = Rect.fromPoints(element.topLeft, element.bottomRight);
          if (rect.contains(position)) {
            _elements[i] = DrawnRectangle(
              topLeft: element.topLeft,
              bottomRight: element.bottomRight,
              color: element.color,
              strokeWidth: element.strokeWidth,
              fillColor: _selectedColor,
            );
            break;
          }
        } else if (element is DrawnCircle) {
          final distance = (position - element.center).distance;
          if (distance <= element.radius) {
            _elements[i] = DrawnCircle(
              center: element.center,
              radius: element.radius,
              color: element.color,
              strokeWidth: element.strokeWidth,
              fillColor: _selectedColor,
            );
            break;
          }
        } else if (element is DrawnPath) {
          if (_isPointInClosedPath(position, element.path)) {
            _elements[i] = DrawnPath(
              path: element.path,
              color: element.color,
              strokeWidth: element.strokeWidth,
              fillColor: _selectedColor,
            );
            break;
          }
        }
      }
    });
  }

  bool _isPointInClosedPath(Offset point, Path path) {
    return path.contains(point);
  }

  void _addTextAtPosition(Offset position) {
    if (_currentText.isNotEmpty) {
      setState(() {
        _elements.add(DrawnText(
          position: position,
          text: _currentText,
          color: _selectedColor,
          fontSize: _fontSize,
          fontFamily: _selectedFont,
        ));
      });
      _currentText = '';
    } else {
      _showTextDialog();
    }
  }

  void _showTextDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Enter your text...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentText = _textController.text;
              });
              _textController.clear();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tap on the canvas to place your text'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  void _undo() {
    if (_elements.isNotEmpty) {
      setState(() {
        _elements.removeLast();
      });
    }
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
                _elements.clear();
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

  Future<void> _saveDrawing() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requestGranted = await Gal.requestAccess();
        if (!requestGranted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gallery access permission required to save drawing'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${directory.path}/color_harmony_drawing_$timestamp.png');
      await tempFile.writeAsBytes(pngBytes);
      await Gal.putImage(tempFile.path, album: 'Color Harmony');
      await tempFile.delete();
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Drawing saved to Gallery! 🎨\nCheck your Photos app in "Color Harmony" album'),
              ),
            ],
          ),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                        _availableColors = _availableColors.toSet().toList();
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundColor,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 0,
                            offset: Offset(4, 4),
                          ),
                        ],
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
abstract class DrawnElement {}

class DrawnPath extends DrawnElement {
  final Path path;
  final Color color;
  final double strokeWidth;
  final Color fillColor;

  DrawnPath({
    required this.path,
    required this.color,
    required this.strokeWidth,
    this.fillColor = Colors.transparent,
  });
}

class DrawnLine extends DrawnElement {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  DrawnLine({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawnRectangle extends DrawnElement {
  final Offset topLeft;
  final Offset bottomRight;
  final Color color;
  final double strokeWidth;
  final Color fillColor;

  DrawnRectangle({
    required this.topLeft,
    required this.bottomRight,
    required this.color,
    required this.strokeWidth,
    this.fillColor = Colors.transparent,
  });
}

class DrawnCircle extends DrawnElement {
  final Offset center;
  final double radius;
  final Color color;
  final double strokeWidth;
  final Color fillColor;

  DrawnCircle({
    required this.center,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    this.fillColor = Colors.transparent,
  });
}

class DrawnText extends DrawnElement {
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;
  final String fontFamily;

  DrawnText({
    required this.position,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontFamily,
  });
}
class EnhancedDrawingPainter extends CustomPainter {
  final List<DrawnElement> elements;
  final Offset? previewStart;
  final Offset? previewEnd;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentStrokeWidth;

  EnhancedDrawingPainter(
    this.elements,
    this.previewStart,
    this.previewEnd,
    this.currentTool,
    this.currentColor,
    this.currentStrokeWidth,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      if (element is DrawnPath) {
        if (element.fillColor != Colors.transparent) {
          final fillPaint = Paint()
            ..color = element.fillColor
            ..style = PaintingStyle.fill;
          canvas.drawPath(element.path, fillPaint);
        }
        
        final paint = Paint()
          ..color = element.color
          ..strokeWidth = element.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(element.path, paint);
      } else if (element is DrawnLine) {
        final paint = Paint()
          ..color = element.color
          ..strokeWidth = element.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(element.start, element.end, paint);
      } else if (element is DrawnRectangle) {
        final rect = Rect.fromPoints(element.topLeft, element.bottomRight);
        
        if (element.fillColor != Colors.transparent) {
          final fillPaint = Paint()
            ..color = element.fillColor
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, fillPaint);
        }
        
        final strokePaint = Paint()
          ..color = element.color
          ..strokeWidth = element.strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, strokePaint);
      } else if (element is DrawnCircle) {
        if (element.fillColor != Colors.transparent) {
          final fillPaint = Paint()
            ..color = element.fillColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(element.center, element.radius, fillPaint);
        }
        
        final strokePaint = Paint()
          ..color = element.color
          ..strokeWidth = element.strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(element.center, element.radius, strokePaint);
      } else if (element is DrawnText) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text,
            style: TextStyle(
              color: element.color,
              fontSize: element.fontSize,
              fontFamily: element.fontFamily,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, element.position);
      }
    }
    
    if (previewStart != null && previewEnd != null) {
      final paint = Paint()
        ..color = currentColor.withValues(alpha:0.7)
        ..strokeWidth = currentStrokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      switch (currentTool) {
        case DrawingTool.line:
          canvas.drawLine(previewStart!, previewEnd!, paint);
          break;
        case DrawingTool.rectangle:
          final rect = Rect.fromPoints(previewStart!, previewEnd!);
          canvas.drawRect(rect, paint);
          break;
        case DrawingTool.circle:
          final center = Offset(
            (previewStart!.dx + previewEnd!.dx) / 2,
            (previewStart!.dy + previewEnd!.dy) / 2,
          );
          final radius = (previewStart! - previewEnd!).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
        default:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
