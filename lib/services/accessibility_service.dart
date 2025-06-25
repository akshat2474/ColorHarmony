import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/accessibility_result.dart';

class AccessibilityService {
  static AccessibilityResult checkContrast(Color foreground, Color background) {
    final contrastRatio = _calculateContrastRatio(foreground, background);
    
    final passesAA = contrastRatio >= 4.5;
    final passesAAA = contrastRatio >= 7.0;
    
    AccessibilityLevel level;
    String recommendation;
    
    if (contrastRatio >= 7.0) {
      level = AccessibilityLevel.excellent;
      recommendation = 'Excellent contrast! Perfect for all users including those with visual impairments.';
    } else if (contrastRatio >= 4.5) {
      level = AccessibilityLevel.good;
      recommendation = 'Good contrast. Meets WCAG AA standards for normal text.';
    } else if (contrastRatio >= 3.0) {
      level = AccessibilityLevel.fair;
      recommendation = 'Fair contrast. Consider improving for better accessibility, especially for small text.';
    } else {
      level = AccessibilityLevel.poor;
      recommendation = 'Poor contrast. Strongly recommend changing colors to improve readability.';
    }

    return AccessibilityResult(
      contrastRatio: contrastRatio,
      passesAA: passesAA,
      passesAAA: passesAAA,
      recommendation: recommendation,
      level: level,
    );
  }

  static double _calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = _getLuminance(color1);
    final luminance2 = _getLuminance(color2);
    
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _getLuminance(Color color) {
    final r = _getRelativeLuminance(color.red / 255.0);
    final g = _getRelativeLuminance(color.green / 255.0);
    final b = _getRelativeLuminance(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _getRelativeLuminance(double colorValue) {
    if (colorValue <= 0.03928) {
      return colorValue / 12.92;
    } else {
      return math.pow((colorValue + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  static List<String> getAccessibilityTips() {
    return [
      'Use high contrast colors for better readability',
      'Test your color combinations with different lighting conditions',
      'Consider colorblind users when choosing color schemes',
      'Ensure text is readable against background colors',
      'Use tools to verify WCAG compliance',
      'Provide alternative ways to convey information besides color',
    ];
  }
}
