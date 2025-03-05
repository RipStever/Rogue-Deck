// lib/gameplay/cardzone/hand_size_control.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_provider.dart';

class HandSizeControl extends ConsumerWidget {
  const HandSizeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    final notifier = ref.read(gameplayProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue[400]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.dashboard, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          const Text(
            'Max Hand Size: ',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '${gameState.maxHandSize}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => notifier.decrementMaxHandSize(),
            child: const Icon(Icons.remove_circle_outline, 
              size: 16, 
              color: Colors.white70
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => notifier.incrementMaxHandSize(),
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