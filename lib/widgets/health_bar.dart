// lib/widgets/health_bar.dart
import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';

class HealthBar extends StatelessWidget {
  final Pokemon pokemon;
  final bool isPlayer;

  const HealthBar({
    Key? key,
    required this.pokemon,
    this.isPlayer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double healthPercentage = pokemon.currentHealth / pokemon.maxHealth;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pokemon.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'HP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: healthPercentage,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),
          if (isPlayer) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${pokemon.currentHealth}/${pokemon.maxHealth}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
