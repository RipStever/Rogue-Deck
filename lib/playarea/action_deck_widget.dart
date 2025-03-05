import 'package:flutter/material.dart';

class ActionDeckWidget extends StatelessWidget {
  final int deckSize;
  final VoidCallback onDraw;

  const ActionDeckWidget({
    super.key,
    required this.deckSize,
    required this.onDraw,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onDraw, // Ensure this triggers the updated draw logic in the parent widget
        child: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            deckSize.toString(), // Display the current number of cards in the deck
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
