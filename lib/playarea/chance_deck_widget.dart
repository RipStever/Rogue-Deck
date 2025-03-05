import 'package:flutter/material.dart';

class ChanceDeckWidget extends StatelessWidget {
  final int deckSize;
  final VoidCallback onDraw;

  const ChanceDeckWidget({
    super.key,
    required this.deckSize,
    required this.onDraw,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onDraw,
        child: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 155, 13, 32),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            deckSize.toString(),
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