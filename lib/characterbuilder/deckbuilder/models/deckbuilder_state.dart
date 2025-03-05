import 'package:card_game/universal/models/action_card_data.dart';

class DeckBuilderState {
  Map<int, int> cardQuantities;
  final int maxDeckSize;
  final int maxPoints;
  String selectedDeckName;
  String? selectedDeckPath;
  String sortOption;
  
  DeckBuilderState({
    Map<int, int>? cardQuantities,
    this.maxDeckSize = 30,
    this.maxPoints = 30,
    this.selectedDeckName = "New Deck",
    this.selectedDeckPath,
    this.sortOption = 'Type',
  }) : cardQuantities = cardQuantities ?? {};

  // Basic calculations
  int get totalCards => cardQuantities.values.fold(0, (sum, qty) => sum + qty);
  
  int calculateTotalCost(List<CardData> availableCards) {
    return availableCards.fold(0, (sum, card) {
      final qty = cardQuantities[card.id] ?? 0;
      return sum + (qty * card.cost);
    });
  }

  // Statistics calculations
  Map<String, Map<String, int>> calculateSubTotals(List<CardData> availableCards) {
    final Map<String, Map<String, int>> subTotals = {};
    
    for (final card in availableCards) {
      final qty = cardQuantities[card.id] ?? 0;
      if (!subTotals.containsKey(card.type)) {
        subTotals[card.type] = {'qty': 0, 'pts': 0};
      }
      subTotals[card.type]!['qty'] = subTotals[card.type]!['qty']! + qty;
      subTotals[card.type]!['pts'] = subTotals[card.type]!['pts']! + (qty * card.cost);
    }
    
    return subTotals;
  }

  // Deck validation
  bool isValidDeck() {
    return totalCards <= maxDeckSize;
  }

  bool canAddCard(CardData card, List<CardData> availableCards) {
    final currentQty = cardQuantities[card.id] ?? 0;
    if (currentQty >= card.max) return false;
    
    final newTotalCards = totalCards + 1;
    if (newTotalCards > maxDeckSize) return false;
    
    final newTotalCost = calculateTotalCost(availableCards) + card.cost;
    if (newTotalCost > maxPoints) return false;
    
    return true;
  }

  // Card sorting
  List<CardData> getSortedCards(List<CardData> cards) {
    final sorted = List<CardData>.from(cards);
    switch (sortOption) {
      case 'Type':
        sorted.sort((a, b) {
          final typeComparison = a.type.compareTo(b.type);
          return typeComparison != 0 ? typeComparison : a.cost.compareTo(b.cost);
        });
        break;
      case 'Cost':
        sorted.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case 'Name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return sorted;
  }

  // Card quantity management
  void incrementCard(int cardId) {
    cardQuantities[cardId] = (cardQuantities[cardId] ?? 0) + 1;
  }

  void decrementCard(int cardId) {
    final currentQty = cardQuantities[cardId] ?? 0;
    if (currentQty <= 1) {
      cardQuantities.remove(cardId);
    } else {
      cardQuantities[cardId] = currentQty - 1;
    }
  }

  void clearDeck() {
    cardQuantities.clear();
    selectedDeckName = "New Deck";
    selectedDeckPath = null;
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'cardQuantities': cardQuantities,
      'selectedDeckName': selectedDeckName,
      'selectedDeckPath': selectedDeckPath,
      'sortOption': sortOption,
    };
  }

  factory DeckBuilderState.fromJson(Map<String, dynamic> json) {
    return DeckBuilderState(
      cardQuantities: Map<int, int>.from(json['cardQuantities'] ?? {}),
      selectedDeckName: json['selectedDeckName'] ?? "New Deck",
      selectedDeckPath: json['selectedDeckPath'],
      sortOption: json['sortOption'] ?? 'Type',
    );
  }
}