import 'package:card_game/universal/models/action_card_data.dart';

class ChanceCardData extends CardData {
  final int qty;

  ChanceCardData({
    required super.id,
    required super.name,
    required this.qty,
    required super.type,
    required super.effect,
    required String super.uuid,
    String? metadata,
  }) : super(
          category: 'Chance',
          metadata: metadata ?? '',  // Ensure metadata is never null
        );

  factory ChanceCardData.fromJson(Map<String, dynamic> json) {
    return ChanceCardData(
      id: json['id'],
      name: json['name'],
      qty: json['qty'] ?? 1, // Default to 1 if qty is missing
      type: json['type'],
      effect: json['effect'],
      uuid: json['uuid'],  // Added to JSON parsing
    );
  }

  factory ChanceCardData.fromCardData(CardData cardData) {
    return ChanceCardData(
      id: cardData.id,
      name: cardData.name,
      qty: 1, // Default to 1 for conversion
      type: cardData.type,
      effect: cardData.effect,
      uuid: cardData.uuid,  // Added to conversion
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'qty': qty,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'effect': effect,
      'uuid': uuid,  // Added to map
    };
  }

  factory ChanceCardData.fromMap(Map<String, dynamic> map) {
    return ChanceCardData(
      id: map['id'],
      name: map['name'],
      qty: 1,
      type: map['type'],
      effect: map['effect'],
      uuid: map['uuid'],  // Added to map parsing
    );
  }
}
