import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';
import '../models/color_harmony.dart';
import '../models/color_palette.dart';
import '../services/palette_storage_service.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';

class PaletteDetailScreen extends StatefulWidget {
  final List<Color> colors;
  final HarmonyType harmonyType;
  final Color baseColor;

  const PaletteDetailScreen({
    super.key,
    required this.colors,
    required this.harmonyType,
    required this.baseColor,
  });

  @override
  State<PaletteDetailScreen> createState() => _PaletteDetailScreenState();
}

class _PaletteDetailScreenState extends State<PaletteDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _nameController = TextEditingController();

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
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final harmonyInfo = ColorHarmony.harmonies
        .firstWhere((h) => h.type == widget.harmonyType);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('PALETTE DETAILS'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePalette,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePalette,
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
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
                  _buildPalettePreview(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildHarmonyInfo(harmonyInfo),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildColorDetails(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildUsageExamples(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildExportPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPalettePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusLarge),
              ),
            ),
            child: Row(
              children: widget.colors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final isFirst = index == 0;
                final isLast = index == widget.colors.length - 1;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _copyColorToClipboard(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.only(
                          topLeft: isFirst ? const Radius.circular(AppConstants.radiusLarge) : Radius.zero,
                          topRight: isLast ? const Radius.circular(AppConstants.radiusLarge) : Radius.zero,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy,
                              color: ColorUtils.getContrastingTextColor(color),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ColorUtils.colorToHex(color),
                              style: TextStyle(
                                color: ColorUtils.getContrastingTextColor(color),
                                fontSize: 14,
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
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                Text(
                  '${widget.colors.length} Color Palette',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap any color to copy its hex code',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarmonyInfo(ColorHarmony harmony) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  harmony.icon,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      harmony.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    Text(
                      harmony.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.baseColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Base Color: ${ColorUtils.colorToHex(widget.baseColor)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDetails() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...widget.colors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            final hsl = ColorUtils.colorToHsl(color);
            final rgb = ColorUtils.colorToRgb(color);
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ColorUtils.colorToHex(color),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'RGB(${rgb['r']}, ${rgb['g']}, ${rgb['b']})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        Text(
                          'HSL(${hsl['h']!.round()}°, ${(hsl['s']! * 100).round()}%, ${(hsl['l']! * 100).round()}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyColorToClipboard(color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUsageExamples() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage Examples',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Web design example
          _buildUsageExample(
            'Web Design',
            widget.colors.length >= 3 ? widget.colors[0] : widget.colors.first,
            widget.colors.length >= 3 ? widget.colors[1] : widget.colors.first,
            widget.colors.length >= 3 ? widget.colors[2] : widget.colors.first,
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Brand example
          _buildBrandExample(),
        ],
      ),
    );
  }

  Widget _buildUsageExample(String title, Color primary, Color secondary, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: secondary,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Header',
                    style: TextStyle(
                      color: ColorUtils.getContrastingTextColor(primary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Area',
                      style: TextStyle(
                        color: ColorUtils.getContrastingTextColor(secondary),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Button',
                        style: TextStyle(
                          color: ColorUtils.getContrastingTextColor(accent),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand Identity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: widget.colors.map((color) {
            return Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    ColorUtils.getColorName(color),
                    style: TextStyle(
                      color: ColorUtils.getContrastingTextColor(color),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Export Panel ──────────────────────────────────────────────────────────

  Widget _buildExportPanel() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: cs.outline.withValues(alpha:0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Palette',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Copy your palette in the format you need',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha:0.5),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildExportButton(
                label: 'CSS Variables',
                icon: Icons.code,
                color: const Color(0xFF667eea),
                onPressed: _exportCSS,
              ),
              _buildExportButton(
                label: 'Flutter',
                icon: Icons.flutter_dash,
                color: const Color(0xFF06b6d4),
                onPressed: _exportFlutter,
              ),
              _buildExportButton(
                label: 'Tailwind',
                icon: Icons.style,
                color: const Color(0xFF10b981),
                onPressed: _exportTailwind,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withValues(alpha:0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportCSS() {
    final buffer = StringBuffer();
    buffer.writeln(':root {');
    for (int i = 0; i < widget.colors.length; i++) {
      final hex = ColorUtils.colorToHex(widget.colors[i]);
      buffer.writeln('  --color-${i + 1}: $hex;');
    }
    buffer.write('}');
    final css = buffer.toString();
    Clipboard.setData(ClipboardData(text: css));
    _showExportSnackBar('CSS custom properties copied!');
  }

  void _exportFlutter() {
    final buffer = StringBuffer();
    buffer.writeln('// Color Harmony — generated palette');
    for (int i = 0; i < widget.colors.length; i++) {
      final hex = widget.colors[i].toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
      buffer.writeln('const Color color${i + 1} = Color(0x$hex);');
    }
    final code = buffer.toString().trim();
    Clipboard.setData(ClipboardData(text: code));
    _showExportSnackBar('Flutter constants copied!');
  }

  void _exportTailwind() {
    final buffer = StringBuffer();
    buffer.writeln('// tailwind.config.js — extend colors');
    buffer.writeln('colors: {');
    buffer.writeln('  harmony: {');
    for (int i = 0; i < widget.colors.length; i++) {
      final hex = ColorUtils.colorToHex(widget.colors[i]);
      buffer.writeln('    \'${i + 1}00\': \'$hex\',');
    }
    buffer.writeln('  },');
    buffer.write('}');
    final config = buffer.toString();
    Clipboard.setData(ClipboardData(text: config));
    _showExportSnackBar('Tailwind config copied!');
  }

  void _showExportSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyColorToClipboard(Color color) {
    final hex = ColorUtils.colorToHex(color);
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: hex));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $hex to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }

  void _sharePalette() {
    final colors = widget.colors.map((c) => ColorUtils.colorToHex(c)).join(', ');
    final harmonyName = ColorHarmony.harmonies
        .firstWhere((h) => h.type == widget.harmonyType)
        .name;
    
    final text = 'Check out this $harmonyName color palette!\nColors: $colors\nCreated with Color Harmony app';
    
    Share.share(text, subject: 'Beautiful Color Palette');
  }

  void _savePalette() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Palette'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Palette Name',
            hintText: 'Enter a name for your palette',
          ),
          maxLength: AppConstants.maxPaletteNameLength,
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
                  colors: widget.colors,
                  harmonyType: widget.harmonyType.toString().split('.').last,
                  createdAt: DateTime.now(),
                );
                
                await PaletteStorageService.savePalette(palette);
                
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Palette saved successfully!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
