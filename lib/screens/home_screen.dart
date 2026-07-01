import 'package:color_harmony/widgets/brutalist_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _heroIntroController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _heroSlideAnimation;

  Color _selectedColor = const Color(0xFF667eea);
  HarmonyType _selectedHarmony = HarmonyType.analogous;
  List<Color> _generatedColors = [];

  // Recent colors — in-memory for the session
  final List<Color> _recentColors = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );

    // Hero section slides in once on load — not a repeating loop
    _heroIntroController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _heroIntroController, curve: Curves.easeOutCubic),
    );

    _generateColors();
    _fadeController.forward();
    _heroIntroController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heroIntroController.dispose();
    super.dispose();
  }

  void _generateColors() {
    final colors =
        ColorService.generateHarmony(_selectedColor, _selectedHarmony);
    setState(() {
      _generatedColors = colors;
      // Track recent colours (deduplicate, cap at 12)
      for (final c in colors) {
        _recentColors.removeWhere(
            (r) => (r.toARGB32() ^ c.toARGB32()) < 0x00111111); // roughly same colour
        _recentColors.insert(0, c);
      }
      if (_recentColors.length > 12) {
        _recentColors.removeRange(12, _recentColors.length);
      }
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

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  bool _isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 768 && w < 1200;
  }

  // ─── Main Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_isDesktop(context)) return _buildDesktopLayout();
              if (_isTablet(context)) return _buildTabletLayout();
              return _buildMobileLayout();
            },
          ),
        ),
      ),
    );
  }

  // ─── Layouts ──────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWebHeader(),
          const SizedBox(height: 30),
          _buildHeroSection(),
          const SizedBox(height: 48),
          _buildRecentColorsStrip(),
          const SizedBox(height: 48),
          _buildFeaturesSection(),
          const SizedBox(height: 48),
          _buildColorGeneratorSection(),
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
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildRecentColorsStrip(),
          const SizedBox(height: 32),
          _buildFeaturesSection(),
          const SizedBox(height: 32),
          _buildColorGeneratorSection(),
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
                    verticalOffset: 24.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildMobileHeroStrip(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildRecentColorsStrip(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildMainFeatures(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildColorGenerator(isCompact: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── App Bars ─────────────────────────────────────────────────────────────

  Widget _buildWebHeader() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        color: AppConstants.cardColor,
        border: Border(bottom: BorderSide(color: Colors.black, width: AppConstants.borderWidth)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.accentPink,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.palette, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                'COLOR HARMONY',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildNavButton('Gallery', Icons.photo_library, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SavedPalettesScreen()));
              }),
              const SizedBox(width: 8),
              _buildNavButton('Accessibility', Icons.accessibility, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AccessibilityCheckerScreen()));
              }),
              const SizedBox(width: 16),
              _buildPrimaryButton('Open Studio', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DrawingPadScreen(initialColors: _generatedColors),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAppBar() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.accentPink,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child:
                    const Icon(Icons.palette, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'COLOR HARMONY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                color: cs.onSurface.withValues(alpha:0.7),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SavedPalettesScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.accessibility_outlined),
                color: cs.onSurface.withValues(alpha:0.7),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AccessibilityCheckerScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Nav Button Helpers ───────────────────────────────────────────────────

  Widget _buildNavButton(String text, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return BrutalistButton(
      onPressed: onPressed,
      color: AppConstants.accentCyan,
      child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }

  // ─── Hero Section ─────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    final cs = Theme.of(context).colorScheme;
    final pad = _isDesktop(context) ? 80.0 : 40.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 32),
      child: SlideTransition(
        position: _heroSlideAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left copy
            Expanded(
              flex: _isDesktop(context) ? 5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Beautiful\nColor Palettes',
                    style: TextStyle(
                      fontSize: _isDesktop(context) ? 52 : 36,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Design stunning colour combinations with harmony algorithms. From drawing pads to pattern creators — everything you need.',
                    style: TextStyle(
                      fontSize: _isDesktop(context) ? 17 : 14,
                      color: cs.onSurface.withValues(alpha:0.55),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildHeroButton('Start Drawing', Icons.brush, true, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DrawingPadScreen(
                                initialColors: _generatedColors),
                          ),
                        );
                      }),
                      const SizedBox(width: 14),
                      _buildHeroButton(
                          'View Gallery', Icons.photo_library, false, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SavedPalettesScreen()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
            if (_isDesktop(context)) ...[
              const SizedBox(width: 56),
              Expanded(
                flex: 4,
                child: _buildLivePaletteHero(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Live colour palette hero — shows the currently generated palette as tall
  /// swatches, replacing the "floating circles on gradient" approach.
  Widget _buildLivePaletteHero() {
    if (_generatedColors.isEmpty) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      height: 360,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: AppConstants.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: Offset(AppConstants.shadowOffset, AppConstants.shadowOffset),
          ),
        ],
      ),
      child: ClipRect(
        child: Row(
          children: _generatedColors.asMap().entries.map((entry) {
            final i = entry.key;
            final color = entry.value;
            final isLast = i == _generatedColors.length - 1;
            return Expanded(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(
                      ClipboardData(text: ColorUtils.colorToHex(color)));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Copied ${ColorUtils.colorToHex(color)}'),
                    backgroundColor: color,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border(
                      right: isLast ? BorderSide.none : const BorderSide(color: Colors.black, width: AppConstants.borderWidth),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          ColorUtils.colorToHex(color),
                          style: TextStyle(
                            color:
                                ColorUtils.getContrastingTextColor(color),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
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

  Widget _buildHeroButton(
      String text, IconData icon, bool isPrimary, VoidCallback onPressed) {
    return BrutalistButton(
      onPressed: onPressed,
      color: isPrimary ? AppConstants.accentPink : Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black, size: 18),
          const SizedBox(width: 10),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mobile Hero Strip ────────────────────────────────────────────────────

  Widget _buildMobileHeroStrip() {
    if (_generatedColors.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Palette',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha:0.45),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _viewPaletteDetails,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _selectedColor.withValues(alpha:0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: _generatedColors.asMap().entries.map((entry) {
                  final i = entry.key;
                  final color = entry.value;
                  final isFirst = i == 0;
                  final isLast = i == _generatedColors.length - 1;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                            ClipboardData(text: ColorUtils.colorToHex(color)));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Copied ${ColorUtils.colorToHex(color)}'),
                          backgroundColor: color,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.only(
                            topLeft: isFirst
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomLeft: isFirst
                                ? const Radius.circular(16)
                                : Radius.zero,
                            topRight: isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ColorUtils.colorToHex(color),
                            style: TextStyle(
                              color: ColorUtils.getContrastingTextColor(color),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Recent Colors Strip ──────────────────────────────────────────────────

  Widget _buildRecentColorsStrip() {
    if (_recentColors.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final pad = _isDesktop(context)
        ? 80.0
        : _isTablet(context)
            ? 40.0
            : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: pad == 0 ? AppConstants.paddingMedium : 0,
                bottom: 10),
            child: Text(
              'Recent Colors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha:0.45),
                letterSpacing: 1.1,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                  left: pad == 0 ? AppConstants.paddingMedium : 0,
                  right: pad == 0 ? AppConstants.paddingMedium : 0),
              itemCount: _recentColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final color = _recentColors[i];
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedColor = color;
                    });
                    _generateColors();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.black, width: isSelected ? 3 : 2),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: Colors.black,
                                blurRadius: 0,
                                offset: Offset(3, 3),
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check,
                            color: ColorUtils.getContrastingTextColor(color),
                            size: 16)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Features Section ─────────────────────────────────────────────────────

  Widget _buildFeaturesSection() {
    final cs = Theme.of(context).colorScheme;
    final pad = _isDesktop(context) ? 80.0 : 40.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Studio Tools',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a tool and get creating',
            style: TextStyle(
                fontSize: 14, color: cs.onSurface.withValues(alpha:0.5)),
          ),
          const SizedBox(height: 28),
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _isDesktop(context) ? 1.4 : 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return _buildFeatureCard(
          title: f['title'] as String,
          subtitle: f['subtitle'] as String,
          icon: f['icon'] as IconData,
          color: f['color'] as Color,
          onTap: f['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BrutalistButton(
      onPressed: onTap,
      color: color,
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icon, size: 100, color: Colors.black.withValues(alpha:0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Icon(icon, size: 28, color: Colors.black),
              ),
              const Spacer(),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // For mobile: smaller card list
  Widget _buildMainFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Studio Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
          childAspectRatio: 1.1,
          children: _getFeatureData().map((f) {
            return _buildFeatureCard(
              title: f['title'] as String,
              subtitle: f['subtitle'] as String,
              icon: f['icon'] as IconData,
              color: f['color'] as Color,
              onTap: f['onTap'] as VoidCallback,
            );
          }).toList(),
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
        'color': const Color(0xFF10b981),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DrawingPadScreen(initialColors: _generatedColors),
              ),
            ),
      },
      {
        'title': 'Pattern Creator',
        'subtitle': 'Design beautiful repeating patterns',
        'icon': Icons.grid_4x4,
        'color': const Color(0xFF8b5cf6),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatternCreatorScreen(initialColors: _generatedColors),
              ),
            ),
      },
      {
        'title': 'Extract Colors',
        'subtitle': 'Pull palettes from any image',
        'icon': Icons.image_search,
        'color': const Color(0xFF06b6d4),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ImageColorExtractorScreen()),
            ),
      },
      {
        'title': 'Edit Palette',
        'subtitle': 'Fine-tune your colour combinations',
        'icon': Icons.tune,
        'color': const Color(0xFFFFD600), // Bright yellow instead of black
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaletteGeneratorScreen(
                  initialColors: _generatedColors,
                  harmonyType: _selectedHarmony,
                ),
              ),
            ),
      },
      {
        'title': 'Palette Details',
        'subtitle': 'HEX, RGB, HSL & export options',
        'icon': Icons.info_outline,
        'color': const Color(0xFFf59e0b),
        'onTap': _viewPaletteDetails,
      },
      {
        'title': 'Saved Palettes',
        'subtitle': 'Browse your saved colour collections',
        'icon': Icons.bookmark_outline,
        'color': const Color(0xFFef4444),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SavedPalettesScreen())),
      },
    ];
  }

  // ─── Colour Generator Section ──────────────────────────────────────────────

  Widget _buildColorGeneratorSection() {
    final cs = Theme.of(context).colorScheme;
    final pad = _isDesktop(context) ? 80.0 : 40.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colour Generator',
            style: TextStyle(
              fontSize: _isDesktop(context) ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a base colour and harmony type',
            style: TextStyle(
                fontSize: 14, color: cs.onSurface.withValues(alpha:0.5)),
          ),
          const SizedBox(height: 28),
          _buildColorGenerator(isCompact: false),
        ],
      ),
    );
  }

  Widget _buildColorGenerator({required bool isCompact}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(
        maxWidth: _isDesktop(context) ? 800 : double.infinity,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        border: Border.all(color: Colors.black, width: AppConstants.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: Offset(AppConstants.shadowOffset, AppConstants.shadowOffset),
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
                      'Colour Wheel',
                      style: TextStyle(
                        fontSize: isCompact ? 17 : 22,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to select a base colour',
                      style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha:0.5)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shuffle_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedColor = ColorService.generateRandomColor();
                    _selectedHarmony = HarmonyType.values[
                        DateTime.now().millisecond %
                            HarmonyType.values.length];
                  });
                  _generateColors();
                },
                style: IconButton.styleFrom(
                  backgroundColor: _selectedColor.withValues(alpha:0.12),
                  foregroundColor: _selectedColor,
                ),
                tooltip: 'Random palette',
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: isCompact ? 190 : 260,
                    height: isCompact ? 190 : 260,
                    child: ColorWheel(
                      onColorSelected: (color) {
                        setState(() => _selectedColor = color);
                        _generateColors();
                      },
                      selectedColor: _selectedColor,
                      size: isCompact ? 190 : 260,
                    ),
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 36),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harmony Type',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface)),
                      const SizedBox(height: 12),
                      _buildHarmonySelector(),
                      const SizedBox(height: 24),
                      Text('Generated Palette',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface)),
                      const SizedBox(height: 12),
                      _buildPalettePreview(),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 20),
            _buildHarmonySelector(),
            const SizedBox(height: 20),
            _buildPalettePreview(),
          ],
        ],
      ),
    );
  }
  Widget _buildHarmonySelector() {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _showHarmonySelectorModal,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                ColorHarmony.harmonies
                    .firstWhere((h) => h.type == _selectedHarmony)
                    .icon,
                color: _selectedColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ColorHarmony.harmonies
                    .firstWhere((h) => h.type == _selectedHarmony)
                    .name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: _selectedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPalettePreview() {
    return InkWell(
      onTap: _viewPaletteDetails,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: ClipRect(
          child: Row(
            children: _generatedColors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;
              final isLast = index == _generatedColors.length - 1;
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border(
                      right: isLast ? BorderSide.none : const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ColorUtils.colorToHex(color),
                      style: TextStyle(
                        color: ColorUtils.getContrastingTextColor(color),
                        fontSize: 10,
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

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop(context) ? 80 : 40,
        vertical: 32,
      ),
      child: Center(
        child: Text(
          'Crafted by Akshat Singh',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha:0.35),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}