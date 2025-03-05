// hero_ability_extraction_service_feats.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/character_model.dart';

class FeatAbilityExtractionService {
  /// Main entry point: builds a list of hero ability CardData objects
  /// from the character’s selectedFeats.
  static Future<List<CardData>> extractFeatAbilities(
    List<Map<String, dynamic>>? selectedFeats,
    CharacterModel character,
  ) async {
    final List<CardData> featAbilities = [];

    if (selectedFeats == null || selectedFeats.isEmpty) {
      print('No feats selected; returning empty feat ability list.');
      return featAbilities;
    }

    // For debugging
    print('Extracting abilities from ${selectedFeats.length} feats...');

    for (final feat in selectedFeats) {
      final featName = feat['name'];
      if (featName == null || featName.isEmpty) {
        print('Encountered feat with no name; skipping.');
        continue;
      }

      // 1) Load the full feat details from Feats.json
      final fullFeat = await _loadFeatDetails(featName);
      if (fullFeat == null) {
        print('No feat details found for "$featName"; skipping.');
        continue;
      }

      // 2) Calculate the relevant aptitude level (optional)
      final aptitudeName = feat['associatedAptitude'] as String?;
      final rawAptitudeValue = _calculateAptitudeValue(character, aptitudeName);
      // You can clamp or interpret this as you like:
      final aptLevel = rawAptitudeValue >= 8 ? 8 : (rawAptitudeValue >= 4 ? 4 : 0);
      print('Feat "$featName": final aptitude level = $aptLevel');

      // 3) Add the base tiers
      featAbilities.addAll(_createTierAbilities(featName, fullFeat));

      // 4) If you have special logic for apt-level changes, apply them
      featAbilities.addAll(_createAptitudeTierAbilities(featName, fullFeat, aptLevel));
    }

    print('Total feat-based abilities created: ${featAbilities.length}');
    return featAbilities;
  }

  // =============================================================================
  //  Private Helpers
  // =============================================================================

  /// Loads all feats from Feats.json and returns the single feat’s details
  static Future<Map<String, dynamic>?> _loadFeatDetails(String featName) async {
    try {
      final allFeats = await _loadAllFeats();
      // find the feat in the list
      for (final feat in allFeats) {
        if (feat['name'] == featName) {
          return feat;
        }
      }
      print('Could not find any feat named "$featName" in Feats.json');
      return null;
    } catch (e) {
      print('Error loading feat details: $e');
      return null;
    }
  }

  /// Loads *all* feats from the JSON file
  static Future<List<Map<String, dynamic>>> _loadAllFeats() async {
    final featsJsonString = await rootBundle.loadString('assets/abilities/Feats.json');
    final List<dynamic> featsData = json.decode(featsJsonString);
    return featsData.map((feat) => Map<String, dynamic>.from(feat)).toList();
  }

  /// Creates the "Basic", "Tier 1", and "Tier 2" abilities from a single feat
  static List<CardData> _createTierAbilities(String featName, Map<String, dynamic> fullFeat) {
    final abilities = <CardData>[];

    // For example, the JSON might have keys: basicEffect, tier1Effect, tier2Effect
    const tiers = [
      {'tier': 'Basic', 'effectKey': 'basicEffect'},
      {'tier': 'Tier 1', 'effectKey': 'tier1Effect'},
      {'tier': 'Tier 2', 'effectKey': 'tier2Effect'},
    ];

    for (final tierData in tiers) {
      final effectKey = tierData['effectKey']!;
      final effect = fullFeat[effectKey];
      if (_isValidEffect(effect)) {
        abilities.add(CardData(
          id: _generateUniqueId(featName, tierData['tier']!),
          name: '$featName - ${tierData['tier']}',
          type: (fullFeat['type'] ?? 'Special') as String,
          effect: effect.toString(),
          category: 'Hero Ability',
        ));
      }
    }

    return abilities;
  }

  /// If your feats have special strings for aptitude-based modifications (like basicApt4Change, etc.),
  /// you can handle that logic here. This is just an example approach matching
  /// what you might have used in your original gameplay_hero_ability_service.
  static List<CardData> _createAptitudeTierAbilities(
    String featName,
    Map<String, dynamic> fullFeat,
    int aptitudeLevel,
  ) {
    final abilities = <CardData>[];

    // For example, you might store these keys in your JSON:
    // "basicApt4Change", "tier1Apt4Change", "tier2Apt4Change"
    // "basicApt8Change", "tier1Apt8Change", "tier2Apt8Change"
    //
    // Then only add them if the feat has that data, and the character’s apt is high enough.

    if (aptitudeLevel < 4) {
      // If user is below 4, no special apt-based abilities
      return abilities;
    }

    // If aptitude is at least 4, check for e.g. "*Apt4Change"
    final isApt8 = aptitudeLevel >= 8;

    // pick which set of keys to check
    final apt4Keys = {
      'Basic': 'basicApt4Change',
      'Tier 1': 'tier1Apt4Change',
      'Tier 2': 'tier2Apt4Change',
    };
    final apt8Keys = {
      'Basic': 'basicApt8Change',
      'Tier 1': 'tier1Apt8Change',
      'Tier 2': 'tier2Apt8Change',
    };

    // For each tier, we see if there’s a *Apt4Change or *Apt8Change
    final relevantKeys = isApt8 ? apt8Keys : apt4Keys;

    // We also need the base tier effect to combine if you do a “modification”
    final baseEffectMap = {
      'Basic': fullFeat['basicEffect'],
      'Tier 1': fullFeat['tier1Effect'],
      'Tier 2': fullFeat['tier2Effect'],
    };

    // Actually iterate over the tiers and add them if present
    relevantKeys.forEach((tierLabel, changeKey) {
      final changedEffect = fullFeat[changeKey];
      final baseEffect = baseEffectMap[tierLabel];
      if (_isValidEffect(changedEffect) && _isValidEffect(baseEffect)) {
        // Combine them, or however you want to represent it
        final combinedEffect = '$baseEffect\n\nAptitude $aptitudeLevel Modification:\n$changedEffect';

        abilities.add(CardData(
          id: _generateUniqueId(featName, '$tierLabel (Apt $aptitudeLevel)'),
          name: '$featName - $tierLabel (Apt $aptitudeLevel)',
          type: fullFeat['type'] ?? 'Special',
          effect: combinedEffect,
          category: 'Hero Ability',
        ));
      }
    });

    return abilities;
  }

  /// Checks that effect is a non-null, non-empty string
  static bool _isValidEffect(dynamic effect) {
    return effect != null && effect.toString().trim().isNotEmpty;
  }

  /// Simple hashing for unique ID generation
  static int _generateUniqueId(String featName, String tier) {
    return featName.hashCode ^ tier.hashCode;
  }

  /// If you need aptitudes from the character.stats, do that here
  static int _calculateAptitudeValue(CharacterModel character, String? aptitudeName) {
    if (aptitudeName == null || character.stats == null) return 0;

    // Some feats might have multiple aptitudes in e.g. "Dexterity/Intelligence"
    // so we split and take the highest
    final aptitudes = aptitudeName.split('/').map((a) => a.trim());
    int highestValue = 0;

    for (final apt in aptitudes) {
      final statBlock = character.stats?[apt];
      if (statBlock != null) {
        final base = statBlock['base'] ?? 0;
        final bonus = statBlock['bonus'] ?? 0;
        final total = base + bonus;
        if (total > highestValue) {
          highestValue = total;
        }
      }
    }
    return highestValue;
  }
}
