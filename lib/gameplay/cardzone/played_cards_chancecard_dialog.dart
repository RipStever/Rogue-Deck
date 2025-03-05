// lib/gameplay/cardzone/played_cards_chancecard_dialog.dart
import 'package:flutter/material.dart';

Future<int?> showChanceCardMoveDialog(BuildContext context, int maxCount) {
  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      int selectedCount = 0;
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Move Chance Cards'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(maxCount + 1, (index) {
                  return RadioListTile<int>(
                    title: Text('Keep $index cards'),
                    value: index,
                    groupValue: selectedCount,
                    onChanged: (value) {
                      setState(() => selectedCount = value!);
                    },
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('npoe'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedCount),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}