import 'package:flutter/material.dart';

class ColorPalette {
  final String id;
  final String name;
  final List<Color> colors;
  final String harmonyType;
  final DateTime createdAt;
  final List<String> tags;

  ColorPalette({
    required this.id,
    required this.name,
    required this.colors,
    required this.harmonyType,
    required this.createdAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colors': colors.map((c) => c.value).toList(),
      'harmonyType': harmonyType,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      colors: (json['colors'] as List<dynamic>?)
          ?.map((c) => Color(c as int))
          .toList() ?? [],
      harmonyType: json['harmonyType'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  ColorPalette copyWith({
    String? id,
    String? name,
    List<Color>? colors,
    String? harmonyType,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return ColorPalette(
      id: id ?? this.id,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      harmonyType: harmonyType ?? this.harmonyType,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}
