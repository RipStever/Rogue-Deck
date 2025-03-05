// lib/universal/models/hero_ability_card_model.dart

import 'action_card_data.dart';
import 'package:card_game/gameplay/charactersection/heroabilityextraction/heroabilityextraction_feats.dart' as FeatService;
import 'package:card_game/gameplay/charactersection/heroabilityextraction/heroabilityextraction_weapons.dart' as WeaponService;

class HeroAbilityCardModel {
  final int id;  // Added id field
  final String name;
  final String type;
  final String effect;
  final String tier;
  final int aptitude;
  final String? requirement;
  final String? pillar;
  final String? fluffText;
  final String? crunchText;

  // Base effects for each tier
  final String? basicEffect;
  final String? tier1Effect;
  final String? tier2Effect;

  // Aptitude modifications
  final String? basicApt4FullText;
  final String? basicApt8FullText;
  final String? tier1Apt4FullText;
  final String? tier1Apt8FullText;
  final String? tier2Apt4FullText;
  final String? tier2Apt8FullText;

  const HeroAbilityCardModel({
    required this.id,  // Added to constructor
    required this.name,
    required this.type,
    required this.effect,
    required this.tier,
    this.aptitude = 0,
    this.requirement,
    this.pillar,
    this.fluffText,
    this.crunchText,
    this.basicEffect,
    this.basicApt4FullText,
    this.basicApt8FullText,
    this.tier1Effect,
    this.tier1Apt4FullText,
    this.tier1Apt8FullText,
    this.tier2Effect,
    this.tier2Apt4FullText,
    this.tier2Apt8FullText,
  });

  static Future<HeroAbilityCardModel> fromCardData(CardData cardData) async {
    String tier = _extractTier(cardData.name);
    int aptitude = _extractAptitude(cardData.name);
    
    String cleanName = cardData.name
        .replaceAll(RegExp(r' - (Basic|Tier \d+).*'), '')
        .replaceAll(RegExp(r' \(Apt \d+\)'), '')
        .trim();
    
    // Load details from either feats or weapons based on the ability using null-aware assignment
    var fullDetails = await FeatService.HeroAbilityExtractionService.loadFullFeatDetails(cleanName) 
      ?? await WeaponService.HeroAbilityExtractionService.loadFullweaponDetails(cleanName);

    return HeroAbilityCardModel(
      id: cardData.id,
      name: cleanName,
      type: cardData.type,
      effect: cardData.effect,
      tier: tier,
      aptitude: aptitude,
      requirement: fullDetails?['requirement'],
      pillar: fullDetails?['pillar'],
      fluffText: fullDetails?['fluff'],
      crunchText: fullDetails?['crunch'],
      basicEffect: fullDetails?['basicEffect'],
      basicApt4FullText: fullDetails?['basicApt4Change'],
      basicApt8FullText: fullDetails?['basicApt8Change'],
      tier1Effect: fullDetails?['tier1Effect'],
      tier1Apt4FullText: fullDetails?['tier1Apt4Change'],
      tier1Apt8FullText: fullDetails?['tier1Apt8Change'],
      tier2Effect: fullDetails?['tier2Effect'],
      tier2Apt4FullText: fullDetails?['tier2Apt4Change'],
      tier2Apt8FullText: fullDetails?['tier2Apt8Change'],
    );
  }

  static String _extractTier(String name) {
    if (name.contains('- Basic')) return 'Basic';
    if (name.contains('- Tier 1')) return 'Tier 1';
    if (name.contains('- Tier 2')) return 'Tier 2';
    return 'Basic';
  }

  static int _extractAptitude(String name) {
    final aptMatch = RegExp(r'\(Apt (\d+)\)').firstMatch(name);
    if (aptMatch != null) {
      return int.parse(aptMatch.group(1)!);
    }
    return 0;
  }

  String get displayName => name + (aptitude > 0 ? ' (Apt $aptitude)' : '');

  bool get hasRequirements => requirement != null && requirement!.isNotEmpty;

  String get formattedRequirements => requirement?.split(',').map((r) => r.trim()).join('\n') ?? '';

  int get tierLevel {
    switch (tier.toLowerCase()) {
      case 'basic':
        return 0;
      case 'tier 1':
        return 1;
      case 'tier 2':
        return 2;
      default:
        return 0;
    }
  }
}