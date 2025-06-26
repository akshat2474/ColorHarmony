import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/color_wheel.dart';
import '../widgets/harmony_selector.dart';
import '../services/color_service.dart';
import '../models/color_harmony.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';
import 'palette_generator_screen.dart';
import 'saved_palettes_screen.dart';
import 'accessibility_checker_screen.dart';
import 'palette_detail_screen.dart';
import 'drawing_pad_screen.dart';
import 'pattern_creator_screen.dart';
import 'image_color_extractor_screen.dart';
import 'animated_fighting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
      _generatedColors =
          ColorService.generateHarmony(_selectedColor, _selectedHarmony);
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
                          duration: AppConstants.animationMedium,
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            // Main Feature Cards - Smaller buttons
                            _buildMainFeatures(),
                            const SizedBox(height: AppConstants.paddingLarge),
                            
                            // Compact Color Generator Section - Fixed size
                            _buildCompactColorGenerator(),
                            const SizedBox(height: AppConstants.paddingLarge),
                            
                            // Quick Actions
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
  Widget _buildMainFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create & Design',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Smaller Feature Cards in 2x3 Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
          childAspectRatio: 1.6, // Increased from 1.1 to make buttons shorter
          children: [
            _buildFeatureCard(
              title: 'Drawing Pad',
              subtitle: 'Create digital art',
              icon: Icons.draw,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrawingPadScreen(
                    initialColors: _generatedColors,
                  ),
                ),
              ),
            ),
            _buildFeatureCard(
              title: 'Pattern Creator',
              subtitle: 'Design patterns',
              icon: Icons.grid_4x4,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatternCreatorScreen(
                    initialColors: _generatedColors,
                  ),
                ),
              ),
            ),
            _buildFeatureCard(
              title: 'Extract Colors',
              subtitle: 'From images',
              icon: Icons.image,
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImageColorExtractorScreen(),
                ),
              ),
            ),
            _buildFeatureCard(
              title: 'Edit Palette',
              subtitle: 'Fine-tune colors',
              icon: Icons.edit,
              color: AppConstants.primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaletteGeneratorScreen(
                    initialColors: _generatedColors,
                    harmonyType: _selectedHarmony,
                  ),
                ),
              ),
            ),
            _buildFeatureCard(
              title: 'View Details',
              subtitle: 'Palette info',
              icon: Icons.visibility,
              color: Colors.orange,
              onTap: _viewPaletteDetails,
            ),
            _buildFeatureCard(
              title: 'Fighting Arena',
              subtitle: 'Animate battles',
              icon: Icons.sports_mma,
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimatedFightingScreen(
                    initialColors: _generatedColors,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 16
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  icon,
                  size: 24, // Reduced from 32
                  color: color,
                ),
              ),
              const SizedBox(height: 6), // Reduced spacing
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13, // Reduced from 16
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10, // Reduced from 12
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCompactColorGenerator() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Color Generator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _selectedColor = ColorService.generateRandomColor();
                  });
                  _generateColors();
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          Center(
            child: SizedBox(
              width: 160, // Reduced from 200
              height: 160, // Reduced from 200
              child: ColorWheel(
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                  _generateColors();
                },
                selectedColor: _selectedColor,
                size: 160, // Reduced from 200
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          GestureDetector(
            onTap: _showHarmonySelectorModal,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    ColorHarmony.harmonies
                        .firstWhere((h) => h.type == _selectedHarmony)
                        .icon,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      ColorHarmony.harmonies
                          .firstWhere((h) => h.type == _selectedHarmony)
                          .name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppConstants.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          GestureDetector(
            onTap: _viewPaletteDetails,
            child: Container(
              height: 50, // Reduced from 60
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
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
                          topLeft: isFirst
                              ? const Radius.circular(AppConstants.radiusMedium)
                              : Radius.zero,
                          bottomLeft: isFirst
                              ? const Radius.circular(AppConstants.radiusMedium)
                              : Radius.zero,
                          topRight: isLast
                              ? const Radius.circular(AppConstants.radiusMedium)
                              : Radius.zero,
                          bottomRight: isLast
                              ? const Radius.circular(AppConstants.radiusMedium)
                              : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ColorUtils.colorToHex(color),
                          style: TextStyle(
                            color: ColorUtils.getContrastingTextColor(color),
                            fontSize: 9, // Reduced from 10
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingSmall),
          
          const Center(
            child: Text(
              'Tap palette to view details',
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
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
                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
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
                    _selectedColor = ColorService.generateRandomColor();
                    _selectedHarmony = HarmonyType.values[
                        DateTime.now().millisecond % HarmonyType.values.length];
                  });
                  _generateColors();
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Random'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
