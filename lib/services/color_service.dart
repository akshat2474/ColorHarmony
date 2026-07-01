import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/color_harmony.dart';

class ColorService {
  static List<Color> generateHarmony(Color baseColor, HarmonyType type) {
    final hsl = HSLColor.fromColor(baseColor);
    
    switch (type) {
      case HarmonyType.complementary:
        return _generateComplementary(hsl);
      case HarmonyType.analogous:
        return _generateAnalogous(hsl);
      case HarmonyType.triadic:
        return _generateTriadic(hsl);
      case HarmonyType.tetradic:
        return _generateTetradic(hsl);
      case HarmonyType.splitComplementary:
        return _generateSplitComplementary(hsl);
      case HarmonyType.monochromatic:
        return _generateMonochromatic(hsl);
    }
  }

  static List<Color> _generateComplementary(HSLColor hsl) {
    return [
      hsl.toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
    ];
  }

  static List<Color> _generateAnalogous(HSLColor hsl) {
    return [
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
      hsl.toColor(),
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
    ];
  }

  static List<Color> _generateTriadic(HSLColor hsl) {
    return [
      hsl.toColor(),
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  static List<Color> _generateTetradic(HSLColor hsl) {
    return [
      hsl.toColor(),
      hsl.withHue((hsl.hue + 90) % 360).toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
      hsl.withHue((hsl.hue + 270) % 360).toColor(),
    ];
  }

  static List<Color> _generateSplitComplementary(HSLColor hsl) {
    return [
      hsl.toColor(),
      hsl.withHue((hsl.hue + 150) % 360).toColor(),
      hsl.withHue((hsl.hue + 210) % 360).toColor(),
    ];
  }

  static List<Color> _generateMonochromatic(HSLColor hsl) {
    return [
      hsl.withLightness(0.2).toColor(),
      hsl.withLightness(0.4).toColor(),
      hsl.toColor(),
      hsl.withLightness(0.7).toColor(),
      hsl.withLightness(0.9).toColor(),
    ];
  }

  static Color generateRandomColor() {
    final random = math.Random();
    return HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360,
      0.5 + random.nextDouble() * 0.5,
      0.3 + random.nextDouble() * 0.4,
    ).toColor();
  }

  static List<Color> generateTrendingPalette() {
    final trendingColors = [
      const Color(0xFF6366f1), // Indigo
      const Color(0xFF8b5cf6), // Violet
      const Color(0xFF06b6d4), // Cyan
      const Color(0xFF10b981), // Emerald
      const Color(0xFFf59e0b), // Amber
      const Color(0xFFef4444), // Red
      const Color(0xFFf97316), // Orange
      const Color(0xFF84cc16), // Lime
    ];
    
    final random = math.Random();
    final baseColor = trendingColors[random.nextInt(trendingColors.length)];
    return generateHarmony(baseColor, HarmonyType.analogous);
  }

  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  static Color adjustSaturation(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation * factor).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }

  static List<Color> generateGradientColors(Color startColor, Color endColor, int steps) {
    final colors = <Color>[];
    for (int i = 0; i < steps; i++) {
      final ratio = i / (steps - 1);
      colors.add(Color.lerp(startColor, endColor, ratio)!);
    }
    return colors;
  }
}
