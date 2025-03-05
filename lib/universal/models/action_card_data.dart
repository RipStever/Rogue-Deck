import 'package:uuid/uuid.dart';

class CardData {
  final int id;
  final String name;
  final int max;
  final int cost;
  final String type;
  final String category;
  final String effect;
  final String? metadata;  // Added for action parsing
  final String uuid;  // Added for unique identifier

  static const Uuid _uuidGenerator = Uuid();

  CardData({
    required this.id,
    required this.name,
    this.max = 0,
    this.cost = 0,
    this.type = 'Unknown',
    this.category = 'Unknown',
    this.effect = '',
    this.metadata,  // Added to constructor
    String? uuid,  // Added to constructor
  }) : uuid = uuid ?? _uuidGenerator.v4();  // Generate UUID if not provided

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      id: json['id'],
      name: json['name'],
      max: json['max'] ?? 0,
      cost: json['cost'] ?? 0,
      type: json['type'] ?? 'Unknown',
      category: json['category'] ?? 'Unknown',
      effect: json['effect'] ?? '',
      metadata: json['metadata'],  // Added to JSON parsing
      uuid: json['uuid'],  // Added to JSON parsing
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardData && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, 
      'max': max,
      'cost': cost,
      'type': type,
      'category': category,
      'effect': effect,
      'metadata': metadata,  // Added to JSON serialization
      'uuid': uuid,  // Added to JSON serialization
    };
  }
}