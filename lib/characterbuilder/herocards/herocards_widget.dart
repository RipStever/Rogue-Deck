// lib/characterbuilder/hero_cards/hero_cards_widget.dart
import 'package:flutter/material.dart';
import '../../universal/models/character_model.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../universal/cardtext/formatted_game_text.dart';

class HeroCardsWidget extends StatelessWidget {
  final CharacterModel characterModel;

  const HeroCardsWidget({
    super.key,
    required this.characterModel,
  });

  (List<Color>, IconData) _getTypeStyleData(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return (
          [Colors.red.shade700, Colors.red.shade500],
          Icons.sports_martial_arts
        );
      case 'movement':
        return (
          [Colors.green.shade700, Colors.green.shade500],
          Icons.directions_run
        );
      case 'special':
        return (
          [Colors.purple.shade700, Colors.purple.shade500],
          Icons.auto_awesome
        );
      default:
        return (
          [Colors.grey.shade700, Colors.grey.shade500],
          Icons.help_outline
        );
    }
  }

  List<Widget> _getStackedIcons(IconData baseIcon, String tier) {
    final List<Widget> stackedIcons = [];
    
    switch (tier) {
      case 'Basic':
        stackedIcons.add(Icon(
          baseIcon,
          color: Colors.white,
          size: 24,
        ));
        break;
      
      case 'Tier 1':
        stackedIcons.addAll([
          const Icon(
            Icons.brightness_low,
            color: Colors.white60,
            size: 32,
          ),
          Icon(
            baseIcon,
            color: Colors.white,
            size: 26,
          ),
        ]);
        break;
      
      case 'Tier 2':
        // More dramatic effect for Tier 2
        stackedIcons.addAll([
          const Icon(
            Icons.brightness_low,
            color: Colors.white38,
            size: 40,
          ),
          const Icon(
            Icons.star,
            color: Colors.white60,
            size: 36,
          ),
          Icon(
            baseIcon,
            color: Colors.white,
            size: 28,
          ),
        ]);
        break;
        
      default:
        stackedIcons.add(Icon(
          baseIcon,
          color: Colors.white,
          size: 24,
        ));
    }
    
    return stackedIcons;
  }

  Color _getTierShade(String tier) {
    switch (tier) {
      case 'Basic':
        return Colors.black.withOpacity(0.1);
      case 'Tier 1':
        return Colors.black.withOpacity(0.2);
      case 'Tier 2':
        return Colors.black.withOpacity(0.3);
      default:
        return Colors.black.withOpacity(0.1);
    }
  }

  Widget _buildFeatCard(Map<String, dynamic> feat, String tier, String effect) {
    if (effect.isEmpty) return const SizedBox.shrink();

    final (gradientColors, typeIcon) = _getTypeStyleData(feat['type']);
    final tierShade = _getTierShade(tier);

    return Container(
      width: 240,  // 2.5 inches at 96 DPI
      height: 336, // 3.5 inches at 96 DPI
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: gradientColors[0], width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors[0],
                    gradientColors[1],
                    gradientColors[0].withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: _getStackedIcons(typeIcon, tier),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AutoSizeText(
                          feat['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          maxFontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Type and Tier
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              color: tierShade,
              child: Text(
                '${feat['type']} - $tier',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Effect Text
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: FormattedGameText(
                  text: effect,
                  autoSize: true,
                  minFontSize: 8,
                  maxFontSize: 14,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hero Cards',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 0.0,
                runSpacing: 0.0,
                children: characterModel.selectedFeats?.expand((feat) => [
                  _buildFeatCard(feat, 'Basic', feat['basicEffect'] ?? ''),
                  _buildFeatCard(feat, 'Tier 1', feat['tier1Effect'] ?? ''),
                  _buildFeatCard(feat, 'Tier 2', feat['tier2Effect'] ?? ''),
                ]).where((widget) => widget is! SizedBox).toList() ?? [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}