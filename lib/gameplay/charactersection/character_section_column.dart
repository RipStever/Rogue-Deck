// lib/gameplay/charactersection/character_section_column.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stat_section.dart';
import 'hero_abilities_section.dart';
import 'package:card_game/gameplay/charactersection/talents_section.dart';

class CharacterSectionColumn extends ConsumerStatefulWidget {
  const CharacterSectionColumn({super.key});

  @override
  ConsumerState<CharacterSectionColumn> createState() => _CharacterSectionColumnState();
}

class _CharacterSectionColumnState extends ConsumerState<CharacterSectionColumn> {
  bool _showAbilities = true;

  void _toggleSection(bool showAbilities) {
    setState(() {
      _showAbilities = showAbilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Stats Section (Top Half)
          const Expanded(
            flex: 4,
            child: StatSection(),
          ),
          
          const SizedBox(height: 8),
          
          // Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _toggleSection(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showAbilities ? Colors.green[700] : const Color.fromARGB(255, 153, 153, 153),
                ),
                child: const Text('Abilities'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _toggleSection(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showAbilities ? Colors.green[700] : const Color.fromARGB(255, 153, 153, 153),
                ),
                child: const Text('Talents'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Conditional Section
          Expanded(
            flex: 9,
            child: _showAbilities ? const HeroAbilitiesSection() : const TalentsSection(),
          ),
        ],
      ),
    );
  }
}