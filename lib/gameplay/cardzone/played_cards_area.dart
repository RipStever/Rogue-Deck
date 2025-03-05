// lib/gameplay/cardzone/played_cards_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import '../../universal/models/chance_card_data.dart';
import '../../universal/widgets/card_widget.dart';
import '../../universal/widgets/chance_card_widget.dart';
import '../gameplay_provider.dart';
import 'played_cards_dialog.dart';

class PlayedCardsArea extends ConsumerWidget {
  const PlayedCardsArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playedCards = ref.watch(gameplayProvider).playedCards;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 180, // Add explicit height for the container
      child: Stack(
        children: [
          // Cards display
          playedCards.isEmpty
              ? const Center(
                  child: Text(
                    'No cards played',
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.none, // Allow cards to overflow
                  children: [
                    for (var i = 0; i < playedCards.length; i++)
                      Positioned(
                        left: 8 + (i * 40.0),
                        top: 10, // Add top padding
                        child: SizedBox(
                          width: 120,
                          height: 160,
                          child: _buildPlayedCard(playedCards[i], i),
                        ),
                      ),
                  ],
                ),

          // View icon button
          if (playedCards.isNotEmpty)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  onPressed: () => _showPlayedCardsDialog(context, playedCards),
                  tooltip: 'View all played cards',
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPlayedCardsDialog(BuildContext context, List<CardData> playedCards) {
    showDialog(
      context: context,
      builder: (context) => PlayedCardsDialog(playedCards: playedCards),
    );
  }

  Widget _buildPlayedCard(CardData card, int index) {
    return Stack(
      children: [
        _selectCardWidget(card),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectCardWidget(CardData card) {
    // Check if the card is a Chance Card based on its category
    if (card.category == 'Chance') {
      return SizedBox(
        width: 120,
        height: 160,
        child: ChanceCardWidget(
          cardData: ChanceCardData.fromCardData(card),
          isHovered: false,
          isSelected: false,
          onTap: () {}, // No action needed for played cards
          pulseAnimation: null,
        ),
      );
    }

    // For other card types, use the standard GameCard
    return GameCard(
      cardData: card,
      isSelected: false,
      onTap: () {},
      isHovered: false,
      width: 120,
      height: 160,
    );
  }
}