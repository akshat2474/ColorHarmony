import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../widgets/color_wheel.dart';
import '../models/color_palette.dart';
import '../models/color_harmony.dart';
import '../services/palette_storage_service.dart';
import '../services/color_service.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';
import 'color_picker_screen.dart';

class PaletteGeneratorScreen extends StatefulWidget {
  final List<Color> initialColors;
  final HarmonyType harmonyType;

  const PaletteGeneratorScreen({
    Key? key,
    required this.initialColors,
    required this.harmonyType,
  }) : super(key: key);

  @override
  State<PaletteGeneratorScreen> createState() => _PaletteGeneratorScreenState();
}

class _PaletteGeneratorScreenState extends State<PaletteGeneratorScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;
  
  List<Color> _colors = [];
  int _selectedColorIndex = 0;
  bool _showColorPicker = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _colors = List.from(widget.initialColors);
    
    _slideController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Palette'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _canAddColor() ? _addColor : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regeneratePalette,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePalette,
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildPalettePreview(),
            Expanded(
              child: _showColorPicker
                  ? _buildColorPicker()
                  : _buildColorList(),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _toggleColorPicker,
          backgroundColor: AppConstants.primaryColor,
          icon: Icon(_showColorPicker ? Icons.list : Icons.palette),
          label: Text(_showColorPicker ? 'Color List' : 'Color Picker'),
        ),
      ),
    );
  }

  Widget _buildPalettePreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Row(
          children: _colors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: AppConstants.animationFast,
                  decoration: BoxDecoration(
                    color: color,
                    border: _selectedColorIndex == index
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedColorIndex == index)
                          const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 24,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          ColorUtils.colorToHex(color),
                          style: TextStyle(
                            color: ColorUtils.getContrastingTextColor(color),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Text(
            'Editing Color ${_selectedColorIndex + 1}',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: ColorWheel(
              onColorSelected: (color) {
                setState(() {
                  _colors[_selectedColorIndex] = color;
                });
              },
              selectedColor: _colors[_selectedColorIndex],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildColorAdjustments(),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ColorPickerScreen(
                    initialColor: _colors[_selectedColorIndex],
                    onColorSelected: (color) {
                      setState(() {
                        _colors[_selectedColorIndex] = color;
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text('Advanced Picker'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorAdjustments() {
    final currentColor = _colors[_selectedColorIndex];
    final hsl = HSLColor.fromColor(currentColor);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        children: [
          _buildSlider(
            'Brightness',
            hsl.lightness,
            (value) {
              setState(() {
                _colors[_selectedColorIndex] = hsl.withLightness(value).toColor();
              });
            },
          ),
          _buildSlider(
            'Saturation',
            hsl.saturation,
            (value) {
              setState(() {
                _colors[_selectedColorIndex] = hsl.withSaturation(value).toColor();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value * 100).round()}%',
          style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppConstants.textPrimary,
          ),
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: AppConstants.primaryColor,
          inactiveColor: AppConstants.primaryColor.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildColorList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.animationMedium,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildColorListItem(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorListItem(int index) {
    final color = _colors[index];
    final isSelected = _selectedColorIndex == index;
    final hsl = ColorUtils.colorToHsl(color);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: isSelected
            ? Border.all(color: AppConstants.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CustomColorSwatch.ColorSwatch(
          color: color,
          size: 40,
          showHex: false,
          showCopyFeedback: false,
        ),
        title: Text(
          ColorUtils.colorToHex(color),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RGB(${color.red}, ${color.green}, ${color.blue})',
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: AppConstants.fontSizeSmall,
              ),
            ),
            Text(
              'HSL(${hsl['h']!.round()}°, ${(hsl['s']! * 100).round()}%, ${(hsl['l']! * 100).round()}%)',
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: AppConstants.fontSizeSmall,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                setState(() {
                  _selectedColorIndex = index;
                  _showColorPicker = true;
                });
              },
            ),
            if (_colors.length > AppConstants.minColorsInPalette)
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: () => _removeColor(index),
              ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedColorIndex = index;
          });
        },
      ),
    );
  }

  // Rest of the methods remain the same...
  void _toggleColorPicker() {
    setState(() {
      _showColorPicker = !_showColorPicker;
    });
  }

  bool _canAddColor() {
    return _colors.length < AppConstants.maxColorsInPalette;
  }

  void _addColor() {
    if (_canAddColor()) {
      setState(() {
        _colors.add(ColorService.generateRandomColor());
        _selectedColorIndex = _colors.length - 1;
      });
    }
  }

  void _removeColor(int index) {
    if (_colors.length > AppConstants.minColorsInPalette) {
      setState(() {
        _colors.removeAt(index);
        if (_selectedColorIndex >= _colors.length) {
          _selectedColorIndex = _colors.length - 1;
        }
      });
    }
  }

  void _regeneratePalette() {
    final baseColor = _colors[_selectedColorIndex];
    final newColors = ColorService.generateHarmony(baseColor, widget.harmonyType);
    setState(() {
      _colors = newColors;
      _selectedColorIndex = 0;
    });
  }

  void _savePalette() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Palette'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Palette Name',
                hintText: 'Enter a name for your palette',
              ),
              maxLength: AppConstants.maxPaletteNameLength,
            ),
            const SizedBox(height: 16),
            // Preview
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: _colors.map((color) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: _colors.indexOf(color) == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              )
                            : _colors.indexOf(color) == _colors.length - 1
                                ? const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  )
                                : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final palette = ColorPalette(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  colors: _colors,
                  harmonyType: widget.harmonyType.toString().split('.').last,
                  createdAt: DateTime.now(),
                );
                
                await PaletteStorageService.savePalette(palette);
                
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Palette saved successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
