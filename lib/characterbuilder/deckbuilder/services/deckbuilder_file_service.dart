import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';

class DeckBuilderFileService {
  final String baseDirectory;
  
  DeckBuilderFileService({required this.baseDirectory});

  Future<List<File>> loadSavedDecks() async {
    try {
      final directory = Directory(baseDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      debugPrint('Loaded ${files.length} deck files');
      return files;
    } catch (e) {
      debugPrint('Error loading saved decks: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> loadDeck(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Deck file not found');
      }
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading deck: $e');
      return null;
    }
  }

  Future<bool> saveDeck(String deckName, Map<String, dynamic> deckData) async {
    try {
      final file = File('$baseDirectory/$deckName.json');
      await file.writeAsString(jsonEncode(deckData));
      return true;
    } catch (e) {
      debugPrint('Error saving deck: $e');
      return false;
    }
  }

  Future<bool> deleteDeck(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting deck: $e');
      return false;
    }
  }

  Future<bool> renameDeck(String oldPath, String newName) async {
    try {
      final oldFile = File(oldPath);
      if (!await oldFile.exists()) {
        return false;
      }

      final directory = oldFile.parent;
      final newFile = File('${directory.path}/$newName.json');

      // Move (rename) the file
      await oldFile.rename(newFile.path);
      return true;
    } catch (e) {
      debugPrint('Error renaming deck: $e');
      return false;
    }
  }

  Future<String?> duplicateDeck(String sourcePath, String newName) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      final directory = sourceFile.parent;
      final newFile = File('${directory.path}/$newName.json');
      
      // Copy the file content
      await sourceFile.copy(newFile.path);
      return newFile.path;
    } catch (e) {
      debugPrint('Error duplicating deck: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadDefaultDeck(BuildContext context) async {
    try {
      final defaultDeckString = await DefaultAssetBundle.of(context)
          .loadString('assets/defaultdeck.json');
      return jsonDecode(defaultDeckString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading default deck: $e');
      return null;
    }
  }

  Future<List<CardData>?> loadDeckbuilderJson(BuildContext context) async {
    try {
      final jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/deckbuilder.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> cardsList = jsonData['actionCards'];
      return cardsList.map((e) => CardData.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading deckbuilder.json: $e');
      return null;
    }
  }
}