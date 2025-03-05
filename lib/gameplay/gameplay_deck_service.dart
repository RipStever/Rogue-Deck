// lib/gameplay/gameplay_deck_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/character_model.dart';

class DeckService {
  static Future<List<CardData>> initializeChanceDeck() async {
    try {
      final chanceJsonString = await rootBundle.loadString('assets/chancedeck.json');
      final List<dynamic> chanceData = json.decode(chanceJsonString);
      
      return chanceData.expand((card) {
        final qty = card['qty'] as int? ?? 1;
        return List.generate(qty, (_) => CardData(
          id: card['id'],
          name: card['name'],
          type: card['type'],
          effect: card['effect'],
          category: 'Chance',
        ));
      }).toList()..shuffle();
    } catch (e) {
      print('Error initializing chance deck: $e');
      return [];
    }
  }

  static Future<List<CardData>> initializeActionDeck(CharacterModel? character) async {
  // 1) Load a library of card definitions (similar to how you do for defaultdeck.json).
  final deckBuilderString = await rootBundle.loadString('assets/deckbuilder.json');
  final Map<String, dynamic> deckBuilderData = json.decode(deckBuilderString);
  final List<dynamic> cardDefinitions = deckBuilderData['actionCards'];

  // 2) Build a map of ID -> definition
  final cardDataMap = {
    for (var card in cardDefinitions) 
      card['id'] as int: card
  };

  // 3) If character has deckData, use it
  if (character?.deckData != null && character!.deckData!.isNotEmpty) {
    print('Building action deck from character.deckData: ${character.deckData}');
    return _createDeckFromCharacterData(character.deckData!, cardDataMap);
  }

  // 4) Otherwise, load defaultdeck.json
  print('No custom deck found, falling back to defaultdeck.json');
  final defaultDeckString = await rootBundle.loadString('assets/defaultdeck.json');
  final defaultDeckData = json.decode(defaultDeckString) as Map<String, dynamic>;
  final cardsList = defaultDeckData['cards'] as List;
  final deck = _createDeckFromCardsList(cardsList, cardDataMap);
  return deck;
}

static List<CardData> _createDeckFromCharacterData(
  Map<int, int> deckData,
  Map<int, dynamic> cardDataMap,
) {
  final deck = <CardData>[];

  deckData.forEach((cardId, qty) {
    final definition = cardDataMap[cardId];
    if (definition == null) {
      print('Warning: No definition found for cardId: $cardId');
      return;
    }
    // Add as many copies as qty
    for (int i = 0; i < qty; i++) {
      deck.add(
        CardData(
          id: cardId,
          name: definition['name'],
          type: definition['type'],
          effect: definition['effect'],
          category: definition['category'],
          cost: definition['cost'] ?? 0,
          max: definition['max'] ?? 0,
          metadata: definition['metadata'],
        ),
      );
    }
  });

  // Shuffle if desired
  deck.shuffle();
  print('Created deck with ${deck.length} cards from character.deckData');
  return deck;
}


  static List<CardData> _createDeckFromCardsList(
    List<dynamic> cardsList, 
    Map<int, dynamic> cardDataMap
  ) {
    return cardsList.expand((card) {
      final cardId = card['id'] as int;
      final qty = card['qty'] as int;
      final cardDef = cardDataMap[cardId];
      
      if (cardDef == null) {
        print('Warning: No card definition found for id: $cardId');
        return <CardData>[];
      }

      // Debug print the card definition
      print('Creating card: ${cardDef['name']} with metadata: ${cardDef['metadata']}');
      
      return List.generate(qty, (_) => CardData(
        id: cardId,
        name: cardDef['name'],
        type: cardDef['type'],
        effect: cardDef['effect'],
        category: cardDef['category'],
        cost: cardDef['cost'] ?? 0,
        max: cardDef['max'] ?? 0,
        metadata: cardDef['metadata'],  // Make sure metadata is being passed
      ));
    }).toList()..shuffle();
  }
}