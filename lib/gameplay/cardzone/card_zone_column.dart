// lib/gameplay/cardzone/card_zone_column.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Adjust these imports as needed
import 'played_cards_main.dart';
import 'hero_actions_section.dart';
import 'hand_section.dart'; // This brings in HandSectionParent, HandSection

class CardZoneColumn extends ConsumerWidget {
  const CardZoneColumn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.all(8.0),
      // Remove `const` from the Column so we can set crossAxisAlignment
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // fill horizontal space
        children: [
          // Play Area Section (Top)
          Expanded(
            flex: 2,
            child: PlayAreaSection(),
          ),

          SizedBox(height: 8),

          // Hero Actions Section (Middle)
          Expanded(
            flex: 3,
            child: HeroActionsSection(),
          ),

          SizedBox(height: 8),

          // Hand Section (Bottom) - our new parent wrapper
          Expanded(
            flex: 3,
            child: HandSectionParent(),
          ),
        ],
      ),
    );
  }
}
