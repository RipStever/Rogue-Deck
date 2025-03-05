//lib/gameplay/gameplay_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'deckmanager/deck_manager_column.dart';
import 'cardzone/card_zone_column.dart';
import 'charactersection/character_section_column.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'gameplay_provider.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final CharacterModel characterModel;

  const GameplayScreen({
    super.key, 
    required this.characterModel,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the character model in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Setting character model in provider: ${widget.characterModel.name}');
      ref.read(characterModelProvider.notifier).state = widget.characterModel;
    });
  }

  @override
  void didUpdateWidget(GameplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.characterModel != oldWidget.characterModel) {
      print('Character model changed, updating provider');
      ref.read(characterModelProvider.notifier).state = widget.characterModel;
    }
  }

  @override
  void dispose() {
    // Clear the character model from the provider
    print('Clearing character model from provider');
    ref.read(characterModelProvider.notifier).state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGameState = ref.watch(gameplayInitProvider);
    
    return asyncGameState.when(
      data: (_) => Scaffold(
        backgroundColor: Colors.grey[900],
        body: Row(
          children: [
            // Deck Management Column (1)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  border: Border(
                    right: BorderSide(color: Colors.grey[800]!, width: 1),
                  ),
                ),
                child: const DeckManagerColumn(),
              ),
            ),

            // Game Area Column (5)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  border: Border(
                    right: BorderSide(color: Colors.grey[800]!, width: 1),
                  ),
                ),
                child: const CardZoneColumn(),
              ),
            ),

            // Character Section Column (4)
            const Expanded(
              flex: 4,
              child: CharacterSectionColumn(),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}