// lib/gameplay/charactersection/HeroAbilityExtraction/HeroAbilityExtraction_Weapons.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:card_game/universal/models/action_card_data.dart';

class HeroAbilityExtractionService {
  /// Load all weapons from the weapons.json file
  static Future<List<Map<String, dynamic>>> loadAllweapons() async {
    try {
      final jsonString = await rootBundle.loadString('assets/abilities/weapons.json');
      final List<dynamic> weaponsData = json.decode(jsonString);
      
      // Convert to List<Map<String, dynamic>>
      return weaponsData.map((weapon) => Map<String, dynamic>.from(weapon)).toList();
    } catch (e) {
      print('Error loading weapons: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> loadFullweaponDetails(String weaponName) async {
    try {
      final allweapons = await loadAllweapons();
      final weapon = allweapons.firstWhere(
        (weapon) => weapon['name'] == weaponName,
        orElse: () => <String, dynamic>{}, // Return an empty map instead of null
      );

      return weapon.isNotEmpty ? weapon : null;
    } catch (e) {
      print('Error loading full weapon details: $e');
      return null;
    }
  }

  /// Extract hero abilities from a list of selected weapon names
  static Future<List<CardData>> extractHeroAbilities(List<Map<String, dynamic>>? selectedweapons) async {
  // Print debug information
  print('Extracting hero abilities');
  print('Selected weapon: $selectedweapons');

  // If no weapons are selected, return empty list
  if (selectedweapons == null || selectedweapons.isEmpty) {
    print('No weapon selected');
    return [];
  }

  // Load all available weapons
  final allweapons = await loadAllweapons();
  print('Total number of weapons in weapons.json: ${allweapons.length}');

  final List<CardData> heroAbilities = [];

  // Process each selected weapon
  for (var selectedweapon in selectedweapons) {
    final weaponName = selectedweapon['name'] as String;
    print('\n--- Processing weapon: $weaponName ---');

    // Find the full weapon details
    final fullweapon = allweapons.firstWhere(
      (f) => f['name'] == weaponName,
      orElse: () {
        print('Could not find full details for weapon: $weaponName');
        return <String, dynamic>{};
      },
    );

    // Skip if no matching weapon found
    if (fullweapon.isEmpty) {
      print('Skipping weapon due to empty details');
      continue;
    }

    // Print full weapon details for debugging
    print('Full weapon Details:');
    fullweapon.forEach((key, value) {
      print('$key: $value');
    });

    // Define tiers to extract
    final tiers = [
      <String, String>{'tier': 'Basic', 'effectKey': 'basicEffect'},
      <String, String>{'tier': 'Tier 1', 'effectKey': 'tier1Effect'},
      <String, String>{'tier': 'Tier 2', 'effectKey': 'tier2Effect'},
    ];

    // Extract abilities for each tier
    for (var tierData in tiers) {
      final effectKey = tierData['effectKey']!;
      final effect = fullweapon[effectKey];
      
      print('\nProcessing Tier: ${tierData['tier']}');
      print('Effect Key: $effectKey');
      print('Effect Value: $effect');

      if (effect != null && effect.toString().isNotEmpty) {
        heroAbilities.add(CardData(
          id: _generateUniqueId(weaponName, tierData['tier']!),
          name: '$weaponName - ${tierData['tier']}',
          type: (fullweapon['type'] ?? 'Special') as String,
          effect: effect.toString(),
          category: 'Hero Ability',
        ));
      }
    }
  }

  print('\nTotal hero abilities extracted: ${heroAbilities.length}');
  return heroAbilities;
}

  /// Generate a unique ID for each hero ability
  static int _generateUniqueId(String weaponName, String tier) {
    return weaponName.hashCode ^ tier.hashCode;
  }

  /// Optional: Method to print detailed weapon information for debugging
  static Future<void> printweaponDetails(String weaponName) async {
    final allweapons = await loadAllweapons();
    final weapon = allweapons.firstWhere(
      (f) => f['name'] == weaponName,
      orElse: () => <String, dynamic>{}, // Return an empty map instead of null
    );

    if (weapon.isNotEmpty) {
      print('weapon Details for $weaponName:');
      weapon.forEach((key, value) {
        print('$key: $value');
      });
    } else {
      print('No weapon found with name: $weaponName');
    }
  }
}