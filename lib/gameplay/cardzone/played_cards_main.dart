// lib/gameplay/cardzone/played_cards_main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'played_cards_area.dart';
import 'card_zone_controls.dart';

class PlayAreaSection extends ConsumerWidget {
  const PlayAreaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Expanded(
            child: PlayedCardsArea(),
          ),
          PlayAreaGameStateBar(),
        ],
      ),
    );
  }
}