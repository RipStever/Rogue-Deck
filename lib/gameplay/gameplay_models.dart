// lib/gameplay/gameplay_models.dart
import 'package:card_game/universal/models/action_card_data.dart';

class GameAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GameAction(this.type, this.data) : timestamp = DateTime.now();

  static GameAction drawChance(CardData card) {
    return GameAction('DRAW_CHANCE', {'card': card});
  }

  static GameAction drawAction(CardData card) {
    return GameAction('DRAW_ACTION', {'card': card});
  }

  static GameAction playCard(CardData card) {
    return GameAction('PLAY_CARD', {'card': card});
  }

  static GameAction applyDamage(int amount, bool wasArmorActive) {
    return GameAction('APPLY_DAMAGE', {
      'amount': amount,
      'wasArmorActive': wasArmorActive,
    });
  }

  static GameAction applyHealing(int amount) {
    return GameAction('APPLY_HEALING', {'amount': amount});
  }

  static GameAction toggleArmor(bool newState) {
    return GameAction('TOGGLE_ARMOR', {'newState': newState});
  }
}