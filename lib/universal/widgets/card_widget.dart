import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../models/action_card_data.dart';
import '../cardtext/formatted_game_text.dart';

class GameCard extends StatelessWidget {
  final CardData cardData;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHovered;
  final Animation<double>? pulseAnimation;
  final double? width;
  final double? height;

  const GameCard({
    super.key,
    required this.cardData,
    required this.isSelected,
    required this.onTap,
    required this.isHovered,
    this.pulseAnimation,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided dimensions if available, otherwise calculate based on state
    final cardWidth = width ?? (isHovered || isSelected ? 240 : 120);
    final cardHeight = height ?? (isHovered || isSelected ? 320 : 180);

    Color baseColor = _getBaseColor(cardData.type);
    Color textColor = Colors.white.withOpacity(0.9);

    return Semantics(
      label:
          'Card name: ${cardData.name}, Type: ${cardData.type}, Category: ${cardData.category}',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor,
                    baseColor.withOpacity(0.8),
                    baseColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : isHovered
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                  width: isSelected ? 2 : (isHovered ? 2 : 1),
                ),
                boxShadow: [
                  if (isSelected && pulseAnimation != null)
                    BoxShadow(
                      color: Colors.white
                          .withOpacity(0.3 + (pulseAnimation!.value * 0.2)),
                      blurRadius: 8 + (pulseAnimation!.value * 4),
                      spreadRadius: 2 + (pulseAnimation!.value * 2),
                    )
                  else if (isHovered)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(4, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        AutoSizeText(
                          cardData.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTypeIcon(cardData.type),
                              color: textColor.withOpacity(0.8),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatType(cardData.type),
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SingleChildScrollView(
                        child: FormattedGameText(
                          text: cardData.effect,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            height: 1.4,
                          ),
                          autoSize: true,
                          minFontSize: 9,
                          maxFontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(cardData.category),
                          color: textColor.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cardData.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: baseColor,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'Movement':
        return 'Movement';
      case 'Special':
        return 'Special';
      case 'Attack':
        return 'Attack';
      default:
        return type;
    }
  }

  Color _getBaseColor(String type) {
    switch (type.toLowerCase()) {
      case 'movement':
        return const Color(0xFF1B5E20); // Dark green
      case 'special':
        return const Color(0xFF4A148C); // Dark purple
      case 'attack':
        return const Color(0xFF7f1D1D); // Dark red
      default:
        return const Color(0xFF424242); // Dark grey
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Movement':
        return Icons.directions_run;
      case 'Special':
        return Icons.auto_awesome;
      case 'Attack':
        return Icons.sports_martial_arts;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mythic':
        return Icons.star;
      case 'Common':
        return Icons.circle;
      case 'Rare':
        return Icons.diamond;
      default:
        return Icons.help_outline;
    }
  }
}