// lib/characterbuilder/feats/feat_service.dart
import 'dart:convert';
import 'dart:io';

class FeatService {
  static Future<List<Map<String, dynamic>>> loadFeats() async {
    try {
      final file = File('assets/abilities/Feats.json');
      
      if (await file.exists()) {
        print('=== FeatService loadFeats ===');
        final content = await file.readAsString();       
        print('Content loaded, length: ${content.length}');
        
        final List<dynamic> feats = json.decode(content);
        print('Parsed ${feats.length} feats');
        
        if (feats.isNotEmpty) {
          print('First feat data:');
          print('Name: ${feats.first['name']}');
          print('Basic Effect: ${feats.first['basicEffect']}');
          print('Tier 1 Effect: ${feats.first['tier1Effect']}');
          print('Tier 2 Effect: ${feats.first['tier2Effect']}');
        }

        // Convert directly to List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(feats);
      }
      print('Feats.json file not found');
      return [];
    } catch (e) {
      print('Error loading Feats: $e');
      rethrow;
    }
  }

  static Future<void> saveFeat(List<Map<String, dynamic>> feats) async {
    try {
      final file = File('assets/abilities/Feats.json');
      print('=== Saving Feats ===');
      print('Saving ${feats.length} feats');
      if (feats.isNotEmpty) {
        print('First feat being saved:');
        print('Name: ${feats.first['name']}');
        print('Basic Effect: ${feats.first['basicEffect']}');
      }
      
      final jsonString = json.encode(feats);
      await file.writeAsString(jsonString);
      print('Save completed');
    } catch (e) {
      print('Error saving Feats: $e');
      rethrow;
    }
  }

  static Future<void> deleteFeat(String name) async {
    try {
      final file = File('assets/abilities/Feats.json');
      print('=== Deleting Feat ===');
      print('Attempting to delete feat: $name');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final allFeats = List<Map<String, dynamic>>.from(json.decode(content));

        final lengthBefore = allFeats.length;
        allFeats.removeWhere((feat) => feat['name'] == name);
        final lengthAfter = allFeats.length;
        
        print('Removed ${lengthBefore - lengthAfter} feats');

        await file.writeAsString(json.encode(allFeats));
        print('Delete completed');
      }
    } catch (e) {
      print('Error deleting Feat: $e');
      rethrow;
    }
  }

  static Future<bool> validateFeat(Map<String, dynamic> feat) async {
    try {
      print('=== Validating Feat ===');
      print('Validating feat: ${feat['name']}');
      
      // Basic validation of required fields
      if (feat['name'] == null || feat['name'].toString().isEmpty) {
        print('Validation failed: missing name');
        return false;
      }
      
      if (feat['type'] == null || feat['type'].toString().isEmpty) {
        print('Validation failed: missing type');
        return false;
      }
      
      if (feat['level'] == null) {
        print('Validation failed: missing level');
        return false;
      }

      print('Validation passed');
      return true;
    } catch (e) {
      print('Error validating feat: $e');
      return false;
    }
  }

  static Future<void> backupFeats() async {
    try {
      final sourceFile = File('assets/abilities/Feats.json');
      print('=== Creating Backup ===');
      
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/Feats_$timestamp.json');
        
        // Create backup directory if it doesn't exist
        final backupDir = Directory('assets/abilities/backups');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        
        await sourceFile.copy(backupFile.path);
        print('Backup created: ${backupFile.path}');
      }
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<void> restoreFromBackup(String backupFileName) async {
    try {
      print('=== Restoring from Backup ===');
      print('Attempting to restore: $backupFileName');
      
      final backupFile = File('assets/abilities/backups/$backupFileName');
      final targetFile = File('assets/abilities/Feats.json');
      
      if (await backupFile.exists()) {
        await backupFile.copy(targetFile.path);
        print('Restore completed');
      } else {
        print('Backup file not found');
        throw Exception('Backup file not found');
      }
    } catch (e) {
      print('Error restoring from backup: $e');
      rethrow;
    }
  }
}