import 'package:flutter/material.dart';
import '../models/hero_ability_card_model.dart';
import '../cardtext/formatted_game_text.dart';

class HeroAbilityDetailsDialog extends StatefulWidget {
  final HeroAbilityCardModel ability;

  const HeroAbilityDetailsDialog({
    super.key, 
    required this.ability,
  });

  @override
  State<HeroAbilityDetailsDialog> createState() => _HeroAbilityDetailsDialogState();
}

class _HeroAbilityDetailsDialogState extends State<HeroAbilityDetailsDialog> {
  bool _isExpanded = true;  // Start expanded by default

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return Colors.red.shade900;
      case 'movement':
        return Colors.green.shade900;
      case 'special':
        return Colors.purple.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildTierPanel({
    required String title,
    required Color headerColor,
    required String mainEffect,
    Map<String, String>? aptitudeChanges,
  }) {
    // Check if the effect is truly empty (accounting for whitespace)
    final bool isEmptyEffect = mainEffect.trim().isEmpty;
    
    // Check if all aptitude changes are empty
    final bool hasAptitudeChanges = aptitudeChanges != null && 
                                   aptitudeChanges.entries.any((entry) => entry.value.trim().isNotEmpty);
                                   
    // The tier is empty if there's no effect text and no aptitude changes
    final bool isEmpty = isEmptyEffect && !hasAptitudeChanges;
    
    final List<String> parts = mainEffect.split('\r\n\r\nMana:');
    final String effectText = parts[0];
    final String? manaText = parts.length > 1 ? parts[1].trim() : null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: isEmpty 
              ? const Text(
                  "N/A",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isEmptyEffect) FormattedGameText(text: effectText),
                    if (manaText != null && manaText.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Mana',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: FormattedGameText(text: manaText)),
                        ],
                      ),
                    ],
                  ],
                ),
          ),
          if (aptitudeChanges != null) ...[
            for (final entry in aptitudeChanges.entries)
              if (entry.value.trim().isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.shade900.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 252, 88, 0).withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Aptitude ${entry.key}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: FormattedGameText(text: entry.value),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.ability.type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: 800,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Banner
              Container(
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  widget.ability.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Expandable Header
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ability.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aptitude: ${widget.ability.aptitude > 0 ? 'Apt ${widget.ability.aptitude}' : 'Base'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),

                      // Fluff Text
                      if (widget.ability.fluffText != null && widget.ability.fluffText!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.ability.fluffText!,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],

                      // Crunch Text
                      if (widget.ability.crunchText != null && widget.ability.crunchText!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade900.withOpacity(0.3)),
                          ),
                          child: Text(
                            widget.ability.crunchText!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (_isExpanded) ...[
                // Tier Panels
                _buildTierPanel(
                  title: 'Basic',
                  headerColor: Colors.red.shade900,
                  mainEffect: widget.ability.basicEffect ?? '',
                  aptitudeChanges: {
                    '4': widget.ability.basicApt4FullText ?? '',
                    '8': widget.ability.basicApt8FullText ?? '',
                  },
                ),
                _buildTierPanel(
                  title: 'Tier 1',
                  headerColor: Colors.red.shade800,
                  mainEffect: widget.ability.tier1Effect ?? '',
                  aptitudeChanges: {
                    '4': widget.ability.tier1Apt4FullText ?? '',
                    '8': widget.ability.tier1Apt8FullText ?? '',
                  },
                ),
                _buildTierPanel(
                  title: 'Tier 2',
                  headerColor: Colors.red.shade900,
                  mainEffect: widget.ability.tier2Effect ?? '',
                  aptitudeChanges: {
                    '4': widget.ability.tier2Apt4FullText ?? '',
                    '8': widget.ability.tier2Apt8FullText ?? '',
                  },
                ),
              ],

              // Close Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}