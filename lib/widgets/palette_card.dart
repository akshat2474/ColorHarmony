import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/color_palette.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

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
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.1),
                    blurRadius: _isPressed ? 15 : 10,
                    offset: Offset(0, _isPressed ? 5 : 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color swatches
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusLarge),
                      ),
                    ),
                    child: Row(
                      children: widget.palette.colors.asMap().entries.map((entry) {
                        final index = entry.key;
                        final color = entry.value;
                        final isFirst = index == 0;
                        final isLast = index == widget.palette.colors.length - 1;
                        
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
                                      color: ColorUtils.getContrastingTextColor(color).withOpacity(0.7),
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
                                widget.palette.name,
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
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
                                      size: 20,
                                      color: widget.isFavorite ? Colors.red : AppConstants.textSecondary,
                                    ),
                                    onPressed: widget.onFavoriteToggle,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.share, size: 20),
                                  onPressed: () => _sharePalette(),
                                  color: AppConstants.textSecondary,
                                ),
                                if (widget.onEdit != null)
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: widget.onEdit,
                                    color: AppConstants.textSecondary,
                                  ),
                                if (widget.onDelete != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
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
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                              ),
                              child: Text(
                                widget.palette.harmonyType,
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeSmall,
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            Text(
                              '${widget.palette.colors.length} colors',
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeSmall,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            Text(
                              _formatDate(widget.palette.createdAt),
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeSmall,
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
        },
      ),
    );
  }

  void _copyColorToClipboard(Color color) {
    final hex = ColorUtils.colorToHex(color);
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
    final colors = widget.palette.colors.map((c) => ColorUtils.colorToHex(c)).join(', ');
    final text = '${widget.palette.name}\nColors: $colors\nCreated with Color Harmony app';
    
    Share.share(text, subject: 'Check out this color palette!');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
