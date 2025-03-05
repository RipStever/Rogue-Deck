import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gameplay_state.dart';
import 'game_action.dart';  // Changed this import

/// Manages health-related game state operations including:
/// - HP changes
/// - Armor management
/// - Overhealth
/// - Breakpoint calculations
class GameplayHealthManager {
  final StateNotifier<GameplayState> notifier;

  GameplayHealthManager(this.notifier);

  GameplayState get state => notifier.state;

  void updateArmorState(bool enabled) {
    notifier.state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        armor: enabled ? 1 : 0,
      ),
    );

    _addToHistory(GameAction.toggleArmor(enabled));
  }

  void updateHitPointsWithOverhealth(int value) {
    if (value == 0) return;

    int remainingDamage = value.abs();
    int newOverhealth = state.characterStats.overhealth;
    int newCurrentHp = state.characterStats.currentHp;
    bool wasArmorActive = state.characterStats.armor > 0;

    // Handle healing
    if (value > 0) {
      newCurrentHp = (newCurrentHp + value).clamp(0, state.characterStats.maxHp);
      _addToHistory(GameAction.applyHealing(value));
    } 
    // Handle damage
    else {
      // Apply armor reduction if active
      if (wasArmorActive) {
        remainingDamage = (remainingDamage / 2).floor();
      }

      // Reduce overhealth first
      if (newOverhealth > 0) {
        final overhealthReduction = min(remainingDamage, newOverhealth);
        newOverhealth -= overhealthReduction;
        remainingDamage -= overhealthReduction;
      }

      // Apply remaining damage to HP
      if (remainingDamage > 0) {
        newCurrentHp -= remainingDamage;
      }

      _addToHistory(GameAction.applyDamage(value, wasArmorActive));
    }

    // Update state and check armor conditions
    final newStats = state.characterStats.copyWith(
      currentHp: newCurrentHp.clamp(0, state.characterStats.maxHp),
      overhealth: newOverhealth,
    );

    // Auto-toggle armor if conditions are met
    if (newStats.shouldDisableArmor && wasArmorActive) {
      notifier.state = state.copyWith(
        characterStats: newStats.copyWith(armor: 0),
      );
      _addToHistory(GameAction.toggleArmor(false));
    } else {
      notifier.state = state.copyWith(characterStats: newStats);
    }
  }

  void updateOverhealth(int value) {
    final newOverhealth = (state.characterStats.overhealth + value).clamp(0, 1000000);
    
    // Auto-enable armor when gaining overhealth
    final newArmor = value > 0 && state.characterStats.armor == 0 ? 1 : state.characterStats.armor;
    
    notifier.state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        overhealth: newOverhealth,
        armor: newArmor,
      ),
    );

    if (newArmor != state.characterStats.armor) {
      _addToHistory(GameAction.toggleArmor(true));
    }
  }

  void toggleArmor() {
    notifier.state = state.copyWith(
      characterStats: state.characterStats.copyWith(
        armor: state.characterStats.armor > 0 ? 0 : 1,
      ),
    );
  }

  /// Calculates whether armor should be enabled based on current health
  void recalculateArmorState() {
    final breakpoint = (state.characterStats.maxHp * 0.9).ceil();
    final shouldHaveArmor = state.characterStats.currentHp >= breakpoint || 
                           state.characterStats.overhealth > 0;
    
    if (shouldHaveArmor != (state.characterStats.armor > 0)) {
      toggleArmor();
    }
  }

  /// Helper method for adding actions to history
  void _addToHistory(GameAction action) {
    notifier.state = state.copyWith(
      actionHistory: [...state.actionHistory, action],
    );
  }
}