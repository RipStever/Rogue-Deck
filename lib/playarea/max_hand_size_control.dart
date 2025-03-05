import 'package:flutter/material.dart';

class MaxHandSizeWidget extends StatelessWidget {
  final int maxHandSize;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const MaxHandSizeWidget({
    super.key,
    required this.maxHandSize,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text(
            'Max Hand Size:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              maxHandSize.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onIncrement,
            child: const Icon(Icons.arrow_drop_up, size: 30),
          ),
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.arrow_drop_down, size: 30),
          ),
        ],
      ),
    );
  }
}
