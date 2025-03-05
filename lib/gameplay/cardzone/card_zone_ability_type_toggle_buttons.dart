// lib/gameplay/cardzone/card_zone_ability_type_toggle_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_provider.dart';

class AbilityTypeToggleButtons extends ConsumerWidget {
  const AbilityTypeToggleButtons({super.key});

  Widget _buildToggleButton({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: compact ? 10 : 12,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    final notifier = ref.read(gameplayProvider.notifier);

    return SizedBox(
      height: 40, // Match button height
      child: Row(
        children: [
          _buildToggleButton(
            label: 'All Ability Types',
            value: gameState.showAllTypes,
            onChanged: (value) => notifier.setShowAllTypes(value),
            color: Colors.blue[400]!,
            compact: true,
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            label: 'All Ability Tiers',
            value: gameState.showAllTiers,
            onChanged: (value) => notifier.setShowAllTiers(value),
            color: Colors.purple[400]!,
            compact: true,
          ),
        ],
      ),
    );
  }
}