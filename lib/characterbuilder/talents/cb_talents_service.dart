// lib/characterbuilder/talents/talent_service.dart
import 'dart:convert';
import 'dart:io';

class TalentService {
  static Future<List<Map<String, dynamic>>> loadTalents() async {
    try {
      final file = File('assets/abilities/talents.json');
      
      if (await file.exists()) {
        print('=== TalentService loadTalents ===');
        final content = await file.readAsString();       
        print('Content loaded, length: ${content.length}');
        
        final List<dynamic> talents = json.decode(content);
        print('Parsed ${talents.length} talents');
        
        if (talents.isNotEmpty) {
          print('First talent data:');
          print('Name: ${talents.first['name']}');
          print('Effect: ${talents.first['effect']}');
        }

        // Convert directly to List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(talents);
      }
      print('talents.json file not found');
      return [];
    } catch (e) {
      print('Error loading talents: $e');
      rethrow;
    }
  }

  static Future<void> saveTalent(List<Map<String, dynamic>> talents) async {
    try {
      final file = File('assets/abilities/talents.json');
      print('=== Saving talents ===');
      print('Saving ${talents.length} talents');
      if (talents.isNotEmpty) {
        print('First talent being saved:');
        print('Name: ${talents.first['name']}');
        print('Basic Effect: ${talents.first['basicEffect']}');
      }
      
      final jsonString = json.encode(talents);
      await file.writeAsString(jsonString);
      print('Save completed');
    } catch (e) {
      print('Error saving talents: $e');
      rethrow;
    }
  }

  static Future<void> deleteTalent(String name) async {
    try {
      final file = File('assets/abilities/talents.json');
      print('=== Deleting talent ===');
      print('Attempting to delete talent: $name');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final allTalents = List<Map<String, dynamic>>.from(json.decode(content));

        final lengthBefore = allTalents.length;
        allTalents.removeWhere((talent) => talent['name'] == name);
        final lengthAfter = allTalents.length;
        
        print('Removed ${lengthBefore - lengthAfter} talents');

        await file.writeAsString(json.encode(allTalents));
        print('Delete completed');
      }
    } catch (e) {
      print('Error deleting talent: $e');
      rethrow;
    }
  }

  static Future<bool> validateTalent(Map<String, dynamic> talent) async {
    try {
      print('=== Validating talent ===');
      print('Validating talent: ${talent['name']}');
      
      // Basic validation of required fields
      if (talent['name'] == null || talent['name'].toString().isEmpty) {
        print('Validation failed: missing name');
        return false;
      }
      
      if (talent['type'] == null || talent['type'].toString().isEmpty) {
        print('Validation failed: missing type');
        return false;
      }
      
      if (talent['level'] == null) {
        print('Validation failed: missing level');
        return false;
      }

      print('Validation passed');
      return true;
    } catch (e) {
      print('Error validating talent: $e');
      return false;
    }
  }

  static Future<void> backupTalents() async {
    try {
      final sourceFile = File('assets/abilities/talents.json');
      print('=== Creating Backup ===');
      
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/talents_$timestamp.json');
        
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
      final targetFile = File('assets/abilities/talents.json');
      
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