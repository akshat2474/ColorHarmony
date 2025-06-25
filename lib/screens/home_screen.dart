import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/color_wheel.dart';
import '../widgets/harmony_selector.dart';
import '../widgets/color_swatch.dart' as CustomColorSwatch;
import '../services/color_service.dart';
import '../models/color_harmony.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';
import 'palette_generator_screen.dart';
import 'saved_palettes_screen.dart';
import 'accessibility_checker_screen.dart';
import 'palette_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Color _selectedColor = const Color(0xFF667eea);
  HarmonyType _selectedHarmony = HarmonyType.analogous;
  List<Color> _generatedColors = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _generateColors();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _generateColors() {
    setState(() {
      _generatedColors = ColorService.generateHarmony(_selectedColor, _selectedHarmony);
    });
  }

  void _showHarmonySelectorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HarmonySelector(
        selectedHarmony: _selectedHarmony,
        onHarmonySelected: (harmony) {
          setState(() {
            _selectedHarmony = harmony;
          });
          _generateColors();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _viewPaletteDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaletteDetailScreen(
          colors: _generatedColors,
          harmonyType: _selectedHarmony,
          baseColor: _selectedColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
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
                            _buildColorWheel(),
                            const SizedBox(height: AppConstants.paddingLarge),
                            _buildHarmonySelector(),
                            const SizedBox(height: AppConstants.paddingLarge),
                            _buildGeneratedPalette(),
                            const SizedBox(height: AppConstants.paddingLarge),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Color Harmony',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedPalettesScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.accessibility),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccessibilityCheckerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorWheel() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Pick a Base Color',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ColorWheel(
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
              _generateColors();
            },
            selectedColor: _selectedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHarmonySelector() {
    final selectedHarmony = ColorHarmony.harmonies
        .firstWhere((h) => h.type == _selectedHarmony);
    
    return GestureDetector(
      onTap: _showHarmonySelectorModal,
      child: Container(
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
        child: Row(
          children: [
            Icon(
              selectedHarmony.icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedHarmony.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  Text(
                    selectedHarmony.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppConstants.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedPalette() {
    return GestureDetector(
      onTap: _viewPaletteDetails,
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated Palette',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: _viewPaletteDetails,
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _selectedColor = ColorService.generateRandomColor();
                        });
                        _generateColors();
                      },
                      tooltip: 'Regenerate',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: _generatedColors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final color = entry.value;
                  final isFirst = index == 0;
                  final isLast = index == _generatedColors.length - 1;
                  
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.only(
                          topLeft: isFirst ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                          bottomLeft: isFirst ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                          topRight: isLast ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                          bottomRight: isLast ? const Radius.circular(AppConstants.radiusMedium) : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ColorUtils.colorToHex(color),
                          style: TextStyle(
                            color: ColorUtils.getContrastingTextColor(color),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: AppConstants.paddingSmall,
              children: _generatedColors.map((color) {
                return CustomColorSwatch.ColorSwatch(
                  color: color,
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    _generateColors();
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Tap to view details hint
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tap to view detailed palette information',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaletteGeneratorScreen(
                        initialColors: _generatedColors,
                        harmonyType: _selectedHarmony,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Palette'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _generatedColors = ColorService.generateTrendingPalette();
                  });
                },
                icon: const Icon(Icons.trending_up),
                label: const Text('Trending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedColor = ColorService.generateRandomColor();
                _selectedHarmony = HarmonyType.values[
                    DateTime.now().millisecond % HarmonyType.values.length];
              });
              _generateColors();
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Random Palette'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
