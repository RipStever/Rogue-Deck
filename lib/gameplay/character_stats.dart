// lib/gameplay/character_stats.dart

class CharacterStats {
  final int currentHp;
  final int maxHp;
  final int armor;
  final int overhealth;
  final int speed;
  final int mana;
  final int maxMana;
  final int surgeCharge;
  final int counter;

  const CharacterStats({
    this.currentHp = 180,
    this.maxHp = 180,
    this.armor = 0,
    this.overhealth = 0,
    this.speed = 5,
    this.mana = 0,
    this.maxMana = 3,
    this.surgeCharge = 0,
    this.counter = 0,
  });

  CharacterStats copyWith({
    int? currentHp,
    int? maxHp,
    int? armor,
    int? overhealth,
    int? speed,
    int? mana,
    int? maxMana,
    int? surgeCharge,
    int? counter,
  }) {
    return CharacterStats(
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      armor: armor ?? this.armor,
      overhealth: overhealth ?? this.overhealth,
      speed: speed ?? this.speed,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      surgeCharge: surgeCharge ?? this.surgeCharge,
      counter: counter ?? this.counter,
    );
  }

  // Helper method to calculate breakpoint
  int get breakpoint => (maxHp * 0.9).ceil();

  // Helper method to check if armor should be disabled
  bool get shouldDisableArmor => currentHp < breakpoint && overhealth <= 0;
}