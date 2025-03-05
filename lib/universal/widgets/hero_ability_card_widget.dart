// lib/universal/widgets/hero_ability_card_widget.dart
import 'package:flutter/material.dart';
import '../models/hero_ability_card_model.dart';
import '../cardtext/formatted_game_text.dart';
import 'hero_ability_details_dialog.dart';

class HeroAbilityCard extends StatelessWidget {
  final HeroAbilityCardModel ability;
  final bool isHovered;
  final VoidCallback? onTap;
  final bool preventFullDialog;

  const HeroAbilityCard({
    super.key,
    required this.ability,
    this.isHovered = false,
    this.onTap,
    this.preventFullDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final (primary, secondary, _) = _getTypeColors();

    return GestureDetector(
      onTap: () {
        onTap?.call();
        
        // Only show full dialog if preventFullDialog is false
        if (!preventFullDialog) {
          showDialog(
            context: context,
            builder: (context) => HeroAbilityDetailsDialog(ability: ability),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isHovered ? 220 : 200,
        height: isHovered ? 330 : 300,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered ? primary : Colors.grey[800]!,
            width: isHovered ? 2 : 1,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ability.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_getTypeIcon(), color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${ability.type} - ${ability.tier}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: FormattedGameText(
                    text: ability.effect,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isHovered ? 11 : 10,
                    ),
                    autoSize: true,
                    minFontSize: 8,
                    maxFontSize: 12,
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: secondary.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (ability.aptitude > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Apt ${ability.aptitude}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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

  (Color primary, Color secondary, Color accent) _getTypeColors() {
    switch (ability.type.toLowerCase()) {
      case 'attack':
        return (
          Colors.red.shade900,
          Colors.red.shade800,
          Colors.red.shade300,
        );
      case 'movement':
        return (
          Colors.green.shade900,
          Colors.green.shade800,
          Colors.green.shade300,
        );
      case 'special':
        return (
          Colors.purple.shade900,
          Colors.purple.shade800,
          Colors.purple.shade300,
        );
      default:
        return (
          Colors.grey.shade800,
          Colors.grey.shade700,
          Colors.grey.shade300,
        );
    }
  }

  IconData _getTypeIcon() {
    switch (ability.type.toLowerCase()) {
      case 'attack':
        return Icons.sports_martial_arts;
      case 'movement':
        return Icons.directions_run;
      case 'special':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }
}