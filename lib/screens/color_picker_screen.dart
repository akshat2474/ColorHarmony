import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../utils/color_utils.dart';
import '../utils/constants.dart';

class ColorPickerScreen extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerScreen({
    Key? key,
    required this.initialColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen>
    with TickerProviderStateMixin {
  late Color _selectedColor;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker'),
        backgroundColor: _selectedColor,
        foregroundColor: ColorUtils.getContrastingTextColor(_selectedColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onColorSelected(_selectedColor);
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorUtils.getContrastingTextColor(_selectedColor),
          unselectedLabelColor: ColorUtils.getContrastingTextColor(_selectedColor).withOpacity(0.7),
          indicatorColor: ColorUtils.getContrastingTextColor(_selectedColor),
          tabs: const [
            Tab(text: 'Wheel'),
            Tab(text: 'Sliders'),
            Tab(text: 'Swatches'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Color preview
          Container(
            width: double.infinity,
            height: 100,
            color: _selectedColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ColorUtils.colorToHex(_selectedColor),
                    style: TextStyle(
                      color: ColorUtils.getContrastingTextColor(_selectedColor),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RGB(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})',
                    style: TextStyle(
                      color: ColorUtils.getContrastingTextColor(_selectedColor),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Color picker tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWheelPicker(),
                _buildSliderPicker(),
                _buildSwatchesPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelPicker() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: ColorPicker(
        pickerColor: _selectedColor,
        onColorChanged: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
        colorPickerWidth: 300,
        pickerAreaHeightPercent: 0.7,
        enableAlpha: false,
        displayThumbColor: true,
        paletteType: PaletteType.hsl,
        labelTypes: const [],
        pickerAreaBorderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    );
  }

  Widget _buildSliderPicker() {
    final hsl = HSLColor.fromColor(_selectedColor);
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          _buildSlider(
            'Hue',
            hsl.hue,
            0,
            360,
            (value) {
              setState(() {
                _selectedColor = hsl.withHue(value).toColor();
              });
            },
          ),
          _buildSlider(
            'Saturation',
            hsl.saturation,
            0,
            1,
            (value) {
              setState(() {
                _selectedColor = hsl.withSaturation(value).toColor();
              });
            },
          ),
          _buildSlider(
            'Lightness',
            hsl.lightness,
            0,
            1,
            (value) {
              setState(() {
                _selectedColor = hsl.withLightness(value).toColor();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(label == 'Hue' ? 0 : 2)}',
          style: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: AppConstants.primaryColor,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  Widget _buildSwatchesPicker() {
    final predefinedColors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
        ),
        itemCount: predefinedColors.length,
        itemBuilder: (context, index) {
          final color = predefinedColors[index];
          return CustomColorSwatch.ColorSwatch(
            color: color,
            isSelected: color == _selectedColor,
            showHex: false,
            showCopyFeedback: false,
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
          );
        },
      ),
    );
  }
}
