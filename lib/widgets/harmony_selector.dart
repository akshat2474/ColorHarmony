import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/color_harmony.dart';
import '../utils/constants.dart';

class HarmonySelector extends StatefulWidget {
  final HarmonyType selectedHarmony;
  final Function(HarmonyType) onHarmonySelected;

  const HarmonySelector({
    super.key,
    required this.selectedHarmony,
    required this.onHarmonySelected,
  });

  @override
  State<HarmonySelector> createState() => _HarmonySelectorState();
}

class _HarmonySelectorState extends State<HarmonySelector>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: const BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            const Text(
              'Choose Color Harmony',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            const Text(
              'Select a harmony type to generate beautiful color combinations',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: AppConstants.animationMedium,
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: ColorHarmony.harmonies.map((harmony) {
                    final isSelected = harmony.type == widget.selectedHarmony;
                    
                    return AnimatedContainer(
                      duration: AppConstants.animationFast,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppConstants.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: isSelected
                            ? Border.all(color: AppConstants.primaryColor, width: 2)
                            : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppConstants.primaryColor
                                : AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Icon(
                            harmony.icon,
                            color: isSelected 
                                ? Colors.white
                                : AppConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          harmony.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected 
                                ? AppConstants.primaryColor 
                                : AppConstants.textPrimary,
                            fontSize: AppConstants.fontSizeLarge,
                          ),
                        ),
                        subtitle: Text(
                          harmony.description,
                          style: const TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppConstants.primaryColor,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: AppConstants.textSecondary,
                              ),
                        onTap: () {
                          widget.onHarmonySelected(harmony.type);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
          ],
        ),
      ),
    );
  }
}
