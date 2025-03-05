// lib/gameplay/gameplay_state.dart

import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'game_action.dart';
import 'character_stats.dart';

class GameplayState {
  // Deck Management
  final List<CardData> chanceDeck;
  final List<CardData> chanceDiscard;
  final List<CardData> actionDeck;
  final List<CardData> actionDiscard;
  
  // Sideboards
  final List<CardData> actionSideboard;
  final List<CardData> chanceSideboard;

  // Card Zone Management
  final List<CardData> playedCards;
  final List<CardData> hand;
  final int maxHandSize;
  final int actionsPlayed;
  final CardData? selectedCard;
  final int? selectedCardId;
  final List<CardData> compatibleAbilities;
  final List<GameAction> actionHistory;
  final int maxActions;

  // Character Management
  final CharacterStats characterStats;
  final List<CardData> heroAbilities;
  final List<CardData> weaponAbilities;
  final String heroAbilitiesSort;
  final CharacterModel? characterModel;

  // Ability Filter Controls
  final bool showAllTypes;
  final bool showAllTiers;

  const GameplayState({
    // Deck Management
    this.chanceDeck = const [],
    this.chanceDiscard = const [],
    this.actionDeck = const [],
    this.actionDiscard = const [],
    
    // Sideboards
    this.actionSideboard = const [],
    this.chanceSideboard = const [],
    
    // Card Zone Management
    this.playedCards = const [],
    this.hand = const [],
    this.maxHandSize = 5,
    this.actionsPlayed = 0,
    this.selectedCard,
    this.selectedCardId,
    this.compatibleAbilities = const [],
    this.actionHistory = const [],
    this.maxActions = 2,
    
    // Character Management
    this.characterStats = const CharacterStats(),
    this.heroAbilities = const [],
    this.weaponAbilities = const [],
    this.heroAbilitiesSort = 'type',
    this.characterModel,

    // Ability Filter Controls
    this.showAllTypes = false,
    this.showAllTiers = false,
  });

  GameplayState copyWith({
    List<CardData>? chanceDeck,
    List<CardData>? chanceDiscard,
    List<CardData>? actionDeck,
    List<CardData>? actionDiscard,
    
    List<CardData>? actionSideboard,
    List<CardData>? chanceSideboard,
    
    List<CardData>? playedCards,
    List<CardData>? hand,
    int? maxHandSize,
    int? actionsPlayed,
    CardData? selectedCard,
    int? selectedCardId,
    List<CardData>? compatibleAbilities,
    List<GameAction>? actionHistory,
    CharacterStats? characterStats,
    List<CardData>? heroAbilities,
    List<CardData>? weaponAbilities,
    String? heroAbilitiesSort,
    CharacterModel? characterModel,
    int? maxActions,
    bool? showAllTypes,
    bool? showAllTiers,

    bool overrideSelectedCard = false,
    bool overrideSelectedCardId = false,
  }) {
    return GameplayState(
      chanceDeck: chanceDeck ?? this.chanceDeck,
      chanceDiscard: chanceDiscard ?? this.chanceDiscard,
      actionDeck: actionDeck ?? this.actionDeck,
      actionDiscard: actionDiscard ?? this.actionDiscard,
      
      actionSideboard: actionSideboard ?? this.actionSideboard,
      chanceSideboard: chanceSideboard ?? this.chanceSideboard,
      
      playedCards: playedCards ?? this.playedCards,
      hand: hand ?? this.hand,
      maxHandSize: maxHandSize ?? this.maxHandSize,
      actionsPlayed: actionsPlayed ?? this.actionsPlayed,
      maxActions: maxActions ?? this.maxActions,
      selectedCard: overrideSelectedCard ? selectedCard : (selectedCard ?? this.selectedCard),
      selectedCardId: overrideSelectedCardId ? selectedCardId : (selectedCardId ?? this.selectedCardId),
      compatibleAbilities: compatibleAbilities ?? this.compatibleAbilities,
      actionHistory: actionHistory ?? this.actionHistory,
      characterStats: characterStats ?? this.characterStats,
      heroAbilities: heroAbilities ?? this.heroAbilities,
      weaponAbilities: weaponAbilities ?? this.weaponAbilities,
      heroAbilitiesSort: heroAbilitiesSort ?? this.heroAbilitiesSort,
      characterModel: characterModel ?? this.characterModel,
      showAllTypes: showAllTypes ?? this.showAllTypes,
      showAllTiers: showAllTiers ?? this.showAllTiers,
    );
  }
}