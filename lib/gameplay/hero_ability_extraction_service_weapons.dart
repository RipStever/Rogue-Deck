// weapon_ability_extraction_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/character_model.dart';

class WeaponAbilityExtractionService {
  /// Main entry point: builds a list of hero ability CardData objects
  /// from the character’s selectedWeapons list.
  static Future<List<CardData>> extractWeaponAbilities(
    List<Map<String, dynamic>>? selectedWeapons,
    CharacterModel character,
  ) async {
    final List<CardData> weaponAbilities = [];

    if (selectedWeapons == null || selectedWeapons.isEmpty) {
      print('No weapons selected; returning empty weapon ability list.');
      return weaponAbilities;
    }

    // For debugging
    print('Extracting abilities from ${selectedWeapons.length} weapons...');

    for (final weapon in selectedWeapons) {
      final weaponName = weapon['name'];
      if (weaponName == null || weaponName.isEmpty) {
        print('Encountered a weapon with no name; skipping.');
        continue;
      }

      // 1) Load the full weapon details from Weapons.json
      final fullWeapon = await _loadWeaponDetails(weaponName);
      if (fullWeapon == null) {
        print('No weapon details found for "$weaponName"; skipping.');
        continue;
      }

      // 2) Calculate any relevant aptitude (optional)
      final aptitudeName = fullWeapon['associatedAptitude'] as String?;
      final rawAptitudeValue = _calculateAptitudeValue(character, aptitudeName);
      // Example clamp logic:
      final aptLevel = rawAptitudeValue >= 8 ? 8 : (rawAptitudeValue >= 4 ? 4 : 0);
      print('Weapon "$weaponName": final aptitude level = $aptLevel');

      // 3) Add the base tiers
      weaponAbilities.addAll(_createTierAbilities(weaponName, fullWeapon));

      // 4) If you have special logic for apt-level changes, apply them
      weaponAbilities.addAll(_createAptitudeTierAbilities(weaponName, fullWeapon, aptLevel));
    }

    print('Total weapon-based abilities created: ${weaponAbilities.length}');
    return weaponAbilities;
  }

  // =============================================================================
  //  Private Helpers
  // =============================================================================

  /// Loads all weapons from Weapons.json, then returns the single weapon’s details
  static Future<Map<String, dynamic>?> _loadWeaponDetails(String weaponName) async {
    try {
      final allWeapons = await _loadAllWeapons();
      // find the weapon in the list
      for (final w in allWeapons) {
        if (w['name'] == weaponName) {
          return w;
        }
      }
      print('Could not find any weapon named "$weaponName" in Weapons.json');
      return null;
    } catch (e) {
      print('Error loading weapon details: $e');
      return null;
    }
  }

  /// Loads *all* weapons from the JSON file
  static Future<List<Map<String, dynamic>>> _loadAllWeapons() async {
    final weaponsJsonString = await rootBundle.loadString('assets/abilities/Weapons.json');
    final List<dynamic> weaponsData = json.decode(weaponsJsonString);
    return weaponsData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Creates the "Basic", "Tier 1", and "Tier 2" abilities for a single weapon
  /// based on keys like basicEffect, tier1Effect, tier2Effect in your JSON.
  static List<CardData> _createTierAbilities(String weaponName, Map<String, dynamic> fullWeapon) {
    final abilities = <CardData>[];

    const tiers = [
      {'tier': 'Basic', 'effectKey': 'basicEffect'},
      {'tier': 'Tier 1', 'effectKey': 'tier1Effect'},
      {'tier': 'Tier 2', 'effectKey': 'tier2Effect'},
    ];

    for (final tierData in tiers) {
      final effectKey = tierData['effectKey']!;
      final effect = fullWeapon[effectKey];
      if (_isValidEffect(effect)) {
        abilities.add(CardData(
          id: _generateUniqueId(weaponName, tierData['tier']!),
          name: '$weaponName - ${tierData['tier']}',
          type: (fullWeapon['type'] ?? 'Attack') as String,
          effect: effect.toString(),
          category: 'Hero Ability',
        ));
      }
    }

    return abilities;
  }

  /// Similar to feats, if your weapons also use aptitude-based modifications,
  /// handle that logic here. If not, you can remove this method.
  static List<CardData> _createAptitudeTierAbilities(
    String weaponName,
    Map<String, dynamic> fullWeapon,
    int aptitudeLevel,
  ) {
    final abilities = <CardData>[];

    if (aptitudeLevel < 4) {
      // If user is below 4, no special apt-based abilities
      return abilities;
    }

    final isApt8 = aptitudeLevel >= 8;

    // For example, keys: "basicApt4Change", "tier1Apt4Change", "tier2Apt4Change"
    // and "basicApt8Change", "tier1Apt8Change", "tier2Apt8Change"
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

    final relevantKeys = isApt8 ? apt8Keys : apt4Keys;

    // We also need the base tier effect to combine if you do a “modification”
    final baseEffectMap = {
      'Basic': fullWeapon['basicEffect'],
      'Tier 1': fullWeapon['tier1Effect'],
      'Tier 2': fullWeapon['tier2Effect'],
    };

    relevantKeys.forEach((tierLabel, changeKey) {
      final changedEffect = fullWeapon[changeKey];
      final baseEffect = baseEffectMap[tierLabel];
      if (_isValidEffect(changedEffect) && _isValidEffect(baseEffect)) {
        final combinedEffect = '$baseEffect\n\nAptitude $aptitudeLevel Modification:\n$changedEffect';

        abilities.add(CardData(
          id: _generateUniqueId(weaponName, '$tierLabel (Apt $aptitudeLevel)'),
          name: '$weaponName - $tierLabel (Apt $aptitudeLevel)',
          type: fullWeapon['type'] ?? 'Attack',
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
  static int _generateUniqueId(String weaponName, String tier) {
    return weaponName.hashCode ^ tier.hashCode;
  }

  /// If you need aptitudes from the character.stats, do that here
  static int _calculateAptitudeValue(CharacterModel character, String? aptitudeName) {
    if (aptitudeName == null || character.stats == null) return 0;

    // For example, "Strength/Intelligence" => we split and check the highest
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
