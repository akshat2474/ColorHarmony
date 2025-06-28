import 'move_model.dart';
import 'package:flutter/material.dart';

enum PokemonType { fire, water, grass, normal }

class Pokemon {
  final String name;
  final PokemonType type;
  final int maxHealth;
  final List<Move> moves;
  final Color color;
  final Color secondaryColor;
  final String spriteAssetPath;

  int currentHealth;

  Pokemon({
    required this.name,
    required this.type,
    required this.maxHealth,
    required this.moves,
    required this.color,
    required this.secondaryColor,
    required this.spriteAssetPath, 
  }) : currentHealth = maxHealth;

  Pokemon.clone(Pokemon pokemon)
      : this(
          name: pokemon.name,
          type: pokemon.type,
          maxHealth: pokemon.maxHealth,
          moves: pokemon.moves,
          color: pokemon.color,
          secondaryColor: pokemon.secondaryColor,
          spriteAssetPath: pokemon.spriteAssetPath, 
        );
}
