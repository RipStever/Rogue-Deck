import 'dart:convert';
import 'dart:io';

class FeatService {
  static Future<List<Map<String, dynamic>>> loadFeats() async {
    try {
      final file = File('assets/abilities/Feats.json');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) {
          return [];
        }
        return List<Map<String, dynamic>>.from(json.decode(content));
      }
    } catch (e) {
      print('Error loading Feats: $e');
      // Consider throwing the error to let the UI handle it
    }
    return [];
  }

  static Future<void> saveFeat(List<Map<String, dynamic>> feats) async {
    try {
      final file = File('assets/abilities/Feats.json');
      final jsonString = json.encode(feats);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving Feats: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  static Future<void> deleteFeat(String baseName) async {
    try {
      final file = File('assets/abilities/Feats.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final allFeats = List<Map<String, dynamic>>.from(json.decode(content));

        // Remove all feats that start with the base name
        allFeats.removeWhere((feat) => 
          feat['name'].toString().startsWith(baseName));

        await file.writeAsString(json.encode(allFeats));
      }
    } catch (e) {
      print('Error deleting Feat: $e');
      rethrow;
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> groupFeatsByBaseName(List<Map<String, dynamic>> feats) async {
    final Map<String, List<Map<String, dynamic>>> groupedFeats = {};
    
    for (var feat in feats) {
      String baseName = feat['name']
          .toString()
          .replaceAll(RegExp(r'\s-\s(Basic|Tier \d+).*'), '')
          .trim();
      
      if (!groupedFeats.containsKey(baseName)) {
        groupedFeats[baseName] = [];
      }
      groupedFeats[baseName]!.add(feat);
    }

    return groupedFeats;
  }

  static Future<bool> validateFeat(Map<String, dynamic> feat) async {
    try {
      // Basic validation of required fields
      if (feat['name'] == null || feat['name'].toString().isEmpty) {
        return false;
      }
      
      if (feat['type'] == null || feat['type'].toString().isEmpty) {
        return false;
      }
      
      if (feat['level'] == null) {
        return false;
      }
      
      if (feat['effect'] == null || feat['effect'].toString().isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating feat: $e');
      return false;
    }
  }

  static Future<void> backupFeats() async {
    try {
      final sourceFile = File('assets/abilities/Feats.json');
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/Feats_$timestamp.json');
        
        // Create backup directory if it doesn't exist
        final backupDir = Directory('assets/abilities/backups');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        
        await sourceFile.copy(backupFile.path);
      }
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<void> restoreFromBackup(String backupFileName) async {
    try {
      final backupFile = File('assets/abilities/backups/$backupFileName');
      final targetFile = File('assets/abilities/Feats.json');
      
      if (await backupFile.exists()) {
        await backupFile.copy(targetFile.path);
      } else {
        throw Exception('Backup file not found');
      }
    } catch (e) {
      print('Error restoring from backup: $e');
      rethrow;
    }
  }
}