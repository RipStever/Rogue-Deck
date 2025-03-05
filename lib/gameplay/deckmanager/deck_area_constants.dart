// lib/gameplay/deckmanager/deck_area_constants.dart

class DeckAreaConstants {
  static const double cardRatio = 2.5 / 3.5;

  // Draw deck defaults
  static const double mainDeckHeight = 140.0;
  static double get mainDeckWidth => mainDeckHeight * cardRatio;

  // Discard pile defaults - slightly smaller
  static const double discardHeight = 120.0;
  static double get discardWidth => discardHeight * cardRatio;
}