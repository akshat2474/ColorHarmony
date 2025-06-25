import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorUtils {
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  static Map<String, int> colorToRgb(Color color) {
    return {
      'r': color.red,
      'g': color.green,
      'b': color.blue,
    };
  }

  static Map<String, double> colorToHsl(Color color) {
    final hsl = HSLColor.fromColor(color);
    return {
      'h': hsl.hue,
      's': hsl.saturation,
      'l': hsl.lightness,
    };
  }

  static Map<String, double> colorToHsv(Color color) {
    final hsv = HSVColor.fromColor(color);
    return {
      'h': hsv.hue,
      's': hsv.saturation,
      'v': hsv.value,
    };
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

  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }

  static Color blendColors(Color color1, Color color2, double ratio) {
    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    
    return Color.fromARGB(255, r, g, b);
  }

  static List<Color> generateShades(Color baseColor, int count) {
    final shades = <Color>[];
    final hsl = HSLColor.fromColor(baseColor);
    
    for (int i = 0; i < count; i++) {
      final lightness = (i / (count - 1)) * 0.8 + 0.1; // Range from 0.1 to 0.9
      shades.add(hsl.withLightness(lightness).toColor());
    }
    
    return shades;
  }

  static Color generateRandomColor() {
    final random = math.Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  static double getColorDistance(Color color1, Color color2) {
    final r1 = color1.red;
    final g1 = color1.green;
    final b1 = color1.blue;
    final r2 = color2.red;
    final g2 = color2.green;
    final b2 = color2.blue;
    
    return math.sqrt(
      math.pow(r2 - r1, 2) + math.pow(g2 - g1, 2) + math.pow(b2 - b1, 2)
    );
  }

  static String getColorName(Color color) {
    final colorNames = {
      Colors.red: 'Red',
      Colors.pink: 'Pink',
      Colors.purple: 'Purple',
      Colors.deepPurple: 'Deep Purple',
      Colors.indigo: 'Indigo',
      Colors.blue: 'Blue',
      Colors.lightBlue: 'Light Blue',
      Colors.cyan: 'Cyan',
      Colors.teal: 'Teal',
      Colors.green: 'Green',
      Colors.lightGreen: 'Light Green',
      Colors.lime: 'Lime',
      Colors.yellow: 'Yellow',
      Colors.amber: 'Amber',
      Colors.orange: 'Orange',
      Colors.deepOrange: 'Deep Orange',
      Colors.brown: 'Brown',
      Colors.grey: 'Grey',
      Colors.blueGrey: 'Blue Grey',
      Colors.black: 'Black',
      Colors.white: 'White',
    };
    Color? closestColor;
    double minDistance = double.infinity;
    
    for (final namedColor in colorNames.keys) {
      final distance = getColorDistance(color, namedColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = namedColor;
      }
    }
    
    return colorNames[closestColor] ?? 'Unknown';
  }
}
