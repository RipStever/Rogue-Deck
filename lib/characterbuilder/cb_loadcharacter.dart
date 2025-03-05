import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/cb_screen.dart';
import 'package:card_game/characterbuilder/deckbuilder/services/deckbuilder_file_service.dart';

class CBLoadCharacter extends ConsumerStatefulWidget {
  final String characterFilePath;

  const CBLoadCharacter({super.key, required this.characterFilePath});

  @override
  ConsumerState<CBLoadCharacter> createState() => _CBLoadCharacterState();
}

class _CBLoadCharacterState extends ConsumerState<CBLoadCharacter> {
  late final DeckBuilderFileService _fileService;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fileService = DeckBuilderFileService(baseDirectory: _getBaseDirectory());
    _loadCharacterData();
  }

  String _getBaseDirectory() {
    final userProfile = Platform.environment['USERPROFILE'];
    return path.join(userProfile ?? '', 'OneDrive', 'Documents', 'Rogue Deck', 'Decks');
  }

  Future<void> _loadCharacterData() async {
    try {
      final file = File(widget.characterFilePath);
      if (!await file.exists()) {
        throw Exception('Character file not found');
      }

      final jsonString = await file.readAsString();
      final characterData = json.decode(jsonString) as Map<String, dynamic>;
      final character = CharacterModel.fromJson(characterData);

      if (!mounted) return;

      ref.read(characterProvider.notifier).updateCharacter(character);
      
      if (character.selectedDeckName.isNotEmpty && character.selectedDeckName != 'New Deck') {
        final deckPath = path.join(_getBaseDirectory(), '${character.selectedDeckName}.json');
        if (await File(deckPath).exists()) {
          ref.read(characterProvider.notifier).updateDeckSelection(deckPath);
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading character...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadCharacterData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text('Character loaded successfully'),
    );
  }
}
