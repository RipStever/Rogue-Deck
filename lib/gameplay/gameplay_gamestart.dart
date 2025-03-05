// lib/gameplay/gameplay_gamestart.dart
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/gameplay/character_stats.dart';
import 'package:card_game/gameplay/gameplay_state.dart';

class GameplayGameStart {
  /// Performs initial setup when starting a game
  /// 
  /// This method handles:
  /// 1. Drawing initial hand from action deck
  /// 2. Setting initial armor state based on HP
  static GameplayState initializeGameStart(GameplayState initialState) {
    // Draw initial hand
    final newHand = _drawStartingHand(initialState);

    // Determine initial armor state
    final newCharacterStats = _determineInitialArmorState(initialState);

    // Return updated state with new hand and armor state
    return initialState.copyWith(
      hand: newHand,
      actionDeck: initialState.actionDeck.sublist(newHand.length),
      characterStats: newCharacterStats,
    );
  }

  /// Draws starting hand based on max hand size
  static List<CardData> _drawStartingHand(GameplayState state) {
    // Ensure we don't draw more cards than are available in the deck
    final cardsToDraw = state.maxHandSize > state.actionDeck.length 
      ? state.actionDeck.length 
      : state.maxHandSize;

    // Draw cards from the end of the deck
    return state.actionDeck.sublist(
      state.actionDeck.length - cardsToDraw, 
      state.actionDeck.length
    );
  }

  /// Determines initial armor state based on character's HP
  static CharacterStats _determineInitialArmorState(GameplayState state) {
    final stats = state.characterStats;
    final breakpoint = (stats.maxHp * 0.9).ceil();

    // Set armor to true if current HP is at or above breakpoint
    return stats.copyWith(
      armor: stats.currentHp >= breakpoint ? 1 : 0,
    );
  }
}