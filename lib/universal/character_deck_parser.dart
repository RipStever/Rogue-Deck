// lib/universal/character_deck_parser.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CharacterDeckParser {
  // Optional base directory for file loading
  final String? baseDir;

  CharacterDeckParser([this.baseDir]);

  /// Loads the deck for the provided [deckName] and returns a Map<int,int>
  /// where each key is the card ID and each value is the quantity.
  /// This matches the JSON structure in "Ten's Deck.json".
  Future<Map<int, int>> loadDeckData(String deckName) async {
    try {
      // Load the deck from assets for web and desktop for consistency
      final jsonContent = await rootBundle.loadString('assets/defaultdeck.json');
      final jsonData = json.decode(jsonContent);

      final cardEntries = (jsonData['cards'] as List).cast<Map<String, dynamic>>();
      final Map<int, int> deckMap = {};

      for (final card in cardEntries) {
        final id = card['id'] as int;
        final qty = card['qty'] as int;
        deckMap[id] = qty;
      }

      return deckMap;
    } catch (e) {
      print('Error loading deck data: $e');
      return <int, int>{};
    }
  }
}
