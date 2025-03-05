// lib/gameplay/deckmanager/deck_area_decksizes.dart

import 'package:flutter/material.dart';
import 'deck_area_widget.dart';

/// Configuration class for deck area styling and sizing
class DeckAreaStyle {
  final double width;
  final double height;
  final double hoverHeightIncrease;
  final double titleFontSize;
  final double hoverTitleFontSize;
  final double cardCountFontSize;
  final Color baseColor;
  final Color hoverBorderColor;
  final Color normalBorderColor;
  final EdgeInsets padding;

  const DeckAreaStyle({
    required this.width,
    required this.height,
    this.hoverHeightIncrease = 20.0,
    this.titleFontSize = 14.0,
    this.hoverTitleFontSize = 16.0,
    this.cardCountFontSize = 12.0,
    required this.baseColor,
    this.hoverBorderColor = Colors.white38,
    this.normalBorderColor = Colors.white24,
    this.padding = const EdgeInsets.all(8.0),
  });
}

/// Style configurations for different deck types
class DeckAreaSizes {
  static const Map<DeckType, DeckAreaStyle> deckStyles = {
    DeckType.chance: DeckAreaStyle(
      width: 100.0,
      height: 140.0,
      baseColor: Color(0xFFB22222),
      titleFontSize: 14.0,
      hoverTitleFontSize: 14.0,
      cardCountFontSize: 12.0,
    ),
    
    DeckType.chanceDiscard: DeckAreaStyle(
      width: 140.0,
      height: 100.0,
      baseColor: Color.fromARGB(171, 178, 34, 34),
      titleFontSize: 14.0,
      hoverTitleFontSize: 14.0,
      cardCountFontSize: 12.0,
    ),
    
    DeckType.action: DeckAreaStyle(
      width: 100.0,
      height: 140.0,
      baseColor: Color.fromARGB(255, 34, 36, 178),
      titleFontSize: 14.0,
      hoverTitleFontSize: 14.0,
      cardCountFontSize: 12.0,
    ),
    
    DeckType.actionDiscard: DeckAreaStyle(
      width: 140.0,
      height: 100.0,
      baseColor: Color.fromARGB(157, 34, 36, 178),
      titleFontSize: 14.0,
      hoverTitleFontSize: 14.0,
      cardCountFontSize: 12.0,
    ),
  };

  /// Get style configuration for a specific deck type
  static DeckAreaStyle getStyleForDeck(DeckType deckType) {
    return deckStyles[deckType] ?? const DeckAreaStyle(
      width: 100.0,
      height: 140.0,
      baseColor: Colors.grey,
    );
  }

  /// Check if deck type is a discard pile
  static bool isDiscardPile(DeckType deckType) {
    return deckType == DeckType.chanceDiscard || deckType == DeckType.actionDiscard;
  }

  /// Get gradient colors for a deck type
  static List<Color> getGradientColors(DeckType deckType) {
    final style = getStyleForDeck(deckType);
    return [
      style.baseColor,
      style.baseColor.withOpacity(0.8),
    ];
  }

  /// Get text style for deck title
  static TextStyle getTitleStyle(DeckType deckType, {bool isHovered = false}) {
    final style = getStyleForDeck(deckType);
    return TextStyle(
      color: Colors.white,
      fontSize: isHovered ? style.hoverTitleFontSize : style.titleFontSize,
      fontWeight: FontWeight.bold,
    );
  }

  /// Get text style for card count
  static TextStyle getCardCountStyle(DeckType deckType) {
    final style = getStyleForDeck(deckType);
    return TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: style.cardCountFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  /// Get container decoration for deck area
  static BoxDecoration getDecoration(DeckType deckType, {required bool isHovered}) {
    final style = getStyleForDeck(deckType);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: getGradientColors(deckType),
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isHovered ? style.hoverBorderColor : style.normalBorderColor,
        width: isHovered ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
        if (isHovered)
          BoxShadow(
            color: style.baseColor.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
      ],
    );
  }

  /// Get card count container decoration
  static BoxDecoration getCardCountDecoration() {
    return BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(12),
    );
  }
}