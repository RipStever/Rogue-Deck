// lib/gameplay/charactersection/stat_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stat_display_widget.dart';
import '../gameplay_provider.dart';
import '../character_stats.dart';

class StatSection extends ConsumerStatefulWidget {
  const StatSection({super.key});

  @override
  ConsumerState<StatSection> createState() => _StatSectionState();
}

class _StatSectionState extends ConsumerState<StatSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double> _shakeAnimation = const AlwaysStoppedAnimation(0);
  Animation<double> _healRiseAnimation = const AlwaysStoppedAnimation(0);
  bool _isVibrating = false;
  bool _isHealing = false;
  int _lastBreakpointTriggerHp = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Shake animation for below breakpoint
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Healing rise animation
    _healRiseAnimation = Tween<double>(begin: 0, end: -40).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,  // This curve will give it a nice bounce
    ),
  );
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to get armor type and breakpoint
  (String, double) _getArmorDetails(CharacterStats stats) {
    if (stats.armor == 0) {
      final breakpoint = (stats.maxHp * 0.9).ceil();
      return stats.currentHp < breakpoint ? ('Shattered Armor', 0.9) : ('Unarmored', 0.9);
    }
    
    return ('Unarmored', 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameplayProvider);
    
    final (armorType, breakpointPercentage) = _getArmorDetails(gameState.characterStats);
    final breakpoint = (gameState.characterStats.maxHp * breakpointPercentage).ceil();
    final isBelowBreakpoint = gameState.characterStats.currentHp < breakpoint;
    
    // Trigger vibration when first dropping below breakpoint
    if (isBelowBreakpoint && _lastBreakpointTriggerHp >= breakpoint) {
      _isVibrating = true;
      _animationController.repeat(reverse: true, period: const Duration(milliseconds: 100));
      
      // Stop vibration after 500 milliseconds
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isVibrating = false;
            _animationController.reset();
          });
        }
      });
    }

    // Trigger healing animation when rising above breakpoint
    if (!isBelowBreakpoint && _lastBreakpointTriggerHp < breakpoint) {
      // Only trigger healing animation if this isn't the initial load
      // We can check this by ensuring _lastBreakpointTriggerHp isn't 0
      if (_lastBreakpointTriggerHp != 0) {
        _isHealing = true;
        _animationController.forward();
        
        Future(() {
          if (mounted) {
            ref.read(gameplayProvider.notifier).toggleArmor();
          }
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isHealing = false;
              _animationController.reset();
            });
          }
        });
      }
    }

    // Update the last known HP
    _lastBreakpointTriggerHp = gameState.characterStats.currentHp;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP and Armor Row
          Row(
            children: [
              // HP Section with Custom Input
              Expanded(
                flex: 3,
                child: StatDisplay(
                  title: 'Hit Points',
                  value: gameState.characterStats.currentHp,
                  maxValue: gameState.characterStats.maxHp,
                  armor: gameState.characterStats.armor,
                  overhealth: gameState.characterStats.overhealth,
                  onIncrement: () {},
                  onDecrement: () {},
                  onCustomValueChange: (value) {
                    ref.read(gameplayProvider.notifier).updateHitPointsWithOverhealth(
                      value,
                    );
                  },
                  onOverhealthChange: (value) {
                    ref.read(gameplayProvider.notifier).updateOverhealth(value);
                  },
                  color: _getHpColor(
                    gameState.characterStats.currentHp,
                    gameState.characterStats.maxHp,
                  ),
                  allowCustomInput: true,
                  showBar: true,
                ),
              ),
              const SizedBox(width: 8),
              // Armor Toggle
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Always provide a valid animation value
                    double translationValue = 0;
                    
                    if (_isVibrating) {
                      translationValue = _shakeAnimation.value;
                    } else if (_isHealing) {
                      translationValue = _healRiseAnimation.value;
                    }

                    return Transform.translate(
                      offset: Offset(
                        _isVibrating ? _shakeAnimation.value : 0,  // X translation for shake
                        _isHealing ? _healRiseAnimation.value : 0,  // Y translation for heal
                      ),
                      child: GestureDetector(
                        onTap: () => ref.read(gameplayProvider.notifier).toggleArmor(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gameState.characterStats.overhealth > 0 
                              ? Colors.purple.withOpacity(0.1)
                              : (_isHealing 
                                  ? Colors.green.withOpacity(0.2)
                                  : (isBelowBreakpoint 
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey[850])),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: gameState.characterStats.armor > 0 
                                ? (gameState.characterStats.overhealth > 0 
                                    ? Colors.purple[700]! 
                                    : (_isHealing
                                        ? Colors.green[700]!
                                        : (isBelowBreakpoint ? Colors.red[700]! : Colors.blue[700]!)))
                                : Colors.white24,
                              width: (gameState.characterStats.armor > 0 || isBelowBreakpoint || _isHealing) ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Armor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gameState.characterStats.overhealth > 0 
                                  ? 'Shielded' 
                                  : armorType,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'Breakpoint: $breakpoint',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'When selected, all recorded damage will be halved.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  gameState.characterStats.overhealth > 0 
                                    ? Icons.shield : 
                                    (gameState.characterStats.armor > 0 
                                      ? (isBelowBreakpoint 
                                          ? Icons.shield_outlined 
                                          : (_isHealing
                                              ? Icons.healing
                                              : Icons.shield)) 
                                      : Icons.shield_outlined),
                                  color: gameState.characterStats.overhealth > 0 
                                    ? Colors.purple[400] 
                                    : (_isHealing
                                        ? Colors.green[400]
                                        : (gameState.characterStats.armor > 0 
                                            ? (isBelowBreakpoint 
                                                ? Colors.red[400] 
                                                : Colors.blue[400]) 
                                            : Colors.grey[600])),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Secondary Stats Row
          Row(
            children: [
              // Speed
              Expanded(
                child: StatDisplay(
                  title: 'Speed',
                  value: gameState.characterStats.speed,
                  maxValue: 0, // No max value
                  onIncrement: () => ref.read(gameplayProvider.notifier).updateSpeed(
                    gameState.characterStats.speed + 1,
                  ),
                  onDecrement: () => ref.read(gameplayProvider.notifier).updateSpeed(
                    gameState.characterStats.speed - 1,
                  ),
                  showBar: false,
                  color: Colors.green[700]!,
                  customValueDisplay: '${gameState.characterStats.speed}m',
                ),
              ),
              const SizedBox(width: 8),
              // Mana
              Expanded(
                child: StatDisplay(
                  title: 'Mana',
                  value: gameState.characterStats.mana,
                  maxValue: gameState.characterStats.maxMana,
                  onIncrement: () => ref.read(gameplayProvider.notifier).updateMana(
                    gameState.characterStats.mana + 1,
                  ),
                  onDecrement: () => ref.read(gameplayProvider.notifier).updateMana(
                    gameState.characterStats.mana - 1,
                  ),
                  color: Colors.blue[700]!,
                ),
              ),
              const SizedBox(width: 8),
              // Surge Charge
              Expanded(
                child: StatDisplay(
                  title: 'Surge',
                  value: gameState.characterStats.surgeCharge,
                  maxValue: 5, // Updated max value to 5
                  onIncrement: () => ref.read(gameplayProvider.notifier).updateSurgeCharge(
                    gameState.characterStats.surgeCharge + 1,
                  ),
                  onDecrement: () => ref.read(gameplayProvider.notifier).updateSurgeCharge(
                    gameState.characterStats.surgeCharge - 1,
                  ),
                  onReset: () => ref.read(gameplayProvider.notifier).updateSurgeCharge(0),
                  color: Colors.purple[700]!,
                ),
              ),
              const SizedBox(width: 8),
              // Counter
              Expanded(
                child: StatDisplay(
                  title: 'Counter',
                  value: gameState.characterStats.counter,
                  maxValue: 10,
                  onIncrement: () => ref.read(gameplayProvider.notifier).updateCounter(
                    gameState.characterStats.counter + 1,
                  ),
                  onDecrement: () => ref.read(gameplayProvider.notifier).updateCounter(
                    gameState.characterStats.counter - 1,
                  ),
                  onReset: () => ref.read(gameplayProvider.notifier).updateCounter(0),
                  color: Colors.orange[700]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHpColor(int current, int max) {
    final percentage = current / max;
    if (percentage > 0.6) return Colors.green[400]!;
    if (percentage > 0.3) return Colors.yellow[700]!;
    return Colors.red[400]!;
  }
}