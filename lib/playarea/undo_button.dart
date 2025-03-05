import 'package:flutter/material.dart';

class UndoButton extends StatelessWidget {
  final VoidCallback onUndo;

  const UndoButton({super.key, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onUndo,
      child: const Text('Undo'),
    );
  }
}
