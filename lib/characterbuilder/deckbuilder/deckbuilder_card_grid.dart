import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/widgets/card_widget.dart';
import 'package:card_game/characterbuilder/deckbuilder/models/deckbuilder_state.dart';


class DeckBuilderCardGrid extends StatelessWidget {
  final List<CardData> availableCards;
  final DeckBuilderState deckState;
  final Function(int, bool) onCardQuantityChanged;
  final int? hoveredIndex;
  final Function(int?) onHoverChanged;

  const DeckBuilderCardGrid({
    super.key,
    required this.availableCards,
    required this.deckState,
    required this.onCardQuantityChanged,
    this.hoveredIndex,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortedCards = deckState.getSortedCards(availableCards);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: sortedCards.length,
      itemBuilder: (context, index) {
        final card = sortedCards[index];
        final qty = deckState.cardQuantities[card.id] ?? 0;
        final exceededLimit = qty > card.max;

        return MouseRegion(
          onEnter: (_) => onHoverChanged(index),
          onExit: (_) => onHoverChanged(null),
          child: Card(
            elevation: 3,
            color: exceededLimit ? Colors.pink[50] : Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GameCard(
                    cardData: card,
                    isSelected: false,
                    onTap: () {},
                    isHovered: hoveredIndex == index,
                  ),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: exceededLimit 
                      ? Border(top: BorderSide(color: Colors.pink[300]!, width: 2))
                      : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: qty > 0
                            ? () => onCardQuantityChanged(card.id, false)
                            : null,
                      ),
                      Text(
                        '$qty/${card.max}',
                        style: TextStyle(
                          color: exceededLimit ? Colors.pink[700] : null,
                          fontWeight: exceededLimit ? FontWeight.bold : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        // Removed the qty < card.max condition
                        onPressed: () => onCardQuantityChanged(card.id, true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}