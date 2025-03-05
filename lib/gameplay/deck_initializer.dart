// lib/gameplay/deck_initializer.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:card_game/universal/models/action_card_data.dart';

class DeckConfiguration {
  final List<CardData> chanceDeck;
  final List<CardData> actionDeck;

  const DeckConfiguration({
    required this.chanceDeck,
    required this.actionDeck,
  });
}

class DeckInitializer {
  static Future<DeckConfiguration> initializeDecks() async {
    try {
      final chanceDeck = await _initializeChanceDeck();
      final actionDeck = await _initializeActionDeck();

      return DeckConfiguration(
        chanceDeck: chanceDeck,
        actionDeck: actionDeck,
      );
    } catch (e) {
      print('Error initializing decks: $e');
      rethrow;
    }
  }

  static Future<List<CardData>> _initializeChanceDeck() async {
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
  }

  static Future<List<CardData>> _initializeActionDeck() async {
    // Load card definitions
    final deckBuilderString = await rootBundle.loadString('assets/deckbuilder.json');
    final List<dynamic> cardDefinitions = json.decode(deckBuilderString);
    final cardDataMap = Map.fromEntries(
      cardDefinitions.map((card) => MapEntry(card['id'] as int, card))
    );

    // Load default deck configuration
    final defaultDeckString = await rootBundle.loadString('assets/defaultdeck.json');
    final defaultDeckData = json.decode(defaultDeckString);
    
    return (defaultDeckData['cards'] as List).expand((card) {
      final cardId = card['id'] as int;
      final qty = card['qty'] as int;
      final cardDef = cardDataMap[cardId];
      
      if (cardDef == null) {
        print('Warning: No card definition found for id: $cardId');
        return <CardData>[];
      }
      
      return List.generate(qty, (_) => CardData(
        id: cardId,
        name: cardDef['name'],
        type: cardDef['type'],
        effect: cardDef['effect'],
        category: cardDef['category'],
        cost: cardDef['cost'] ?? 0,
        max: cardDef['max'] ?? 0,
      ));
    }).toList()..shuffle();
  }

  static Future<Map<String, dynamic>> loadDefaultDeck() async {
    final defaultDeckString = await rootBundle.loadString('assets/defaultdeck.json');
    return json.decode(defaultDeckString) as Map<String, dynamic>;
  }

  static Future<List<CardData>> loadCardDefinitions() async {
    final deckBuilderString = await rootBundle.loadString('assets/deckbuilder.json');
    final List<dynamic> cardDefinitions = json.decode(deckBuilderString);
    return cardDefinitions.map((card) => CardData.fromJson(card)).toList();
  }
}