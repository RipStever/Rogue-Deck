// lib/gameplay/deck/gameplay_deck_manager.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameplay_state.dart';
import '../game_action.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import '../../universal/models/chance_card_data.dart';

/// Manages all deck-related operations including:
/// - Drawing cards
/// - Shuffling decks
/// - Managing discard piles
/// - Moving cards between zones
class GameplayDeckManager {
  final StateNotifier<GameplayState> notifier;

  GameplayDeckManager(this.notifier);

  GameplayState get state => notifier.state;

  // Chance Card Operations
  void drawChanceCard() {
    if (state.chanceDeck.isEmpty) return;

    final newChanceDeck = List<CardData>.from(state.chanceDeck)..removeLast();
    final drawnCard = state.chanceDeck.last;
    
    notifier.state = state.copyWith(
      chanceDeck: newChanceDeck,
      playedCards: [...state.playedCards, drawnCard],
    );

    _addToHistory(GameAction.drawChance(drawnCard));
  }

  void drawChanceCardForExecution() {
    if (state.chanceDeck.isEmpty) return;

    final newChanceDeck = List<CardData>.from(state.chanceDeck)..removeLast();
    
    notifier.state = state.copyWith(
      chanceDeck: newChanceDeck,
    );

    _addToHistory(GameAction.drawChance(state.chanceDeck.last));
  }

  void returnChanceCardsToTop(List<ChanceCardData> cards) {
    print('Returning ${cards.length} chance cards to the top of the deck');
    
    final cardDataToReturn = cards.map((c) => CardData(
      id: c.id,
      name: c.name,
      type: c.type,
      effect: c.effect,
      category: 'Chance',
    )).toList();

    final reversedCards = cardDataToReturn.reversed.toList();

    notifier.state = state.copyWith(
      chanceDeck: [...reversedCards, ...state.chanceDeck],
    );

    // Remove related draw actions from history
    final newHistory = List<GameAction>.from(state.actionHistory);
    newHistory.removeWhere((action) => 
      action.type == 'DRAW_CHANCE' && 
      cardDataToReturn.any((card) => action.data['card'].id == card.id)
    );

    notifier.state = state.copyWith(
      actionHistory: newHistory,
    );
  }

  void shuffleChanceDiscard() {
    if (state.chanceDiscard.isEmpty) return;

    final newChanceDeck = List<CardData>.from(state.chanceDiscard)..shuffle();
    notifier.state = state.copyWith(
      chanceDeck: [...state.chanceDeck, ...newChanceDeck],
      chanceDiscard: [],
    );
  }

  void moveDiscardToTop(CardData card) {
    final newDiscard = List<CardData>.from(state.chanceDiscard)
      ..removeWhere((c) => c.id == card.id);  
    
    final newDeck = List<CardData>.from(state.chanceDeck)
      ..add(card);

    notifier.state = state.copyWith(
      chanceDeck: newDeck,
      chanceDiscard: newDiscard,
    );
  }

  void moveDiscardAndShuffle(CardData card) {
    final newDiscard = List<CardData>.from(state.chanceDiscard)
      ..removeWhere((c) => c.id == card.id);
    
    final newDeck = List<CardData>.from(state.chanceDeck)
      ..add(card)
      ..shuffle();

    notifier.state = state.copyWith(
      chanceDeck: newDeck,
      chanceDiscard: newDiscard,
    );
  }

  void moveDiscardToBottom(CardData card) {
    final newDiscard = List<CardData>.from(state.chanceDiscard)
      ..removeWhere((c) => c.id == card.id);
    
    final newDeck = List<CardData>.from(state.chanceDeck)
      ..insert(0, card);

    notifier.state = state.copyWith(
      chanceDeck: newDeck,
      chanceDiscard: newDiscard,
    );
  }

  // Action Card Operations
  void drawActionCard() {
    if (state.actionDeck.isEmpty) return;

    final newActionDeck = List<CardData>.from(state.actionDeck)..removeLast();
    final drawnCard = state.actionDeck.last;
    
    notifier.state = state.copyWith(
      actionDeck: newActionDeck,
      hand: [...state.hand, drawnCard],
    );

    _addToHistory(GameAction.drawAction(drawnCard));
  }

  void shuffleActionDiscard() {
    if (state.actionDiscard.isEmpty) return;

    final newActionDeck = List<CardData>.from(state.actionDiscard)..shuffle();
    notifier.state = state.copyWith(
      actionDeck: [...state.actionDeck, ...newActionDeck],
      actionDiscard: [],
    );
  }

  void moveDiscardToTopAction(CardData card) {
    final newDiscard = List<CardData>.from(state.actionDiscard)
      ..removeWhere((c) => c.id == card.id);
    
    final newDeck = List<CardData>.from(state.actionDeck)
      ..add(card);

    notifier.state = state.copyWith(
      actionDeck: newDeck,
      actionDiscard: newDiscard,
    );
  }

  void moveDiscardAndShuffleAction(CardData card) {
    final newDiscard = List<CardData>.from(state.actionDiscard)
      ..removeWhere((c) => c.id == card.id);
    
    final newDeck = List<CardData>.from(state.actionDeck)
      ..add(card)
      ..shuffle();

    notifier.state = state.copyWith(
      actionDeck: newDeck,
      actionDiscard: newDiscard,
    );
  }

  void moveDiscardToBottomAction(CardData card) {
    final newDiscard = List<CardData>.from(state.actionDiscard)
      ..removeWhere((c) => c.id == card.id);
    
    final newDeck = List<CardData>.from(state.actionDeck)
      ..insert(0, card);

    notifier.state = state.copyWith(
      actionDeck: newDeck,
      actionDiscard: newDiscard,
    );
  }

  // General Card Management
void discardCardByIndex(int index) {
  if (index < 0 || index >= state.hand.length) return; // Prevent invalid index errors

  final cardToDiscard = state.hand[index]; // Get the card at the index
  final newHand = List<CardData>.from(state.hand)..removeAt(index); // Remove only this card

  // Add the discarded card to the correct discard pile (Chance or Action)
  if (cardToDiscard.category == 'Chance') {
    final newChanceDiscard = List<CardData>.from(state.chanceDiscard)..add(cardToDiscard);
    notifier.state = state.copyWith(hand: newHand, chanceDiscard: newChanceDiscard);
  } else {
    final newActionDiscard = List<CardData>.from(state.actionDiscard)..add(cardToDiscard);
    notifier.state = state.copyWith(hand: newHand, actionDiscard: newActionDiscard);
  }
}

void discardCardByUuid(String uuid) {
  final cardToDiscard = state.hand.firstWhere((card) => card.uuid == uuid);
  final newHand = List<CardData>.from(state.hand)..removeWhere((card) => card.uuid == uuid);

  // Add the discarded card to the correct discard pile (Chance or Action)
  if (cardToDiscard.category == 'Chance') {
    final newChanceDiscard = List<CardData>.from(state.chanceDiscard)..add(cardToDiscard);
    notifier.state = state.copyWith(hand: newHand, chanceDiscard: newChanceDiscard);
  } else {
    final newActionDiscard = List<CardData>.from(state.actionDiscard)..add(cardToDiscard);
    notifier.state = state.copyWith(hand: newHand, actionDiscard: newActionDiscard);
  }
}

void returnDiscardToHand(CardData card) {
  final newDiscard = List<CardData>.from(state.actionDiscard)
    ..removeWhere((c) => c.id == card.id);

  final newHand = List<CardData>.from(state.hand)
    ..add(card);

  notifier.state = state.copyWith(
    actionDiscard: newDiscard,
    hand: newHand,
  );
}

  void returnChanceDiscardToHand(CardData card) {
    final newDiscard = List<CardData>.from(state.chanceDiscard)
      ..removeWhere((c) => c.id == card.id);

    final newHand = List<CardData>.from(state.hand)
      ..add(card);

    notifier.state = state.copyWith(
      chanceDiscard: newDiscard,
      hand: newHand,
    );
  }

  void discardChanceCard(CardData card) {
    final chanceDiscard = List<CardData>.from(state.chanceDiscard);
    final hand = List<CardData>.from(state.hand);

    // Remove from hand
    hand.removeWhere((c) => c.uuid == card.uuid);
    
    // Add to chance discard pile
    chanceDiscard.add(card);

    notifier.state = state.copyWith(
      hand: hand,
      chanceDiscard: chanceDiscard,
    );
  }

  void moveTopChanceCardToHand() {
    if (state.chanceDeck.isEmpty) return;

    final drawnCard = state.chanceDeck.last;
    final newChanceDeck = List<CardData>.from(state.chanceDeck)..removeLast();
    
    notifier.state = state.copyWith(
      chanceDeck: newChanceDeck,
      hand: [...state.hand, drawnCard],
    );

    _addToHistory(GameAction.drawChance(drawnCard));
  }

  void _addToHistory(GameAction action) {
    notifier.state = state.copyWith(
      actionHistory: [...state.actionHistory, action],
    );
  }
}