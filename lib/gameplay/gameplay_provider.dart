// lib/gameplay/gameplay_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'gameplay_state.dart';
import 'gameplay_initializer.dart';
import 'gameplay_notifier.dart';

// Character model provider with debug
final characterModelProvider = StateProvider<CharacterModel?>((ref) {
  print('characterModelProvider created/updated');
  return null;
});

// Initialization provider with more debug info
final gameplayInitProvider = FutureProvider.autoDispose<GameplayState>((ref) async {
  print('\n=== gameplayInitProvider executing ===');
  final characterModel = ref.watch(characterModelProvider);
  print('Character from provider: ${characterModel?.name}');
  
  if (characterModel == null) {
    print('No character model available yet');
    return const GameplayState();
  }

  print('Initializing state for character: ${characterModel.name}');
  final state = await GameplayInitializer.initializeState(character: characterModel);
  print('Initialization complete, returning state with ${state.heroAbilities.length} abilities');
  return state;
});

// Main gameplay provider
final gameplayProvider = StateNotifierProvider.autoDispose<GameplayNotifier, GameplayState>((ref) {
  print('\n=== Creating new GameplayNotifier ===');
  final characterModel = ref.watch(characterModelProvider);
  final asyncInitialState = ref.watch(gameplayInitProvider);
  
  return GameplayNotifier(
    ref,
    asyncInitialState.when(
      data: (state) {
        print('GameplayNotifier receiving initialized state:');
        print('- Character: ${characterModel?.name}');
        print('- Hero abilities: ${state.heroAbilities.length}');
        print('- Weapon abilities: ${state.weaponAbilities.length}');  // Add this line
        return state;
      },
      loading: () {
        print('GameplayNotifier in loading state');
        return GameplayState(characterModel: characterModel);
      },
      error: (error, stackTrace) {
        print('GameplayNotifier encountered error:');
        print(error);
        print(stackTrace);
        return GameplayState(characterModel: characterModel);
      },
    ),
  );
});