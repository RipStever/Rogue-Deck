import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deck_dialog_chance.dart'; // Import the new Chance Deck Dialog
import 'deck_dialog_action.dart'; // Import the new Action Deck Dialog

// Adjust these imports as needed
import '../gameplay_provider.dart';
import 'deck_area_widget.dart';
import 'sideboard_widget.dart';
import '../../universal/welcome_screen.dart';
import 'discard_dialog_chance.dart'; 
import 'discard_dialog_action.dart'; 

class DeckManagerColumn extends ConsumerWidget {
  const DeckManagerColumn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameplayProvider);

    return Stack(
      children: [
        Container(
          color: Colors.grey[850],
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Back to Menu Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => WelcomeScreen(
                        initialSelectedCharacter: gameState.characterModel?.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
              const SizedBox(height: 12),

              // Chance Deck
              Stack(
                children: [
                  DeckAreaWidget(
                    title: 'Chance Deck',
                    count: gameState.chanceDeck.length,
                    topCard: gameState.chanceDeck.isNotEmpty ? gameState.chanceDeck.last : null,
                    onTap: () => ref.read(gameplayProvider.notifier).deckManager.drawChanceCard(),
                    deckType: DeckType.chance,
                  ),
                  Positioned(
                    bottom: 1, // Controls how far the icon is from the bottom
                    right: 1, // Controls how far the icon is from the right
                    child: IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ChanceDeckDialog(
                            deckPile: gameState.chanceDeck,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Add to Hand Button
              ElevatedButton(
                onPressed: gameState.chanceDeck.isNotEmpty
                    ? () => ref.read(gameplayProvider.notifier).deckManager.moveTopChanceCardToHand()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 184, 24, 24),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Add to Hand'),
              ),
              const SizedBox(height: 12),

              // Chance Discard
              DeckAreaWidget(
                title: 'Chance Discard',
                count: gameState.chanceDiscard.length,
                topCard: gameState.chanceDiscard.isNotEmpty ? gameState.chanceDiscard.last : null,
                onTap: () {
                  if (gameState.chanceDiscard.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => ChanceDiscardDialog(
                        discardPile: gameState.chanceDiscard,
                        onReshuffle: () => ref.read(gameplayProvider.notifier).deckManager.shuffleChanceDiscard(),
                      ),
                    );
                  }
                },
                deckType: DeckType.chanceDiscard,
              ),
              const SizedBox(height: 12),

              // Action Deck
              Stack(
                children: [
                  DeckAreaWidget(
                    title: 'Action Deck',
                    count: gameState.actionDeck.length,
                    topCard: gameState.actionDeck.isNotEmpty ? gameState.actionDeck.last : null,
                    onTap: () => ref.read(gameplayProvider.notifier).deckManager.drawActionCard(),
                    deckType: DeckType.action,
                  ),
                  Positioned(
                    bottom: 1, // Controls how far the icon is from the bottom
                    right: 1, // Controls how far the icon is from the right
                    child: IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ActionDeckDialog(
                            deckPile: gameState.actionDeck,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Discard
              DeckAreaWidget(
                title: 'Action Discard',
                count: gameState.actionDiscard.length,
                topCard: gameState.actionDiscard.isNotEmpty ? gameState.actionDiscard.last : null,
                onTap: () {
                  if (gameState.actionDiscard.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => ActionDiscardDialog(
                        discardPile: gameState.actionDiscard,
                        onReshuffle: () => ref.read(gameplayProvider.notifier).deckManager.shuffleActionDiscard(),
                      ),
                    );
                  }
                },
                deckType: DeckType.actionDiscard,
              ),
              const SizedBox(height: 12),

              // Sideboard
              const Expanded(
                child: SideboardWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
