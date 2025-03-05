import 'package:flutter/material.dart';

class EndTurnButton extends StatelessWidget {
  final VoidCallback onEndTurn;

  const EndTurnButton({super.key, required this.onEndTurn});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onEndTurn,
      child: const Text('End Turn'),
    );
  }
}
