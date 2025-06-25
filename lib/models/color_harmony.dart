import 'package:flutter/material.dart';

enum HarmonyType {
  complementary,
  analogous,
  triadic,
  tetradic,
  splitComplementary,
  monochromatic,
}

class ColorHarmony {
  final HarmonyType type;
  final String name;
  final String description;
  final IconData icon;

  const ColorHarmony({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });

  static const List<ColorHarmony> harmonies = [
    ColorHarmony(
      type: HarmonyType.complementary,
      name: 'Complementary',
      description: 'Colors opposite on the color wheel',
      icon: Icons.compare_arrows,
    ),
    ColorHarmony(
      type: HarmonyType.analogous,
      name: 'Analogous',
      description: 'Colors adjacent on the color wheel',
      icon: Icons.linear_scale,
    ),
    ColorHarmony(
      type: HarmonyType.triadic,
      name: 'Triadic',
      description: 'Three colors evenly spaced',
      icon: Icons.change_history,
    ),
    ColorHarmony(
      type: HarmonyType.tetradic,
      name: 'Tetradic',
      description: 'Four colors forming a rectangle',
      icon: Icons.crop_square,
    ),
    ColorHarmony(
      type: HarmonyType.splitComplementary,
      name: 'Split Complementary',
      description: 'Base color plus two adjacent to complement',
      icon: Icons.call_split,
    ),
    ColorHarmony(
      type: HarmonyType.monochromatic,
      name: 'Monochromatic',
      description: 'Variations of a single hue',
      icon: Icons.gradient,
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name,
      'description': description,
    };
  }

  factory ColorHarmony.fromJson(Map<String, dynamic> json) {
    final type = HarmonyType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => HarmonyType.analogous,
    );
    
    return harmonies.firstWhere(
      (h) => h.type == type,
      orElse: () => harmonies.first,
    );
  }
}
