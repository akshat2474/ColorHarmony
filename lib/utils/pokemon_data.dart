import 'package:flutter/material.dart';
import '../models/move_model.dart';
import '../models/pokemon_model.dart';

class PokemonData {
  static const Move tackle =  Move(name: 'Tackle', type: MoveType.normal, animationType: AnimationType.physical, power: 20, icon: Icons.sports_mma);
  static const Move growl =  Move(name: 'Growl', type: MoveType.normal, animationType: AnimationType.status, power: 0, icon: Icons.record_voice_over);
  static const Move ember = Move(name: 'Ember', type: MoveType.fire, animationType: AnimationType.projectile, power: 25, icon: Icons.local_fire_department);
  static const Move flameBurst =  Move(name: 'Flame Burst', type: MoveType.fire, animationType: AnimationType.projectile, power: 35, icon: Icons.whatshot);
  static const Move waterGun = Move(name: 'Water Gun', type: MoveType.water, animationType: AnimationType.projectile, power: 25, icon: Icons.water_drop);
  static const Move bubble =  Move(name: 'Bubble', type: MoveType.water, animationType: AnimationType.projectile, power: 20, icon: Icons.bubble_chart);

  static Pokemon charmander = Pokemon(
    name: 'Charmander',
    type: PokemonType.fire,
    maxHealth: 100,
    moves: [tackle, growl, ember, flameBurst],
    color: Colors.deepOrangeAccent,
    secondaryColor: Colors.orange,
    spriteAssetPath: 'assets/svg/charmander.svg',
  );

  static Pokemon squirtle = Pokemon(
    name: 'Squirtle',
    type: PokemonType.water,
    maxHealth: 100,
    moves: [tackle, growl, waterGun, bubble],
    color: Colors.lightBlue,
    secondaryColor: Colors.blue.shade200,
    spriteAssetPath: 'assets/svg/squirtle.svg',
  );
}
