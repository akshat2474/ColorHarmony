import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/color_palette.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../services/accessibility_service.dart';

class PaletteCard extends StatefulWidget {
  final ColorPalette palette;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const PaletteCard({
    super.key,
    required this.palette,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<PaletteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _isPressed ? AppConstants.shadowOffset + AppConstants.paddingSmall : AppConstants.paddingSmall,
          left: _isPressed ? AppConstants.shadowOffset + AppConstants.paddingMedium : AppConstants.paddingMedium,
          right: AppConstants.paddingMedium,
          bottom: _isPressed ? AppConstants.paddingSmall : AppConstants.shadowOffset + AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          border: Border.all(color: Colors.black, width: AppConstants.borderWidth),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: Offset(AppConstants.shadowOffset, AppConstants.shadowOffset),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color swatches
            SizedBox(
              height: 120,
              child: Row(
                children: widget.palette.colors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final color = entry.value;
                  final isLast = index == widget.palette.colors.length - 1;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _copyColorToClipboard(color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          border: Border(
                            right: isLast ? BorderSide.none : const BorderSide(color: Colors.black, width: AppConstants.borderWidth),
                            bottom: const BorderSide(color: Colors.black, width: AppConstants.borderWidth),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ColorUtils.colorToHex(color),
                                style: TextStyle(
                                  color: ColorUtils.getContrastingTextColor(color),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.copy,
                                color: ColorUtils.getContrastingTextColor(color).withValues(alpha:0.7),
                                size: 16,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.palette.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.w900, // Archivo black-like
                            color: AppConstants.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onFavoriteToggle != null)
                            IconButton(
                              icon: Icon(
                                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 24,
                                color: widget.isFavorite ? Colors.red : AppConstants.textSecondary,
                              ),
                              onPressed: widget.onFavoriteToggle,
                            ),
                          IconButton(
                            icon: const Icon(Icons.share, size: 24),
                            onPressed: () => _sharePalette(),
                            color: AppConstants.textSecondary,
                          ),
                          if (widget.onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 24),
                              onPressed: widget.onEdit,
                              color: AppConstants.textSecondary,
                            ),
                          if (widget.onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 24),
                              onPressed: widget.onDelete,
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.accentCyan,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          widget.palette.harmonyType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Text(
                        '${widget.palette.colors.length} COLORS',
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(width: 8),

                      // WCAG contrast badge
                      _buildContrastBadge(),
                      
                      const Spacer(),
                      
                      Text(
                        _formatDate(widget.palette.createdAt).toUpperCase(),
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyColorToClipboard(Color color) {
    final hex = ColorUtils.colorToHex(color);
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: hex));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('COPIED $hex TO CLIPBOARD'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }

  void _sharePalette() {
    final colors = widget.palette.colors.map((c) => ColorUtils.colorToHex(c)).join(', ');
    final text = '${widget.palette.name}\nColors: $colors\nCreated with Color Harmony app';
    
    Share.share(text, subject: 'Check out this color palette!');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}D AGO';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}H AGO';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}M AGO';
    } else {
      return 'JUST NOW';
    }
  }

  Widget _buildContrastBadge() {
    if (widget.palette.colors.length < 2) return const SizedBox.shrink();

    double worst = double.infinity;
    final colors = widget.palette.colors;
    for (int i = 0; i < colors.length - 1; i++) {
      final result = AccessibilityService.checkContrast(colors[i], colors[i + 1]);
      if (result.contrastRatio < worst) {
        worst = result.contrastRatio;
      }
    }

    late String label;
    late Color bg;

    if (worst >= 7.0) {
      label = 'AAA ✓';
      bg = AppConstants.successColor;
    } else if (worst >= 4.5) {
      label = 'AA ✓';
      bg = AppConstants.accentCyan;
    } else {
      label = '⚠ LOW';
      bg = AppConstants.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
