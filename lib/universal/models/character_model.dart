class CharacterModel {
  String name;
  String playerName;
  String selectedDeckName; // Only store deck name here
  String? selectedClass;
  int selectedLevel;
  Map<String, Map<String, int>>? stats;
  Map<int,int>? deckData;

  // Keep feats and weapons from the newer version
  List<Map<String, dynamic>>? selectedFeats;
  List<Map<String, dynamic>>? selectedWeapons;
  List<Map<String, dynamic>>? selectedTalents;

  CharacterModel({
    required this.name,
    required this.playerName,
    required this.selectedDeckName,
    required this.selectedLevel,
    this.deckData,
    this.selectedClass,
    this.stats,
    this.selectedFeats,
    this.selectedWeapons,
    this.selectedTalents,
  });

  // CopyWith method
  CharacterModel copyWith({
    String? name,
    String? playerName,
    String? selectedDeckName,
    String? selectedClass,
    int? selectedLevel,
    Map<String, Map<String, int>>? stats,
    Map<int,int>? deckData,
    List<Map<String, dynamic>>? selectedFeats,
    List<Map<String, dynamic>>? selectedWeapons,
    List<Map<String, dynamic>>? selectedTalents,
  }) {
    return CharacterModel(
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      selectedDeckName: selectedDeckName ?? this.selectedDeckName,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedClass: selectedClass ?? this.selectedClass,
      stats: stats ?? this.stats,
      deckData: deckData ?? this.deckData,
      selectedFeats: selectedFeats ?? this.selectedFeats,
      selectedWeapons: selectedWeapons ?? this.selectedWeapons,
      selectedTalents: selectedTalents ?? this.selectedTalents,
    );
  }

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    print('Parsing character JSON: $json');

     // parse deckData if present
    final deckDataRaw = json['deckData'] as Map<String,dynamic>?;
      Map<int,int>? deckMap;
      if (deckDataRaw != null) {
        deckMap = deckDataRaw.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    return CharacterModel(
      name: json['name'] as String? ?? '',
      playerName: json['playerName'] as String? ?? '',
      selectedDeckName: (json['deck'] as String?) ?? 'Default Deck',
      selectedLevel: json['level'] as int? ?? 1,
      selectedClass: json['class'] as String?,
      stats: _parseStats(json['stats']),
      selectedFeats: _parseFeats(json['feats']),
      selectedWeapons: _parseWeapons(json['selectedWeapons']),
      // Parse talents similarly:
      selectedTalents: _parseTalents(json['selectedTalents']),
      deckData: (json['deckData'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'playerName': playerName,
      'deck': selectedDeckName,
      'class': selectedClass,
      'level': selectedLevel,
      'stats': stats?.map((statKey, statMap) => MapEntry(statKey, statMap)),
      'feats': selectedFeats?.map((feat) => {'name': feat['name']}).toList(),
      'selectedWeapons':
          selectedWeapons?.map((w) => {'name': w['name']}).toList(),

      // Save talents:
      'selectedTalents':
          selectedTalents?.map((talent) => {'name': talent['name']}).toList(),

      'deckData': deckData,
    };
  }

  // Parsing logic for stats
  static Map<String, Map<String, int>>? _parseStats(dynamic rawStats) {
    if (rawStats is Map) {
      return rawStats.map<String, Map<String, int>>((statKey, statVal) {
        if (statVal is Map) {
          final statValMap = statVal.map<String, int>((k, v) {
            return MapEntry(k.toString(), (v as int?) ?? 0);
          });
          return MapEntry(statKey.toString(), statValMap);
        }
        return MapEntry(statKey.toString(), <String, int>{});
      });
    }
    return null;
  }

  // Parsing logic for feats
  static List<Map<String, dynamic>>? _parseFeats(dynamic rawFeats) {
    if (rawFeats == null) return null;
    if (rawFeats is List) {
      return List<Map<String, dynamic>>.from(rawFeats.map((feat) {
        if (feat is Map) {
          return Map<String, dynamic>.from(feat);
        }
        return {'name': feat.toString()};
      }));
    }
    return null;
  }

  // Parsing logic for weapons
  static List<Map<String, dynamic>>? _parseWeapons(dynamic rawWeapons) {
    if (rawWeapons == null) return null;
    if (rawWeapons is List) {
      return List<Map<String, dynamic>>.from(rawWeapons.map((w) {
        if (w is Map) {
          return Map<String, dynamic>.from(w);
        }
        return {'name': w.toString()};
      }));
    }
    return null;
  }

  // Parsing logic for talents
  static List<Map<String, dynamic>>? _parseTalents(dynamic rawTalents) {
    if (rawTalents == null) return null;
    if (rawTalents is List) {
      return List<Map<String, dynamic>>.from(rawTalents.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return {'name': item.toString()};
      }));
    }
    return null;
  }
}
