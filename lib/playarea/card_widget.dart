import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../universal/models/action_card_data.dart';

class GameCard extends StatelessWidget {
  final CardData cardData;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHovered;

  const GameCard({
    super.key,
    required this.cardData,
    required this.isSelected,
    required this.onTap,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    Color headerColor = _getHeaderColor(cardData.type);
    Color footerColor = _getFooterColor(cardData.category);

    // Adjust scaling to retain original proportions
    double cardWidth = isHovered ? 240 : 120;
    double cardHeight = isHovered ? 320 : 180;

    return Semantics(
      label: 'Card name: ${cardData.name}, Type: ${cardData.type}, Category: ${cardData.category}',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: isHovered
                    ? [
                        const BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(4, 4))
                      ]
                    : [
                        const BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))
                      ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Column(
                      children: [
                        AutoSizeText(
                          cardData.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getTypeIcon(cardData.type),
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cardData.type,
                                style: const TextStyle(fontSize: 9, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 11, color: Colors.black),
                            children: _buildEffectText(cardData.effect),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: footerColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(cardData.category),
                          color: Colors.black87,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cardData.category,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildEffectText(String effect) {
    final boldWords = ['Reaction:', 'Special:', 'Note:', 'Requirement:', 'Scene:', 'Drawback:'];
    List<TextSpan> spans = [];

    for (String line in effect.split('\n')) {
      String boldWord = boldWords.firstWhere(
        (bold) => line.startsWith(bold),
        orElse: () => '',
      );

      if (boldWord.isNotEmpty) {
        spans.add(TextSpan(
          text: boldWord,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        spans.add(TextSpan(
          text: '${line.substring(boldWord.length)}\n',
        ));
      } else {
        spans.add(TextSpan(
          text: '$line\n',
        ));
      }
    }

    return spans;
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Movement':
        return Icons.directions_run;
      case 'Ability':
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

  Color _getHeaderColor(String type) {
    switch (type) {
      case 'Movement':
        return Colors.green;
      case 'Ability':
        return Colors.purple;
      default:
        return Colors.redAccent;
    }
  }

  Color _getFooterColor(String category) {
    switch (category) {
      case 'Mythic':
        return Colors.amberAccent;
      case 'Common':
        return Colors.brown[200]!;
      case 'Rare':
        return const Color.fromARGB(255, 72, 185, 238);
      case 'Legendary':
        return Colors.purple[200]!;
      default:
        return Colors.grey;
    }
  }
}
