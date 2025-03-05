// lib/gameplay/cardzone/action_execution_chancedeckwindow.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../deckmanager/deck_area_widget.dart';
import '../../universal/models/action_card_data.dart';
import '../../universal/models/chance_card_data.dart';
import '../gameplay_provider.dart';
import 'chance_sideboard_selection_dialog.dart';
import 'action_sideboard_selection_dialog.dart'; // Add this import

class ChanceDeckWindow extends ConsumerWidget {
  final int chanceDeckCount;
  final List<ChanceCardData> drawnCards;
  final VoidCallback onDraw;
  final VoidCallback onUndo;
  final VoidCallback onAddToHand;
  final Function(List<ChanceCardData>) onSideboardDraw;
  final Function(List<ChanceCardData>) onSideboardToHand;
  // Add callback for Action Sideboard selection
  final Function(CardData)? onActionSideboardSelect;

  const ChanceDeckWindow({
    super.key,
    required this.chanceDeckCount,
    required this.drawnCards,
    required this.onDraw,
    required this.onUndo,
    required this.onAddToHand,
    this.onSideboardDraw = _defaultSideboardDraw,
    this.onSideboardToHand = _defaultSideboardToHand,
    this.onActionSideboardSelect,
  });

  // Default implementations that do nothing
  static void _defaultSideboardDraw(List<ChanceCardData> cards) {}
  static void _defaultSideboardToHand(List<ChanceCardData> cards) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);
    
    // Count total undoable actions
    final totalUndoableActions = drawnCards.length + 
        gameState.actionHistory.where((action) => action.type == 'ADD_CHANCE_TO_HAND').length;
    
    // Check if sideboards have cards
    final hasChanceSideboardCards = gameState.chanceSideboard.isNotEmpty;
    final hasActionSideboardCards = gameState.actionSideboard.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Chance Deck',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Chance Deck
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DeckAreaWidget(
              title: 'Chance Deck',
              count: chanceDeckCount,
              onTap: chanceDeckCount > 0 ? onDraw : () {}, 
              deckType: DeckType.chance,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Add to Hand button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: chanceDeckCount > 0 ? onAddToHand : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Add to Hand'),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Undo button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton(
              onPressed: totalUndoableActions > 0 ? onUndo : null,
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber[800],
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.undo, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Undo ($totalUndoableActions)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Section title for Sideboards
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: Text(
              'Sideboards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Chance Sideboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DeckAreaWidget(
              title: 'Chance Sideboard',
              count: gameState.chanceSideboard.length,
              onTap: () {
                if (hasChanceSideboardCards) {
                  _showChanceSideboardDialog(context, ref, gameState.chanceSideboard);
                }
              },
              deckType: DeckType.sideboard,
              customColor: Colors.purple,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Action Sideboard - new addition
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DeckAreaWidget(
              title: 'Action Sideboard',
              count: gameState.actionSideboard.length,
              onTap: () {
                if (hasActionSideboardCards) {
                  _showActionSideboardDialog(context, ref, gameState.actionSideboard);
                }
              },
              deckType: DeckType.sideboard,
              customColor: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
  
  // Keep existing Chance Sideboard dialog method
  void _showChanceSideboardDialog(
    BuildContext context, 
    WidgetRef ref,
    List<CardData> sideboardCards
  ) {
    // Filter out only cards with category 'Chance' and convert them to ChanceCardData
    final List<ChanceCardData> chanceCards = [];
    
    for (final card in sideboardCards) {
      if (card.category == 'Chance') {
        // If it's already a ChanceCardData, use it directly
        if (card is ChanceCardData) {
          chanceCards.add(card);
        } else {
          // Otherwise, create a new ChanceCardData object
          chanceCards.add(ChanceCardData(
            id: card.id,
            name: card.name,
            type: card.type,
            effect: card.effect,
            qty: 1,
            uuid: card.uuid ?? 'sb_${card.id}_${DateTime.now().millisecondsSinceEpoch}',
          ));
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => ChanceSideboardSelectionDialog(
        sideboardCards: chanceCards, // Use the properly typed list
        onExecute: (drawCards, handCards) {
          // First save references to all selected cards before removal
          final allSelectedCards = [...drawCards, ...handCards];
          
          // Process the selected cards when Execute is clicked
          
          // 1. Remove selected cards from sideboard
          for (final card in allSelectedCards) {
            ref.read(gameplayProvider.notifier).removeFromSideboard(card, 'Chance');
          }
          
          // 2. Add "Draw" cards to drawnCards area using the callback
          if (drawCards.isNotEmpty) {
            onSideboardDraw(drawCards);
          }
          
          // 3. Add "Hand" cards directly to player's hand using the callback
          if (handCards.isNotEmpty) {
            onSideboardToHand(handCards);
          }
          
          // 4. Close the dialog
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context), // Simply close without changes
      ),
    );
  }
  
  // Add new Action Sideboard dialog method
  void _showActionSideboardDialog(
    BuildContext context, 
    WidgetRef ref,
    List<CardData> sideboardCards
  ) {
    // Filter only action cards
    final actionCards = sideboardCards.where((card) => card.category != 'Chance').toList();
    
    showDialog(
      context: context,
      builder: (context) => ActionSideboardSelectionDialog(
        sideboardCards: actionCards,
        onSelect: (selectedCard) {
          // Remove from sideboard
          ref.read(gameplayProvider.notifier).removeFromSideboard(selectedCard, 'Action');
          
          // Call the callback to add to drawn cards
          onActionSideboardSelect?.call(selectedCard);
          
          // Close dialog
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}