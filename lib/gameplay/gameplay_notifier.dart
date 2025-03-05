// lib/gameplay/gameplay_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/chance_card_data.dart';
import 'package:card_game/universal/models/hero_ability_card_model.dart';
import 'gameplay_state.dart';
import 'gameplay_health_manager.dart';
import 'cardzone/action_parser.dart';
import 'notifier/gameplay_deck_manager.dart';
import 'notifier/gameplay_action_manager.dart';
import 'package:card_game/universal/models/character_model.dart';

class GameplayNotifier extends StateNotifier<GameplayState> {
  final Ref ref;
  late final GameplayHealthManager healthManager;
  late final GameplayDeckManager deckManager;
  late final GameplayActionManager actionManager;

  GameplayNotifier(this.ref, GameplayState state) : super(state) {
    healthManager = GameplayHealthManager(this);
    deckManager = GameplayDeckManager(this);
    actionManager = GameplayActionManager(this);
  }

  // Action Display Management
  void setShowAllTypes(bool value) {
    state = state.copyWith(showAllTypes: value);
    _updateCompatibleAbilities();
  }

  void setShowAllTiers(bool value) {
    state = state.copyWith(showAllTiers: value);
    _updateCompatibleAbilities();
  }

  void _updateCompatibleAbilities() {
    if (state.selectedCard == null) return;

    final actions = ActionParser.parse(state.selectedCard?.metadata);
    List<CardData> filteredAbilities = [];

    // Filter abilities based on toggle settings
    for (final ability in state.heroAbilities) {
      final tierMatch = RegExp(r'- (Basic|Tier \d+)').firstMatch(ability.name);
      final tier = tierMatch?.group(1) ?? 'Basic';
      final type = ability.type;
      final tierLevel = _getTierLevel(tier);

      // Apply type filter
      if (!state.showAllTypes) {
        if (!actions.any((action) => action.actionTypes.contains(type))) {
          continue;
        }
      }

      // Apply tier filter
      if (!state.showAllTiers) {
        if (!actions.any((action) => 
          action.tier == null || action.tier! >= tierLevel)) {
          continue;
        }
      }

      filteredAbilities.add(ability);
    }

    state = state.copyWith(compatibleAbilities: filteredAbilities);
  }

  // Action Limit Management
  void incrementMaxActions() {
    state = state.copyWith(maxActions: state.maxActions + 1);
  }

  void decrementMaxActions() {
    if (state.maxActions > 1) {
      state = state.copyWith(maxActions: state.maxActions - 1);
    }
  }

  // Hand Size Management  
  void incrementMaxHandSize() {
    state = state.copyWith(maxHandSize: state.maxHandSize + 1);
  }

  void decrementMaxHandSize() {
    if (state.maxHandSize > 1) {
      state = state.copyWith(maxHandSize: state.maxHandSize - 1);
    }
  }

  // Game Flow Control
  void endTurn() {
    // Separate chance cards from other cards
    final chanceCards = state.playedCards.where((card) => card.category == 'Chance').toList();
    final nonChanceCards = state.playedCards.where((card) => card.category != 'Chance').toList();
    
    // Route cards to appropriate discard piles
    final chanceDiscard = [...state.chanceDiscard, ...chanceCards];
    final actionDiscard = [...state.actionDiscard, ...nonChanceCards];
    
    // Draw up to max hand size
    final newHand = List<CardData>.from(state.hand);
    var newActionDeck = List<CardData>.from(state.actionDeck);
    
    while (newHand.length < state.maxHandSize && newActionDeck.isNotEmpty) {
      newHand.add(newActionDeck.last);
      newActionDeck = List<CardData>.from(newActionDeck)..removeLast();
    }

    // Update state
    state = state.copyWith(
      playedCards: [],
      actionDeck: newActionDeck,
      chanceDeck: state.chanceDeck,
      chanceDiscard: chanceDiscard,
      actionDiscard: actionDiscard,
      hand: newHand,
      actionsPlayed: 0,
      selectedCard: null,
      selectedCardId: null,
      compatibleAbilities: [],
      overrideSelectedCard: true,
      overrideSelectedCardId: true,
    );
  }

  // Card Selection
  void toggleCardSelection(CardData card, {int? uniqueId}) {
    print('\n=== Card Selection Event ===');
    print('Selected card: ${card.name} (id: ${card.id})');
    print('Current selectedCard?.id=${state.selectedCard?.id}');
    print('Card metadata: ${card.metadata}');
    print('Total hero abilities available: ${state.heroAbilities.length}');

    // If it's the same card, unselect
    if (state.selectedCard?.id == card.id) {
      print('Unselecting card ${card.name}');
      state = state.copyWith(
        overrideSelectedCard: true,
        overrideSelectedCardId: true,
        selectedCard: null,
        selectedCardId: null,
        compatibleAbilities: [],
      );
      return;
    }

    // Update state with selected card
    state = state.copyWith(
      overrideSelectedCard: true,
      overrideSelectedCardId: true,
      selectedCard: card,
      selectedCardId: uniqueId,
    );

    // Update compatible abilities
    _updateCompatibleAbilities();
  }

  // Character Stats Management
  void updateArmorState(bool enabled) => healthManager.updateArmorState(enabled);
  void updateHitPointsWithOverhealth(int value) => healthManager.updateHitPointsWithOverhealth(value);
  void updateOverhealth(int value) => healthManager.updateOverhealth(value);
  void toggleArmor() => healthManager.toggleArmor();

  void updateSpeed(int newValue) {
    state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        speed: newValue.clamp(0, 10),
      ),
    );
  }

  void updateMana(int newValue) {
    state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        mana: newValue.clamp(0, state.characterStats.maxMana),
      ),
    );
  }

  void updateSurgeCharge(int newValue) {
    state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        surgeCharge: newValue.clamp(0, 5),
      ),
    );
  }

  void updateCounter(int newValue) {
    state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        counter: newValue.clamp(0, 10),
      ),
    );
  }

  // Action Execution Delegation
  void executeAction({
    required CardData actionCard,
    required HeroAbilityCardModel heroAbility,
    List<ChanceCardData>? drawnChanceCards,
    bool forceExecute = false,
  }) {
    actionManager.executeAction(
      actionCard: actionCard,
      heroAbility: heroAbility,
      drawnChanceCards: drawnChanceCards,
      forceExecute: forceExecute,
    );
  }

  // Character Model Management
  void setCharacterModel(CharacterModel characterModel) {
    print('Setting character model: ${characterModel.name}');
    state = state.copyWith(characterModel: characterModel);
    print('Updated state abilities count: ${state.heroAbilities.length}');
  }

  // Helper Methods
  int _getTierLevel(String tier) {
    switch (tier.toLowerCase()) {
      case 'basic':
        return 0;
      case 'tier 1':
        return 1;
      case 'tier 2':
        return 2;
      default:
        return 0;
    }
  }

  // Add these new sideboard management methods
  void addToActionSideboard(CardData card) {
    final newSideboard = List<CardData>.from(state.actionSideboard)..add(card);
    state = state.copyWith(actionSideboard: newSideboard);
  }

  void addToChanceSideboard(CardData card) {
    final newSideboard = List<CardData>.from(state.chanceSideboard)..add(card);
    state = state.copyWith(chanceSideboard: newSideboard);
  }

  // Fix the removeFromSideboard method with proper syntax
  void removeFromSideboard(CardData card, String type) {
    if (type == 'Action') {
      // First try to find and remove by UUID (most precise)
      var newSideboard = List<CardData>.from(state.actionSideboard);
      int indexToRemove = newSideboard.indexWhere((c) => c.uuid == card.uuid);
      
      // If UUID not found, fall back to removing just one instance by ID
      if (indexToRemove == -1) {
        indexToRemove = newSideboard.indexWhere((c) => c.id == card.id);
      }
      
      // Only remove if we found a matching card
      if (indexToRemove >= 0) {
        newSideboard.removeAt(indexToRemove);
      }
      
      // Add to action discard pile
      final newActionDiscard = List<CardData>.from(state.actionDiscard)..add(card);
      
      state = state.copyWith(
        actionSideboard: newSideboard,
        actionDiscard: newActionDiscard
      );
    } else {
      // Chance cards - same approach
      var newSideboard = List<CardData>.from(state.chanceSideboard);
      int indexToRemove = newSideboard.indexWhere((c) => c.uuid == card.uuid);
      
      if (indexToRemove == -1) {
        indexToRemove = newSideboard.indexWhere((c) => c.id == card.id);
      }
      
      if (indexToRemove >= 0) {
        newSideboard.removeAt(indexToRemove);
      }
      
      // Add to chance discard pile
      final newChanceDiscard = List<CardData>.from(state.chanceDiscard)..add(card);
      
      state = state.copyWith(
        chanceSideboard: newSideboard,
        chanceDiscard: newChanceDiscard
      );
    }
  }

  // Move a card from hand to appropriate sideboard
  void moveFromHandToSideboard(CardData card) {
    // First, remove card from hand
    final newHand = List<CardData>.from(state.hand)
      ..removeWhere((c) => c.uuid == card.uuid);

    // Then add to the appropriate sideboard
    if (card.category == 'Chance') {
      final newSideboard = List<CardData>.from(state.chanceSideboard)..add(card);
      state = state.copyWith(
        hand: newHand,
        chanceSideboard: newSideboard,
      );
    } else {
      final newSideboard = List<CardData>.from(state.actionSideboard)..add(card);
      state = state.copyWith(
        hand: newHand,
        actionSideboard: newSideboard,
      );
    }
  }

  // Add this method to allow moving cards from sideboard back to hand
  void moveFromSideboardToHand(CardData card, String type) {
    // Add card to hand
    final newHand = List<CardData>.from(state.hand)..add(card);
    
    // Remove card from appropriate sideboard
    if (type == 'Chance') {
      final newSideboard = List<CardData>.from(state.chanceSideboard)
        ..removeWhere((c) => c.uuid == card.uuid);
      
      state = state.copyWith(
        hand: newHand,
        chanceSideboard: newSideboard,
      );
    } else { // Action
      final newSideboard = List<CardData>.from(state.actionSideboard)
        ..removeWhere((c) => c.uuid == card.uuid);
      
      state = state.copyWith(
        hand: newHand,
        actionSideboard: newSideboard,
      );
    }
  }

  void undoLastAction() {
    actionManager.undoLastAction();
  }
}