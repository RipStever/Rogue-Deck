import 'package:card_game/universal/models/character_model.dart';
import 'character_stats.dart';

class StatsService {
  static Future<CharacterStats> initializeCharacterStats(CharacterModel character) async {
    // Get stats from character model
    final stats = character.stats ?? {};
    
    // Calculate base stats
    final baseHp = stats['HP']?['base'] ?? 180;
    final baseSpeed = stats['Speed']?['base'] ?? 5;
    
    // Apply any bonuses from stats
    final bonusHp = stats['HP']?['bonus'] ?? 0;
    final bonusSpeed = stats['Speed']?['bonus'] ?? 0;

    return CharacterStats(
      currentHp: baseHp + bonusHp,
      maxHp: baseHp + bonusHp,
      speed: baseSpeed + bonusSpeed,
      mana: 0,
      maxMana: 3,
      surgeCharge: 0,
      counter: 0,
      armor: 0,
      overhealth: 0,
    );
  }

  static int calculateBreakpoint(int maxHp) {
    return (maxHp * 0.9).ceil();
  }

  static bool shouldDisableArmor(int currentHp, int maxHp, int overhealth) {
    final breakpoint = calculateBreakpoint(maxHp);
    return currentHp < breakpoint && overhealth <= 0;
  }
}