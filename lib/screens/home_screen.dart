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
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatingAnimation;

  Color _selectedColor = const Color(0xFF667eea);
  HarmonyType _selectedHarmony = HarmonyType.analogous;
  List<Color> _generatedColors = [];
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _generateColors();
    _fadeController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatingController.dispose();
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

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFAFA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (_isDesktop(context)) {
                  return _buildDesktopLayout();
                } else if (_isTablet(context)) {
                  return _buildTabletLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWebHeader(),
          const SizedBox(height: 30),
          _buildMainFeaturesSection(),
          const SizedBox(height: 60),
          _buildHeroSection(),
          const SizedBox(height: 60),
          _buildColorGeneratorSection(),
          const SizedBox(height: 60),
          _buildQuickActionsSection(),
          const SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWebHeader(),
          const SizedBox(height: 20),
          _buildMainFeaturesSection(),
          const SizedBox(height: 40),
          _buildHeroSection(),
          const SizedBox(height: 40),
          _buildColorGeneratorSection(),
          const SizedBox(height: 40),
          _buildQuickActionsSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileAppBar(),
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
                    _buildMainFeatures(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildColorGenerator(isCompact: true),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Color Harmony',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton('Gallery', Icons.photo_library, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedPalettesScreen(),
                  ),
                );
              }),
              const SizedBox(width: 20),
              _buildHeaderButton('Accessibility', Icons.accessibility, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilityCheckerScreen(),
                  ),
                );
              }),
              const SizedBox(width: 20),
              _buildPrimaryButton('Get Started', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrawingPadScreen(
                      initialColors: _generatedColors,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text, IconData icon, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient:const LinearGradient(
              colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 20,
      ),
      child: Column(
        children: [
          Text(
            'Creative Tools',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your creative tool to get started',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 16 : 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = _getFeatureData();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isDesktop(context) ? 3 : (_isTablet(context) ? 2 : 2),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: _isDesktop(context) ? 1.1 : 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildEnhancedFeatureCard(
          title: feature['title'] as String,
          subtitle: feature['subtitle'] as String,
          icon: feature['icon'] as IconData,
          color: feature['color'] as Color,
          onTap: feature['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildEnhancedFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: _isDesktop(context) ? 32 : 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _isDesktop(context) ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _isDesktop(context) ? 14 : 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 40,
      ),
      child: Row(
        children: [
          Expanded(
            flex: _isDesktop(context) ? 1 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: Text(
                        'Create Beautiful\nColor Palettes',
                        style: TextStyle(
                          fontSize: _isDesktop(context) ? 56 : 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Design stunning color combinations with our intuitive tools. From drawing pads to pattern creators, unleash your creativity with professional-grade color harmony.',
                  style: TextStyle(
                    fontSize: _isDesktop(context) ? 18 : 16,
                    color: Colors.grey[500],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    _buildHeroButton(
                      'Start Creating',
                      Icons.brush,
                      true,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawingPadScreen(
                            initialColors: _generatedColors,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildHeroButton(
                      'Explore Gallery',
                      Icons.photo_library,
                      false,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedPalettesScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isDesktop(context)) ...[
            const SizedBox(width: 60),
            Expanded(
              child: _buildHeroVisual(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroButton(String text, IconData icon, bool isPrimary, VoidCallback onPressed) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                  )
                : null,
            color: isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: isPrimary ? null : Border.all(color: AppConstants.primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isPrimary ? AppConstants.primaryColor : Colors.grey).withOpacity(0.3),
                blurRadius: _isHovering ? 20 : 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppConstants.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroVisual() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatingAnimation.value),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _selectedColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _generatedColors.isNotEmpty
                            ? _generatedColors
                            : [Colors.blue, Colors.purple, Colors.pink],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorGeneratorSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 40,
      ),
      child: Column(
        children: [
          Text(
            'Interactive Color Generator',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Discover perfect color combinations with our advanced harmony algorithms',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 16 : 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildColorGenerator(isCompact: false),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildQuickActionButton(
          'Trending Colors',
          Icons.trending_up,
          AppConstants.secondaryColor,
          () {
            setState(() {
              _generatedColors = ColorService.generateTrendingPalette();
            });
          },
        ),
        _buildQuickActionButton(
          'Random Palette',
          Icons.shuffle,
          Colors.orange,
          () {
            setState(() {
              _selectedColor = ColorService.generateRandomColor();
              _selectedHarmony = HarmonyType.values[
                  DateTime.now().millisecond % HarmonyType.values.length];
            });
            _generateColors();
          },
        ),
        _buildQuickActionButton(
          'Accessibility Check',
          Icons.accessibility,
          Colors.green,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccessibilityCheckerScreen(),
              ),
            );
          },
        ),
        _buildQuickActionButton(
          'Saved Palettes',
          Icons.bookmark,
          AppConstants.primaryColor,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavedPalettesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Center(
        child: Text(
           'Crafted by Akshat Singh',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Color Harmony',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
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

  Widget _buildColorGenerator({required bool isCompact}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _isDesktop(context) ? 800 : double.infinity,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Wheel',
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your base color',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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
                style: IconButton.styleFrom(
                  backgroundColor: _selectedColor.withOpacity(0.1),
                  foregroundColor: _selectedColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: isCompact ? 200 : 280,
                    height: isCompact ? 200 : 280,
                    child: ColorWheel(
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                        _generateColors();
                      },
                      selectedColor: _selectedColor,
                      size: isCompact ? 200 : 280,
                    ),
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harmony Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHarmonySelector(),
                      const SizedBox(height: 24),
                      Text(
                        'Generated Palette',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPalettePreview(),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          if (isCompact) ...[
            const SizedBox(height: 24),
            _buildHarmonySelector(),
            const SizedBox(height: 24),
            _buildPalettePreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildHarmonySelector() {
    return GestureDetector(
      onTap: _showHarmonySelectorModal,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _selectedColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                ColorHarmony.harmonies
                    .firstWhere((h) => h.type == _selectedHarmony)
                    .icon,
                color: _selectedColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ColorHarmony.harmonies
                    .firstWhere((h) => h.type == _selectedHarmony)
                    .name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: _selectedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalettePreview() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _viewPaletteDetails,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                      bottomLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                      topRight: isLast ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
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
      ),
    );
  }

  Widget _buildMainFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create & Design',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
          childAspectRatio: 1.6,
          children: _getFeatureCards(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFeatureData() {
    return [
      {
        'title': 'Drawing Pad',
        'subtitle': 'Create digital art with custom brushes',
        'icon': Icons.draw,
        'color': Colors.green,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrawingPadScreen(
              initialColors: _generatedColors,
            ),
          ),
        ),
      },
      {
        'title': 'Pattern Creator',
        'subtitle': 'Design beautiful repeating patterns',
        'icon': Icons.grid_4x4,
        'color': Colors.purple,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatternCreatorScreen(
              initialColors: _generatedColors,
            ),
          ),
        ),
      },
      {
        'title': 'Extract Colors',
        'subtitle': 'Pull palettes from any image',
        'icon': Icons.image,
        'color': Colors.teal,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ImageColorExtractorScreen(),
          ),
        ),
      },
      {
        'title': 'Edit Palette',
        'subtitle': 'Fine-tune your color combinations',
        'icon': Icons.edit,
        'color': AppConstants.primaryColor,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaletteGeneratorScreen(
              initialColors: _generatedColors,
              harmonyType: _selectedHarmony,
            ),
          ),
        ),
      },
      {
        'title': 'View Details',
        'subtitle': 'Explore palette information',
        'icon': Icons.visibility,
        'color': Colors.orange,
        'onTap': _viewPaletteDetails,
      },
      {
        'title': 'Fighting Arena',
        'subtitle': 'Animate epic color battles',
        'icon': Icons.sports_mma,
        'color': Colors.deepOrange,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedFightingScreen(
              initialColors: _generatedColors,
            ),
          ),
        ),
      },
    ];
  }

  List<Widget> _getFeatureCards() {
    final features = _getFeatureData();
    return features.map((feature) => _buildFeatureCard(
      title: feature['title'] as String,
      subtitle: feature['subtitle'] as String,
      icon: feature['icon'] as IconData,
      color: feature['color'] as Color,
      onTap: feature['onTap'] as VoidCallback,
    )).toList();
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
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTrendingButton()),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(child: _buildRandomButton()),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(child: _buildAccessibilityButton()),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(child: _buildSavedButton()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendingButton() {
    return ElevatedButton.icon(
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildRandomButton() {
    return ElevatedButton.icon(
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildAccessibilityButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccessibilityCheckerScreen(),
          ),
        );
      },
      icon: const Icon(Icons.accessibility),
      label: const Text('Accessibility'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildSavedButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SavedPalettesScreen(),
          ),
        );
      },
      icon: const Icon(Icons.bookmark),
      label: const Text('Saved'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }
}
