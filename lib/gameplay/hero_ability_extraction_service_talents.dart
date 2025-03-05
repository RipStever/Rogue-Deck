import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/character_model.dart';

class TalentAbilityExtractionService {
  /// Main entry point: builds a list of hero ability CardData objects
  /// from the character’s `selectedTalents`.
  static Future<List<CardData>> extractTalentAbilities(
    List<Map<String, dynamic>>? selectedTalents,
    CharacterModel character,
  ) async {
    final List<CardData> talentAbilities = [];

    if (selectedTalents == null || selectedTalents.isEmpty) {
      print('No talents selected; returning empty talent ability list.');
      return talentAbilities;
    }

    // For debugging
    print('Extracting abilities from ${selectedTalents.length} talents...');

    for (final talent in selectedTalents) {
      final talentName = talent['name'];
      if (talentName == null || talentName.isEmpty) {
        print('Encountered a talent with no name; skipping.');
        continue;
      }

      // 1) Load the full talent details from Talents.json
      final fullTalent = await loadTalentDetails(talentName);
      if (fullTalent == null) {
        print('No talent details found for "$talentName"; skipping.');
        continue;
      }

      // 2) (Optional) If you have any special logic for aptitudes, do it here.
      //    For example, if your talents also scale with some stats, you could
      //    do something similar to feats/weapons. We'll omit that for now.

      // 3) Convert the JSON data into hero ability CardData objects.
      //    If your talents only have one effect, that might be all you need:
      talentAbilities.add(_createTalentAbility(talentName, fullTalent));
      
      // If you want multiple tiers or something else, see the feats/weapons
      // examples for how to split them out.
    }

    print('Total talent-based abilities created: ${talentAbilities.length}');
    return talentAbilities;
  }

  // =============================================================================
  //  Private Helpers
  // =============================================================================

  /// Loads a single talent by `talentName` from `Talents.json`.
  static Future<Map<String, dynamic>?> loadTalentDetails(String talentName) async {
    try {
      final allTalents = await _loadAllTalents();
      // find the matching talent in the list
      for (final t in allTalents) {
        if (t['name'] == talentName) {
          return t;
        }
      }
      print('Could not find any talent named "$talentName" in Talents.json');
      return null;
    } catch (e) {
      print('Error loading talent details: $e');
      return null;
    }
  }

  /// Loads *all* talents from the JSON file
  static Future<List<Map<String, dynamic>>> _loadAllTalents() async {
    final talentsJsonString = await rootBundle.loadString('assets/abilities/Talents.json');
    final List<dynamic> talentsData = json.decode(talentsJsonString);
    return talentsData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Creates a single CardData object from the talent’s data.
  /// Adjust the fields or logic to match your JSON structure.
  static CardData _createTalentAbility(String talentName, Map<String, dynamic> fullTalent) {
    final effect = fullTalent['effect'] ?? 'No effect text';
    final pillar = fullTalent['pillar'] ?? 'Special'; 
    // Use pillar or any relevant field as the "type" for your CardData, or adapt as needed

    return CardData(
      id: _generateUniqueId(talentName),
      name: talentName,                      // e.g., "Body Is A Weapon"
      type: pillar,                          // e.g., "Martial", "Elemental", etc.
      effect: effect.toString(),             // Full text of the Talent's effect
      category: 'Hero Ability',              // or "Talent Ability" if you prefer
    );
  }

  /// Simple hashing for unique ID generation
  static int _generateUniqueId(String talentName) {
    return talentName.hashCode;
  }
}
