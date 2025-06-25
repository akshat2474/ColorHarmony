import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/accessibility_service.dart';
import '../models/accessibility_result.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';

class AccessibilityCheckerScreen extends StatefulWidget {
  const AccessibilityCheckerScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilityCheckerScreen> createState() => _AccessibilityCheckerScreenState();
}

class _AccessibilityCheckerScreenState extends State<AccessibilityCheckerScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  AccessibilityResult? _result;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _checkAccessibility();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _checkAccessibility() {
    setState(() {
      _result = AccessibilityService.checkContrast(_foregroundColor, _backgroundColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Accessibility Checker'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: AppConstants.animationSlow,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildColorSelectors(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildPreview(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  if (_result != null) _buildResults(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildGuidelines(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelectors() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Colors to Test',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          Row(
            children: [
              Expanded(
                child: _buildColorSelector(
                  'Text Color',
                  _foregroundColor,
                  () => _showAdvancedColorPicker(true),
                ),
              ),
              
              const SizedBox(width: AppConstants.paddingLarge),
              
              Expanded(
                child: _buildColorSelector(
                  'Background Color',
                  _backgroundColor,
                  () => _showAdvancedColorPicker(false),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Quick color presets
          const Text(
            'Quick Presets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetButton('Black on White', Colors.black, Colors.white),
              _buildPresetButton('White on Black', Colors.white, Colors.black),
              _buildPresetButton('Blue on White', Colors.blue, Colors.white),
              _buildPresetButton('White on Blue', Colors.white, Colors.blue),
              _buildPresetButton('Dark Gray on Light', Colors.grey[800]!, Colors.grey[100]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    color: ColorUtils.getContrastingTextColor(color),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ColorUtils.colorToHex(color),
                    style: TextStyle(
                      color: ColorUtils.getContrastingTextColor(color),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, Color foreground, Color background) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _foregroundColor = foreground;
          _backgroundColor = background;
        });
        _checkAccessibility();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Heading',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _foregroundColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is sample body text to demonstrate how the selected colors work together. The contrast ratio affects readability for all users, especially those with visual impairments.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _foregroundColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _foregroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    'Button Text',
                    style: TextStyle(
                      color: _backgroundColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final result = _result!;
    
    Color levelColor;
    IconData levelIcon;
    
    switch (result.level) {
      case AccessibilityLevel.excellent:
        levelColor = Colors.green;
        levelIcon = Icons.check_circle;
        break;
      case AccessibilityLevel.good:
        levelColor = Colors.blue;
        levelIcon = Icons.check_circle_outline;
        break;
      case AccessibilityLevel.fair:
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      case AccessibilityLevel.poor:
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(levelIcon, color: levelColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Accessibility Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          _buildResultRow('Contrast Ratio', '${result.contrastRatio.toStringAsFixed(2)}:1'),
          _buildResultRow('WCAG AA', result.passesAA ? 'Pass ✓' : 'Fail ✗'),
          _buildResultRow('WCAG AAA', result.passesAAA ? 'Pass ✓' : 'Fail ✗'),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              result.recommendation,
              style: TextStyle(
                color: levelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelines() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WCAG Guidelines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          _buildGuidelineItem(
            'AA Standard',
            'Minimum contrast ratio of 4.5:1 for normal text',
            Icons.check_circle_outline,
            Colors.blue,
          ),
          _buildGuidelineItem(
            'AAA Standard',
            'Enhanced contrast ratio of 7:1 for normal text',
            Icons.check_circle,
            Colors.green,
          ),
          _buildGuidelineItem(
            'Large Text',
            'Minimum 3:1 ratio for text 18pt+ or 14pt+ bold',
            Icons.text_fields,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedColorPicker(bool isForeground) {
    Color currentColor = isForeground ? _foregroundColor : _backgroundColor;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${isForeground ? 'Text' : 'Background'} Color'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                currentColor = color;
              },
              colorPickerWidth: 250,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsl,
              labelTypes: const [],
              pickerAreaBorderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isForeground) {
                  _foregroundColor = currentColor;
                } else {
                  _backgroundColor = currentColor;
                }
              });
              _checkAccessibility();
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
