import 'package:flutter/material.dart';

enum MoveType { normal, fire, water, grass }
enum AnimationType { physical, projectile, status }

class Move {
  final String name;
  final MoveType type;
  final AnimationType animationType;
  final int power;
  final IconData icon;

  const Move({
    required this.name,
    required this.type,
    required this.animationType,
    required this.power,
    required this.icon,
  });
}
