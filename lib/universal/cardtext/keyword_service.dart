// lib/universal/services/keyword_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';  // Add this import for Color

class KeywordDefinition {
  final Color color;
  final List<String> patterns;
  final List<String>? terms;

  KeywordDefinition({
    required this.color,
    this.patterns = const [],
    this.terms = const [],
  });

  List<RegExp> get regexPatterns {
    final List<RegExp> regexes = [];
    
    // Add pattern-based regexes
    for (final pattern in patterns) {
      regexes.add(RegExp(pattern));
    }
    
    // Add exact-match terms
    if (terms != null) {
      final termPattern = terms!.map((term) => RegExp.escape(term)).join('|');
      if (termPattern.isNotEmpty) {
        regexes.add(RegExp('\\b($termPattern)\\b'));
      }
    }
    
    return regexes;
  }

  factory KeywordDefinition.fromJson(Map<String, dynamic> json) {
    return KeywordDefinition(
      color: Color(int.parse(json['color'].substring(1), radix: 16) | 0xFF000000),
      patterns: List<String>.from(json['patterns'] ?? []),
      terms: List<String>.from(json['terms'] ?? []),
    );
  }
}

class KeywordService {
  // Singleton pattern
  static final KeywordService _instance = KeywordService._internal();
  factory KeywordService() => _instance;
  KeywordService._internal();

  // Map to store keywords and their descriptions
  Map<String, String> _keywords = {};
  final Map<String, KeywordDefinition> _definitions = {};
  bool _initialized = false;

  // Initialize the service by loading keywords
  Future<void> initialize() async {
    if (_initialized) return;
    print("Starting KeywordService initialization...");

    try {
      // Load basic keywords from a JSON asset
      final jsonString = await rootBundle.loadString('assets/keywords.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Convert the dynamic values to String
      _keywords = data.map((key, value) => MapEntry(key, value.toString()));
      
      // Load pattern-based keywords if available
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        final keywordFiles = manifestMap.keys
            .where((String key) => key.startsWith('assets/keywords/') && key.endsWith('.json'));
        
        print("Found keyword files: ${keywordFiles.toList()}");
        
        for (final file in keywordFiles) {
          final content = await rootBundle.loadString(file);
          final filename = file.split('/').last.replaceAll('.json', '');
          _definitions[filename] = KeywordDefinition.fromJson(json.decode(content));
        }
      } catch (e) {
        print('No advanced keyword definitions found: $e');
      }
      
      _initialized = true;
      print("KeywordService initialization complete");
    } catch (e) {
      print('Failed to initialize KeywordService: $e');
      // Initialize with empty maps if loading fails
      _keywords = {};
      _initialized = true;
    }
  }

  // Get the description for a keyword
  String getKeywordDescription(String keyword) {
    return _keywords[keyword.toLowerCase()] ?? 'No description available.';
  }

  // Check if a word is a keyword
  bool isKeyword(String word) {
    return _keywords.containsKey(word.toLowerCase());
  }

  List<(RegExp, Color)> getAllPatterns() {
    final patterns = <(RegExp, Color)>[];
    
    for (final definition in _definitions.values) {
      for (final regex in definition.regexPatterns) {
        patterns.add((regex, definition.color));
      }
    }
    
    return patterns;
  }
}