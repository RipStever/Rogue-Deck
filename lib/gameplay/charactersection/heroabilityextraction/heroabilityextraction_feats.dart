// lib/gameplay/charactersection/HeroAbilityExtraction/HeroAbilityExtraction_Feats.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:card_game/universal/models/action_card_data.dart';

class HeroAbilityExtractionService {
  /// Load all feats from the Feats.json file
  static Future<List<Map<String, dynamic>>> loadAllFeats() async {
    try {
      final jsonString = await rootBundle.loadString('assets/abilities/Feats.json');
      final List<dynamic> featsData = json.decode(jsonString);
      
      // Convert to List<Map<String, dynamic>>
      return featsData.map((feat) => Map<String, dynamic>.from(feat)).toList();
    } catch (e) {
      print('Error loading feats: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> loadFullFeatDetails(String featName) async {
    try {
      final allFeats = await loadAllFeats();
      final feat = allFeats.firstWhere(
        (feat) => feat['name'] == featName,
        orElse: () => <String, dynamic>{}, // Return an empty map instead of null
      );

      return feat.isNotEmpty ? feat : null;
    } catch (e) {
      print('Error loading full feat details: $e');
      return null;
    }
  }

  /// Extract hero abilities from a list of selected feat names
  static Future<List<CardData>> extractHeroAbilities(List<Map<String, dynamic>>? selectedFeats) async {
  // Print debug information
  print('Extracting hero abilities');
  print('Selected Feats: $selectedFeats');

  // If no feats are selected, return empty list
  if (selectedFeats == null || selectedFeats.isEmpty) {
    print('No feats selected');
    return [];
  }

  // Load all available feats
  final allFeats = await loadAllFeats();
  print('Total number of feats in Feats.json: ${allFeats.length}');

  final List<CardData> heroAbilities = [];

  // Process each selected feat
  for (var selectedFeat in selectedFeats) {
    final featName = selectedFeat['name'] as String;
    print('\n--- Processing Feat: $featName ---');

    // Find the full feat details
    final fullFeat = allFeats.firstWhere(
      (f) => f['name'] == featName,
      orElse: () {
        print('Could not find full details for feat: $featName');
        return <String, dynamic>{};
      },
    );

    // Skip if no matching feat found
    if (fullFeat.isEmpty) {
      print('Skipping feat due to empty details');
      continue;
    }

    // Print full feat details for debugging
    print('Full Feat Details:');
    fullFeat.forEach((key, value) {
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
      final effect = fullFeat[effectKey];
      
      print('\nProcessing Tier: ${tierData['tier']}');
      print('Effect Key: $effectKey');
      print('Effect Value: $effect');

      if (effect != null && effect.toString().isNotEmpty) {
        heroAbilities.add(CardData(
          id: _generateUniqueId(featName, tierData['tier']!),
          name: '$featName - ${tierData['tier']}',
          type: (fullFeat['type'] ?? 'Special') as String,
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
  static int _generateUniqueId(String featName, String tier) {
    return featName.hashCode ^ tier.hashCode;
  }

  /// Optional: Method to print detailed feat information for debugging
  static Future<void> printFeatDetails(String featName) async {
    final allFeats = await loadAllFeats();
    final feat = allFeats.firstWhere(
      (f) => f['name'] == featName,
      orElse: () => <String, dynamic>{}, // Return an empty map instead of null
    );

    if (feat.isNotEmpty) {
      print('Feat Details for $featName:');
      feat.forEach((key, value) {
        print('$key: $value');
      });
    } else {
      print('No feat found with name: $featName');
    }
  }
}