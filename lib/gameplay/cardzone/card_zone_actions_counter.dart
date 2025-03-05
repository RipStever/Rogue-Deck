// lib/gameplay/cardzone/card_zone_actions_counter.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_provider.dart';

class ActionsCounter extends ConsumerWidget {
  const ActionsCounter({super.key});

  Color _getActionCounterColor(int actionsPlayed, int maxActions) {
    if (actionsPlayed >= maxActions) return Colors.red[700]!.withOpacity(0.3);
    if (actionsPlayed >= (maxActions / 2).floor()) return Colors.orange[700]!.withOpacity(0.3);
    return Colors.green[700]!.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    final notifier = ref.read(gameplayProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getActionCounterColor(gameState.actionsPlayed, gameState.maxActions),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_martial_arts, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          const Text(
            'Actions: ',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '${gameState.actionsPlayed}/${gameState.maxActions}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => notifier.decrementMaxActions(),
            child: const Icon(Icons.remove_circle_outline, 
              size: 16, 
              color: Colors.white70
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => notifier.incrementMaxActions(),
            child: const Icon(Icons.add_circle_outline, 
              size: 16, 
              color: Colors.white70
            ),
          ),
        ],
      ),
    );
  }
}