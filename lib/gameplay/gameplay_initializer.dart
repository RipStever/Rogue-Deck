// lib/gameplay/gameplay_initializer.dart

import 'package:card_game/universal/models/character_model.dart';
import 'gameplay_state.dart';
import 'gameplay_deck_service.dart';
import 'gameplay_hero_ability_service.dart';
import 'gameplay_stats_service.dart';
import 'gameplay_gamestart.dart';

class GameplayInitializer {
  static Future<GameplayState> initializeState({CharacterModel? character}) async {
    print('\n=== GameplayInitializer Start ===');
    if (character == null) {
      print('No character provided, returning empty state');
      return const GameplayState();
    }

    try {
      print('Initializing for character: ${character.name}');
      print('Selected feats: ${character.selectedFeats?.length ?? 0}');
      print('Character stats: ${character.stats}');
      
      // Initialize each component separately for better error tracking
      print('\nInitializing chance deck...');
      final chanceDeck = await DeckService.initializeChanceDeck();
      print('Chance deck initialized with ${chanceDeck.length} cards');

      print('\nInitializing action deck...');
      final actionDeck = await DeckService.initializeActionDeck(character);
      print('Action deck initialized with ${actionDeck.length} cards');

      print('\nInitializing hero abilities...');
      final heroAbilities = await HeroAbilityService.initializeHeroAbilities(character);
      print('Hero abilities initialized with ${heroAbilities.length} abilities:');
      for (var ability in heroAbilities) {
        print('  - ${ability.name} (${ability.type})');
      }

      print('\nInitializing character stats...');
      final characterStats = await StatsService.initializeCharacterStats(character);
      print('Character stats initialized');

      // Create initial state before game start setup
      final initialState = GameplayState(
        chanceDeck: chanceDeck,
        actionDeck: actionDeck,
        heroAbilities: heroAbilities,
        characterStats: characterStats,
        characterModel: character,
        maxHandSize: character.stats?['Hand Size']?['base'] ?? 5,
        actionSideboard: const [], // Explicitly initialize empty sideboards
        chanceSideboard: const [],
      );

      // Apply game start setup (draw hand, set initial armor)
      print('\nApplying game start setup...');
      final finalState = GameplayGameStart.initializeGameStart(initialState);
      
      print('\n=== GameplayInitializer Complete ===');
      print('Final state contains:');
      print('- ${finalState.chanceDeck.length} chance cards');
      print('- ${finalState.actionDeck.length} action cards');
      print('- ${finalState.heroAbilities.length} hero abilities');
      print('- ${finalState.hand.length} cards in hand');
      print('- Initial armor state: ${finalState.characterStats.armor}');
      
      return finalState;

    } catch (e, stackTrace) {
      print('\n!!! Error initializing gameplay state !!!');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Returning empty state with only character model');
      return GameplayState(characterModel: character);
    }
  }
}