class CharacterCardData {
  final int id;
  final int number;
  final String name;
  final String type;
  final String category;
  final String aptitude;
  final int aptitudeValue; // Value of associated aptitude (min 1)
  final String tier;
  final String effect;
  final String additionalInfo;

  CharacterCardData({
    required this.id,
    required this.number,
    required this.name,
    required this.type,
    required this.category,
    required this.aptitude,
    required this.aptitudeValue,
    required this.tier,
    required this.effect,
    this.additionalInfo = '',
  });

  // Factory method to create an instance from JSON
  factory CharacterCardData.fromJson(Map<String, dynamic> json) {
    return CharacterCardData(
      id: json['id'],
      number: json['number'],
      name: json['name'],
      type: json['type'],
      category: json['category'],
      aptitude: json['aptitude'],
      aptitudeValue: (json['aptitudeValue'] ?? 1).clamp(1, double.infinity).toInt(),
      tier: json['tier'],
      effect: json['effect'],
      additionalInfo: json['additionalInfo'] ?? '',
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'type': type,
      'category': category,
      'aptitude': aptitude,
      'aptitudeValue': aptitudeValue,
      'tier': tier,
      'effect': effect,
      'additionalInfo': additionalInfo,
    };
  }

  // Replace [Aptitude] placeholders with the aptitudeValue, formatted as bold and keeping brackets
  String formattedEffect() {
    final regex = RegExp(r'\[Aptitude\]');
    return effect.replaceAllMapped(regex, (match) => '[<b>$aptitudeValue</b>]');
  }
}
