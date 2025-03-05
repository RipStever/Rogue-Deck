// lib/gameplay/cardzone/pcard_zone_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'card_zone_ability_type_toggle_buttons.dart';
import 'hand_size_control.dart';
import 'card_zone_actions_counter.dart';
import '../gameplay_provider.dart';

class PlayAreaGameStateBar extends ConsumerWidget {
  const PlayAreaGameStateBar({super.key});

  Future<void> _handleEndTurn(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(gameplayProvider.notifier);

    notifier.endTurn();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    final notifier = ref.read(gameplayProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          // Undo Button
          TextButton.icon(
            onPressed: () => notifier.undoLastAction(),
            icon: const Icon(Icons.undo, size: 16, color: Colors.white70),
            label: Text(
              'Undo (${gameState.actionHistory.length})',
              style: const TextStyle(color: Colors.white70),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),

          const SizedBox(width: 8),

          // End Turn Button and Ability Filters
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _handleEndTurn(context, ref),
                icon: const Icon(Icons.rotate_right, size: 16),
                label: const Text('End Turn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),

              const SizedBox(width: 8),
              const AbilityTypeToggleButtons(),
            ],
          ),

          const Spacer(),

          const HandSizeControl(),

          const SizedBox(width: 16),

          const ActionsCounter(),
        ],
      ),
    );
  }
}