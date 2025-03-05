// lib/gameplay/notifier/gameplay_action_manager.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_state.dart';
import '../game_action.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import '../../universal/models/chance_card_data.dart';
import '../../universal/models/hero_ability_card_model.dart';

extension ListExtensions<T> on List<T> {
  void removeLastWhere(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) {
        removeAt(i);
        break;
      }
    }
  }
}

/// Manages game action recording, execution, and undo functionality
class GameplayActionManager {
  final StateNotifier<GameplayState> notifier;
  GameplayState get state => notifier.state;

  GameplayActionManager(this.notifier);

  /// Records a new action and adds it to history
  void recordAction(GameAction action) {
    print('\n📝 Recording Action: ${action.type}');

    final updatedHistory = [...state.actionHistory, action];
    notifier.state = state.copyWith(actionHistory: updatedHistory);

    print('✅ Action History Updated! Total actions: ${updatedHistory.length}');
  }


  /// Attempts to undo the last action in history
  void undoLastAction() {
    print('\n=== Undoing Last Action ===');
    if (state.actionHistory.isEmpty) {
      print('No actions to undo');
      return;
    }

    final lastAction = state.actionHistory.last;
    print('Undoing action: ${lastAction.type}');
    
    try {
      switch (lastAction.type) {
        case 'EXECUTE_ACTION':
          _undoExecuteAction(lastAction);
          break;
          
        case 'DRAW_CHANCE':
          _undoDrawChance(lastAction);
          break;
          
        case 'DRAW_ACTION':
          _undoDrawAction(lastAction);
          break;
          
        case 'DISCARD_CARD':
          _undoDiscardCard(lastAction);
          break;
          
        default:
          print('Unknown action type: ${lastAction.type}');
          return;
      }

      // Remove the undone action from history
      notifier.state = state.copyWith(
        actionHistory: state.actionHistory.sublist(0, state.actionHistory.length - 1)
      );
      
      print('Action successfully undone');
      
    } catch (e) {
      print('Error undoing action: $e');
    }
  }

  /// Executes an action with the given ability and action card
  void executeAction({
    required CardData actionCard,
    required HeroAbilityCardModel heroAbility,
    List<ChanceCardData>? drawnChanceCards,
    bool forceExecute = false, 
  }) {
    print('\n=== DETAILED Executing Action ===');
    print('Action Card: ${actionCard.name} (ID: ${actionCard.id})');
    print('Action Card Category: ${actionCard.category}');
    print('Hero Ability: ${heroAbility.name}');
    print('Drawn Chance Cards: ${drawnChanceCards?.length ?? 0}');

    // Check action limit unless force executing
    if (!forceExecute && state.actionsPlayed >= state.maxActions) {
      print('Cannot execute: Maximum actions reached');
      return;
    }

    try {
      // Remove only the first instance of the action card from the hand
      final newHand = List<CardData>.from(state.hand);
      final index = newHand.indexWhere((card) => card.uuid == actionCard.uuid);
      if (index != -1) {
        newHand.removeAt(index);
      }

      // Remove only the specific drawn chance cards
      if (drawnChanceCards != null) {
        for (var chanceCard in drawnChanceCards) {
          final chanceIndex = newHand.indexWhere((card) => card.uuid == chanceCard.uuid);
          if (chanceIndex != -1) {
            newHand.removeAt(chanceIndex);
          }
        }
      }

      // Add played card to played area
      final newPlayedCards = [...state.playedCards, actionCard];

      // Add any drawn chance cards to played area
      if (drawnChanceCards != null) {
        final chanceCardData = drawnChanceCards.map((c) => CardData(
          id: c.id,
          name: c.name,
          type: c.type,
          effect: c.effect,
          category: 'Chance',
          uuid: c.uuid,  // Ensure unique instance tracking
        )).toList();

        newPlayedCards.addAll(chanceCardData);
      }

      // Record the action
      final action = GameAction(
        'EXECUTE_ACTION',
        {
          'actionCard': actionCard,
          'heroAbility': heroAbility,
          'chanceCards': drawnChanceCards?.map((c) => c.toMap()).toList(),
          'forced': forceExecute,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Update game state
      notifier.state = state.copyWith(
        hand: newHand,
        playedCards: newPlayedCards,
        actionsPlayed: forceExecute ? state.actionsPlayed : state.actionsPlayed + 1,
        selectedCard: null,
        selectedCardId: null,
        compatibleAbilities: [],
        overrideSelectedCard: true,
        overrideSelectedCardId: true,
        actionHistory: [...state.actionHistory, action],
      );

      _processActionEffects(actionCard, heroAbility);

    } catch (e, stackTrace) {
      print('Error executing action: $e');
      print('Stacktrace: $stackTrace');
    }
  }


  // Private helper methods for undoing specific action types

  void _undoExecuteAction(GameAction action) {
    print('Undoing execute action');
    final actionCard = action.data['actionCard'] as CardData;
    final chanceCards = (action.data['chanceCards'] as List?)?.map(
      (cardMap) => ChanceCardData.fromMap(cardMap as Map<String, dynamic>)
    ).toList();
    final wasForced = action.data['forced'] as bool? ?? false;

    // Return action card to hand
    final newHand = List<CardData>.from(state.hand)..add(actionCard);
    
    // Remove from played cards
    final newPlayedCards = List<CardData>.from(state.playedCards);
    newPlayedCards.removeLastWhere((card) => card.id == actionCard.id);

    // Return any chance cards to the deck
    var newChanceDeck = state.chanceDeck;
    if (chanceCards != null && chanceCards.isNotEmpty) {
      final cardDataList = chanceCards.map((c) => CardData(
        id: c.id,
        name: c.name,
        type: c.type,
        effect: c.effect,
        category: 'Chance'
      )).toList();
      
      for (var card in cardDataList) {
        newPlayedCards.removeLastWhere((playedCard) => playedCard.id == card.id);
      }
      newChanceDeck = [...newChanceDeck, ...cardDataList];
    }

    notifier.state = state.copyWith(
      hand: newHand,
      playedCards: newPlayedCards,
      chanceDeck: newChanceDeck,
      actionsPlayed: wasForced ? state.actionsPlayed : state.actionsPlayed - 1,
    );
  }

  void _undoDrawChance(GameAction action) {
    print('Undoing chance card draw');
    final card = action.data['card'] as CardData;

    notifier.state = state.copyWith(
      chanceDeck: [...state.chanceDeck, card],
      playedCards: state.playedCards..removeLastWhere((c) => c.id == card.id),
    );
  }

  void _undoDrawAction(GameAction action) {
    print('Undoing action card draw');
    final card = action.data['card'] as CardData;

    notifier.state = state.copyWith(
      actionDeck: [...state.actionDeck, card],
      hand: state.hand..removeLastWhere((c) => c.id == card.id),
    );
  }

  void _undoDiscardCard(GameAction action) {
    print('Undoing card discard');
    final card = action.data['card'] as CardData;
    final wasFromHand = action.data['fromHand'] as bool? ?? false;

    if (wasFromHand) {
      notifier.state = state.copyWith(
        hand: [...state.hand, card],
        actionDiscard: state.actionDiscard..removeLastWhere((c) => c.id == card.id),
      );
    } else {
      notifier.state = state.copyWith(
        playedCards: [...state.playedCards, card],
        actionDiscard: state.actionDiscard..removeLastWhere((c) => c.id == card.id),
      );
    }
  }

  /// Process any additional effects from executing an action
  void _processActionEffects(CardData actionCard, HeroAbilityCardModel heroAbility) {
    print('Processing action effects...');
    
    // Check if action requires drawing chance cards
    final metadata = actionCard.metadata;
    if (metadata?.toLowerCase().contains('draw') ?? false) {
      print('Action requires drawing chance cards');
      // Note: Actual draw logic should be handled by DeckManager
    }
  }

  void addChanceCardToHand(ChanceCardData card) {
    print('\n=== Adding Chance Card to Hand ===');
    
    // Convert ChanceCardData to CardData format
    final cardData = CardData(
      id: card.id,
      name: card.name,
      type: card.type,
      effect: card.effect,
      category: 'Chance',
      uuid: card.uuid, // Keep unique ID tracking
    );

    // Update game state: add to hand
    notifier.state = state.copyWith(
      hand: [...state.hand, cardData],
    );

    // 🔥 NEW: Record action in history so it can be undone
    recordAction(GameAction(
      'ADD_CHANCE_TO_HAND',  // Action type
      {'card': cardData},    // Action data
    ));

    print('Card added to hand and action recorded.');
  }
}