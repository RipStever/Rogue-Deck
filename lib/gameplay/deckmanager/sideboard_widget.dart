// lib/gameplay/deckmanager/components/sideboard_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_provider.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/chance_card_data.dart';  // Add this import
import 'package:card_game/universal/widgets/card_widget.dart';
import 'package:card_game/universal/widgets/chance_card_widget.dart';
import 'deck_area_widget.dart';

class SideboardWidget extends ConsumerWidget {
  const SideboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    final actionCount = gameState.actionSideboard.length;
    final chanceCount = gameState.chanceSideboard.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sideboards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Make the deck area take remaining space to match other deck areas
          Expanded(
            child: Center(
              child: Column(
                // Use standard spacing to match other decks
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Chance Sideboard Deck - Now using DeckAreaWidget for consistency
                  DeckAreaWidget(
                    title: 'Chance Sideboard',
                    count: chanceCount,
                    onTap: () {
                      if (chanceCount > 0) {
                        _showSideboardDialog(context, ref, 'Chance', gameState.chanceSideboard);
                      }
                    },
                    deckType: DeckType.sideboard,
                    customColor: Colors.purple,
                  ),
                  
                  // Standard spacing between decks (match deckmanagercolumn.dart)
                  const SizedBox(height: 12), 
                  
                  // Action Sideboard Deck - Now using DeckAreaWidget for consistency
                  DeckAreaWidget(
                    title: 'Action Sideboard',
                    count: actionCount,
                    onTap: () {
                      if (actionCount > 0) {
                        _showSideboardDialog(context, ref, 'Action', gameState.actionSideboard);
                      }
                    },
                    deckType: DeckType.sideboard,
                    customColor: Colors.blue[700],  // Use blue for action sideboard
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSideboardDialog(
    BuildContext context,
    WidgetRef ref,
    String type,
    List<CardData> cards,
  ) {
    // Create a local copy of the cards for immediate UI updates
    List<CardData> localCards = List.from(cards);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('$type Sideboard (${localCards.length} cards)', 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey[900],
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          content: SizedBox(
            width: 650,
            height: 500, 
            child: localCards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards in sideboard',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: type == 'Action' ? 0.65 : 2/3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: localCards.length,
                    itemBuilder: (context, index) {
                      final card = localCards[index];
                      return Stack(
                        children: [
                          // Card container with proper sizing
                          Center(
                            child: _buildCardWidget(card, type),
                          ),
                          
                          // Menu button with PopupMenuButton
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30),
                              ),
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Colors.grey[850],
                                itemBuilder: (BuildContext context) => [
                                  // Move to Hand Option
                                  const PopupMenuItem<String>(
                                    value: 'move_to_hand',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.pan_tool, 
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Move to Hand',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Discard Option
                                  const PopupMenuItem<String>(
                                    value: 'discard',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline, 
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Discard Card',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (String value) {
                                  // Update local state first for immediate UI change
                                  setState(() {
                                    localCards.remove(card);
                                  });
                                  
                                  // Then update the app state
                                  if (value == 'move_to_hand') {
                                    ref.read(gameplayProvider.notifier).moveFromSideboardToHand(card, type);
                                  } else if (value == 'discard') {
                                    ref.read(gameplayProvider.notifier).removeFromSideboard(card, type);
                                  }
                                  
                                  // If last card removed, close dialog
                                  if (localCards.isEmpty) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the appropriate card widget
  Widget _buildCardWidget(CardData card, String type) {
    if (card.category == 'Chance') {
      // For chance cards - keep normal rendering
      return SizedBox(
        width: 200,
        height: 300,
        child: ChanceCardWidget(
          cardData: card is ChanceCardData 
            ? card 
            : ChanceCardData(
                id: card.id,
                name: card.name,
                type: card.type,
                effect: card.effect,
                qty: 1,
                uuid: card.uuid ?? 'sb_${card.id}_${DateTime.now().millisecondsSinceEpoch}',
              ),
          isHovered: false,
          isSelected: false,
          onTap: () {},
        ),
      );
    } else {
      // For action cards - IMPORTANT: Pass isHovered: true to make it appear expanded
      return SizedBox(
        // Match expanded card dimensions from hand zone
        width: 200,   // Same as hoveredCardWidth in HandSection
        height: 280,  // Same as hoveredCardHeight in HandSection
        child: GameCard(
          cardData: card,
          isHovered: true,  // This is the key change - force expanded state
          isSelected: false,
          onTap: () {},
        ),
      );
    }
  }
}