import 'package:flutter/material.dart';
import '../models/move_model.dart';

class BattleDialogueBox extends StatelessWidget {
  final String text;
  final List<Move>? moves;
  final Function(Move)? onMoveSelected;
  final bool isDisplayingMoves;

  const BattleDialogueBox({
    Key? key,
    required this.text,
    this.moves,
    this.onMoveSelected,
    this.isDisplayingMoves = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A wrapper container to create the thick border effect from the screenshot.
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.all(4), // Padding creates the outer border thickness
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isDisplayingMoves ? _buildMoveSelection() : _buildDialogueText(),
        ),
      ),
    );
  }

  Widget _buildDialogueText() {
    return Center(
      key: const ValueKey('dialogue'),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMoveSelection() {
    return GridView.builder(
      key: const ValueKey('moves'),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4 / 1, // Adjusted ratio for taller buttons
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (moves != null && index < moves!.length) {
          final move = moves![index];
          return ElevatedButton.icon(
            onPressed: () => onMoveSelected?.call(move),
            icon: Icon(move.icon, size: 18),
            label: Text(
              move.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black54, width: 2),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black54, width: 2),
          ),
        );
      },
    );
  }
}
