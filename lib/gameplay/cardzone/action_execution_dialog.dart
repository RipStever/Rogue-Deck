// lib/gameplay/cardzone/action_execution_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../universal/models/action_card_data.dart';
import '../../universal/models/chance_card_data.dart';
import '../../universal/models/hero_ability_card_model.dart';
import '../gameplay_provider.dart';
import '../game_action.dart';  // Add this import
import 'action_execution_actionwindow.dart';
import 'action_execution_chancewindow.dart';
import 'action_execution_chancedeckwindow.dart';

class ActionExecutionDialog extends StatefulWidget {
  final CardData actionCard;
  final HeroAbilityCardModel heroAbility;
  final VoidCallback? onExecute; 
  final VoidCallback onCancel;

  const ActionExecutionDialog({
    super.key,
    required this.actionCard,
    required this.heroAbility,
    this.onExecute,
    required this.onCancel,
  });

  @override
  _ActionExecutionDialogState createState() => _ActionExecutionDialogState();
}

class _ActionExecutionDialogState extends State<ActionExecutionDialog> {
  final List<ChanceCardData> _drawnChanceCards = [];
  final List<ChanceCardData> _chanceCardsToHand = []; // Changed from CardData to ChanceCardData
  
  // Add tracking for cards that came from sideboard
  final List<ChanceCardData> _cardsFromSideboard = [];
  final List<ChanceCardData> _cardsFromChanceSideboard = [];
  // Track if the action card was replaced from sideboard
  CardData? _originalActionCard;
  late CardData _currentActionCard;
  
  // Initialize _currentActionCard in initState
  @override
  void initState() {
    super.initState();
    _currentActionCard = widget.actionCard;
  }

  void _drawChanceCard(WidgetRef ref) {
    final gameState = ref.read(gameplayProvider);
    
    if (gameState.chanceDeck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cards left in the Chance Deck!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final drawnCard = ChanceCardData(
        id: gameState.chanceDeck.last.id,
        name: gameState.chanceDeck.last.name,
        qty: 1,
        type: gameState.chanceDeck.last.type,
        effect: gameState.chanceDeck.last.effect,
        uuid: gameState.chanceDeck.last.uuid,  // Ensure UUID is copied
      );
      _drawnChanceCards.add(drawnCard);
      ref.read(gameplayProvider.notifier).deckManager.drawChanceCardForExecution();
    });
  }

  void _undoChanceCardDraw(WidgetRef ref) {
    if (_drawnChanceCards.isEmpty) return;

    setState(() {
      final cardToReturn = _drawnChanceCards.removeLast();
      ref.read(gameplayProvider.notifier).deckManager.returnChanceCardsToTop([cardToReturn]);
    });
  }

  void _addChanceCardToHand(WidgetRef ref) {
    print("\n=== Staging Chance Card to Hand ===");

    final gameState = ref.read(gameplayProvider);
    if (gameState.chanceDeck.isEmpty) {
      print("⚠ No cards left in the Chance Deck!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cards left in the Chance Deck!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final topCard = gameState.chanceDeck.last;

      // ✅ Ensure UUID stays the same across actions
      final cardToAdd = ChanceCardData(
        id: topCard.id,
        name: topCard.name,
        type: topCard.type,
        effect: topCard.effect,
        qty: 1,
        uuid: topCard.uuid,  // 👈 **Preserve UUID**
      );

      _chanceCardsToHand.add(cardToAdd);

      print("✅ Card Staged for Hand: ${cardToAdd.name} (UUID: ${cardToAdd.uuid})");
      print("🔍 Total Staged: ${_chanceCardsToHand.length}");

      // Remove from chance deck
      ref.read(gameplayProvider.notifier).deckManager.drawChanceCardForExecution();

      // ✅ Store ALL staged cards together in action history, preserving UUIDs
      final newActionHistory = List<GameAction>.from(ref.read(gameplayProvider).actionHistory);
      newActionHistory.add(GameAction(
        'ADD_CHANCE_TO_HAND',
        {'cards': _chanceCardsToHand.map((c) => c.toMap()).toList()},
      ));

      // ✅ Ensure we are using the same instance when moving to `gameState.hand`
      ref.read(gameplayProvider.notifier).state = ref.read(gameplayProvider.notifier).state.copyWith(
        actionHistory: newActionHistory,
      );

      print("🔄 ActionHistory Updated: ${ref.read(gameplayProvider).actionHistory.length} actions");
    });
  }

  void _undoAddChanceCardToHand(WidgetRef ref) {
    print("\n=== Undoing Chance Cards Added to Hand ===");
    final gameState = ref.read(gameplayProvider);

    if (gameState.hand.isEmpty) {
      print("⚠ No chance cards in hand to undo.");
      return;
    }

    // ✅ Ensure last action has a valid "cards" list
    final lastAction = gameState.actionHistory.last;
    if (lastAction.data['cards'] == null || lastAction.data['cards'] is! List) {
      print("🚨 ERROR: lastAction.data['cards'] is null or not a list. Skipping undo.");
      return;
    }

    final cardsToReturn = (lastAction.data['cards'] as List)
        .map((cardMap) => ChanceCardData.fromMap(cardMap as Map<String, dynamic>))
        .toList();

    // ✅ Log hand before removal
    final handUUIDs = gameState.hand.map((c) => c.uuid).toList();
    final removeUUIDs = cardsToReturn.map((c) => c.uuid).toList();

    print("🔍 Hand before undo: $handUUIDs");
    print("🔄 Cards to remove: $removeUUIDs");

    // ✅ Ensure UUID matching is consistent
    for (var card in cardsToReturn) {
      if (!handUUIDs.contains(card.uuid)) {
        print("⚠ ERROR: Card with UUID ${card.uuid} is not found in hand! Possible UUID mismatch.");
      }
    }

    // ✅ Remove ALL recorded cards from hand using `uuid` matching
    final newHand = gameState.hand.where((c) => !removeUUIDs.contains(c.uuid)).toList();

    // ✅ Log hand after removal
    print("🔍 Hand after undo: ${newHand.map((c) => c.uuid).toList()}");

    // Return all cards to chance deck
    final newChanceDeck = [...gameState.chanceDeck, ...cardsToReturn];

    // ✅ Store updated state
    ref.read(gameplayProvider.notifier).state = gameState.copyWith(
      hand: newHand,
      chanceDeck: newChanceDeck,
    );

    print("✅ Undo successful. Cards returned to chance deck: ${cardsToReturn.length}");
  }

  void _handleUndo(WidgetRef ref) {
    final gameState = ref.read(gameplayProvider);
    
    if (gameState.actionHistory.isEmpty) {
      print('⚠ No actions in history to undo.');
      return;
    }

    final lastAction = gameState.actionHistory.last;
    print('🔄 Undoing Last Action: ${lastAction.type}');

    // Get button that was clicked from the call stack
    final trace = StackTrace.current.toString();
    final isAddToHandUndo = trace.contains('Undo Add to Hand');

    if (isAddToHandUndo) {
      if (lastAction.type == 'ADD_CHANCE_TO_HAND') {
        print('🛑 Undoing ADD_CHANCE_TO_HAND');
        _undoAddChanceCardToHand(ref);
      } else {
        print('❌ No ADD_CHANCE_TO_HAND action to undo');
      }
    } else {
      // This is the draw undo button
      if (lastAction.type == 'DRAW_CHANCE') {
        print('🛑 Undoing DRAW_CHANCE');
        _undoChanceCardDraw(ref);
      } else {
        print('❌ No DRAW_CHANCE action to undo');
      }
    }

    // Remove the undone action from history
    if (gameState.actionHistory.isNotEmpty) {
      ref.read(gameplayProvider.notifier).state = gameState.copyWith(
        actionHistory: gameState.actionHistory.sublist(0, gameState.actionHistory.length - 1),
      );
    }
  }

  Future<void> _executeAction(BuildContext context, WidgetRef ref) async {
    final gameState = ref.read(gameplayProvider);
    
    if (gameState.actionsPlayed >= gameState.maxActions) {
      if (mounted && context.mounted) Navigator.of(context).pop();
      return;
    }

    try {
      // Handle chance card discard dialog if needed
      if (_currentActionCard.category.toLowerCase() == 'chance') {
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text(
              'Discard Cards?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Would you like to discard all Action cards and Chance cards from your hand?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                child: const Text('Keep Cards'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                child: const Text('Discard All'),
              ),
            ],
          ),
        );

        if (shouldDiscard == true) {
          // Get all action AND chance cards from hand
          final cardsToDiscard = gameState.hand.where((card) => 
            card.type.toLowerCase() == 'action' || 
            card.category.toLowerCase() == 'chance'
          ).toList();
          
          // Discard each card to its appropriate discard pile
          for (var card in cardsToDiscard) {
            if (card.category.toLowerCase() == 'chance') {
              // Discard chance cards to chance discard
              ref.read(gameplayProvider.notifier).deckManager.discardChanceCard(card);
            } else {
              // Discard action cards to action discard
              ref.read(gameplayProvider.notifier).deckManager.discardCardByUuid(card.uuid);
            }
          }
        }
      }

      // Execute the action with drawn cards
      ref.read(gameplayProvider.notifier).executeAction(
        actionCard: _currentActionCard,
        heroAbility: widget.heroAbility,
        drawnChanceCards: _drawnChanceCards,
      );

      // Add staged cards to hand
      for (var card in _chanceCardsToHand) {
        ref.read(gameplayProvider.notifier).actionManager.addChanceCardToHand(card);
      }

      // Handle discarding
      for (var drawnCard in _drawnChanceCards) {
        if (!_chanceCardsToHand.any((card) => card.uuid == drawnCard.uuid)) {
          ref.read(gameplayProvider.notifier).deckManager.discardCardByUuid(drawnCard.uuid);
        }
      }

      // Call the onExecute callback if provided
      widget.onExecute?.call();
    } finally {
      // Always close the dialog, even if there's an error
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _executeWithFreePlay(WidgetRef ref) {
    try {
      // Execute with drawn cards
      ref.read(gameplayProvider.notifier).executeAction(
        actionCard: _currentActionCard,
        heroAbility: widget.heroAbility,
        drawnChanceCards: _drawnChanceCards,
        forceExecute: true,
      );

      // Add staged cards to hand directly
      for (var card in _chanceCardsToHand) {
        ref.read(gameplayProvider.notifier).actionManager.addChanceCardToHand(card);
      }

      // Handle discarding of drawn cards that weren't added to hand
      for (var drawnCard in _drawnChanceCards) {
        if (!_chanceCardsToHand.any((card) => card.uuid == drawnCard.uuid)) {
          ref.read(gameplayProvider.notifier).deckManager.discardCardByUuid(drawnCard.uuid);
        }
      }

      // Call the onExecute callback if provided
      widget.onExecute?.call();
    } finally {
      // Always close the dialog, even if there's an error
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Add method to replace the action card with one from sideboard
  void _replaceActionCardFromSideboard(CardData newCard) {
    setState(() {
      // Store the original card if this is the first replacement
      _originalActionCard ??= _currentActionCard;
      // Update the current action card
      _currentActionCard = newCard;
    });
  }

  // Update cancel to restore action card if needed
  void _handleCancel(WidgetRef ref) {
    print("\n❌ Cancel button pressed. Closing dialog...");

    try {
      // Track if we need to restore cards to sideboard
      final hasChanceSideboardCards = _cardsFromChanceSideboard.isNotEmpty;
      final hasActionSideboardCard = _originalActionCard != null;
      
      // Undo all drawn chance cards before closing
      int safetyCounter = 0;
      while (_drawnChanceCards.isNotEmpty) {
        _undoChanceCardDraw(ref);
        safetyCounter++;
        if (safetyCounter > 10) { // Safety limit to prevent infinite loops
          print("🚨 ERROR: Infinite loop detected while undoing drawn chance cards.");
          break;
        }
      }

      safetyCounter = 0;
      while (_chanceCardsToHand.isNotEmpty) {
        _undoAddChanceCardToHand(ref);
        safetyCounter++;
        if (safetyCounter > 10) { // Safety limit to prevent infinite loops
          print("🚨 ERROR: Infinite loop detected while undoing chance cards in hand.");
          break;
        }
      }
      
      // Restore chance cards to sideboard if needed
      if (hasChanceSideboardCards) {
        print("✅ Restoring ${_cardsFromChanceSideboard.length} chance cards to sideboard");
        for (var card in _cardsFromChanceSideboard) {
          ref.read(gameplayProvider.notifier).addToChanceSideboard(card);
        }
        _cardsFromChanceSideboard.clear();
      }
      
      // Restore action card to sideboard if needed
      if (hasActionSideboardCard) {
        print("✅ Restoring action card to sideboard");
        ref.read(gameplayProvider.notifier).addToActionSideboard(_currentActionCard);
        // No need to reset _originalActionCard as we're closing anyway
      }

      print("✅ All undo operations completed. Closing dialog...");

      // Ensure the dialog is closed properly
      if (mounted && context.mounted) {
        Navigator.of(context).pop();
      }
      
    } catch (e, stackTrace) {
      print("🚨 Error while cancelling action execution: $e");
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gameState = ref.watch(gameplayProvider);

        return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Execute Ability',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 1200,  // Increased from 1000 (20% larger)
              height: 720,  // Increased from 600 (20% larger)
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Side: Action Window (flex: 1)
                  Expanded(
                    flex: 3,
                    child: ActionWindow(
                      actionCard: _currentActionCard,
                      heroAbility: widget.heroAbility,
                      // Remove this callback since we moved the component
                      // onActionSideboardSelect: _replaceActionCardFromSideboard,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Middle: Chance Deck Window (flex: 1)
                  Expanded(
                    flex: 2,
                    child: ChanceDeckWindow(
                      chanceDeckCount: gameState.chanceDeck.length,
                      drawnCards: _drawnChanceCards,
                      onDraw: () => _drawChanceCard(ref),
                      onUndo: () => _handleUndo(ref),
                      onAddToHand: () => _addChanceCardToHand(ref),
                      onSideboardDraw: (cards) {
                        setState(() {
                          _cardsFromChanceSideboard.addAll(cards);
                          _drawnChanceCards.addAll(cards);
                        });
                      },
                      onSideboardToHand: (cards) {
                        setState(() {
                          _cardsFromChanceSideboard.addAll(cards);
                          _chanceCardsToHand.addAll(cards);
                        });
                        
                        for (var card in cards) {
                          ref.read(gameplayProvider.notifier).actionManager.addChanceCardToHand(card);
                        }
                      },
                      // Changed: Action sideboard cards are added to drawn cards
                      onActionSideboardSelect: (card) {
                        setState(() {
                          // Convert to ChanceCardData if needed
                          final chanceCard = card is ChanceCardData 
                              ? card 
                              : ChanceCardData(
                                  id: card.id,
                                  name: card.name,
                                  type: card.type,
                                  effect: card.effect,
                                  qty: 1,
                                  uuid: card.uuid ?? 'sb_${card.id}_${DateTime.now().millisecondsSinceEpoch}',
                                );
                          
                          // Track the sideboard origin
                          _cardsFromSideboard.add(chanceCard);
                          
                          // Add to drawn cards
                          _drawnChanceCards.add(chanceCard);
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Side: Chance Window (flex: 2)
                  Expanded(
                    flex: 7,
                    child: ChanceWindow(
                      chanceDeckCount: gameState.chanceDeck.length,
                      drawnCards: _drawnChanceCards,
                      chanceCardsToHand: _chanceCardsToHand, // Remove the map conversion
                      onDraw: () => _drawChanceCard(ref),
                      onUndo: () => _undoAddChanceCardToHand(ref),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
            TextButton(
              onPressed: () => _handleCancel(ref),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _executeAction(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.actionsPlayed >= gameState.maxActions 
                  ? Colors.red[700] 
                  : Colors.green[700],
              ),
              child: Text(
                gameState.actionsPlayed >= gameState.maxActions
                  ? 'Actions Limit Reached' 
                  : 'Execute',
              ),
            ),
            ElevatedButton(
              onPressed: () => _executeWithFreePlay(ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
              ),
              child: const Text('Free to Play'),
            ),
          ],
        );
      },
    );
  }
}