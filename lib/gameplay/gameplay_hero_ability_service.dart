// hero_ability_service.dart

import 'package:card_game/gameplay/hero_ability_extraction_service_feats.dart';
import 'package:card_game/gameplay/hero_ability_extraction_service_weapons.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/universal/models/action_card_data.dart';

class HeroAbilityService {
  static Future<List<CardData>> initializeHeroAbilities(CharacterModel character) async {
    // 1) Feats
    final featAbilities = await FeatAbilityExtractionService.extractFeatAbilities(
      character.selectedFeats,
      character,
    );

    // 2) Weapons
    final weaponAbilities = await WeaponAbilityExtractionService.extractWeaponAbilities(
      character.selectedWeapons,
      character,
    );

    // 3) Combine them
    final combinedAbilities = <CardData>[];
    combinedAbilities.addAll(featAbilities);
    combinedAbilities.addAll(weaponAbilities);

    print('HeroAbilityService: total combined abilities: ${combinedAbilities.length}');
    return combinedAbilities;
  }
}
