// lib/newcontent/talents/NewContent_Talent_service.dart
import 'dart:convert';
import 'dart:io';

class TalentService {
  static const String _filePath = 'assets/abilities/Talents.json';

  /// Load all talents from the JSON file
  static Future<List<Map<String, dynamic>>> loadTalents() async {
    try {
      final file = File(_filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) {
          return [];
        }
        return List<Map<String, dynamic>>.from(json.decode(content));
      }
    } catch (e) {
      print('Error loading talents: $e');
    }
    return [];
  }

  /// Save a list of talents to the JSON file
  static Future<void> saveTalents(List<Map<String, dynamic>> talents) async {
    try {
      final file = File(_filePath);
      final jsonString = json.encode(talents);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving talents: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  /// Delete a talent by its name
  static Future<void> deleteTalent(String talentName) async {
    try {
      final file = File(_filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final allTalents = List<Map<String, dynamic>>.from(json.decode(content));

        // Remove talents with the matching name
        allTalents.removeWhere((talent) => talent['name'] == talentName);

        await file.writeAsString(json.encode(allTalents));
      }
    } catch (e) {
      print('Error deleting talent: $e');
      rethrow;
    }
  }

  /// Validate that a talent has the required fields
  static bool validateTalent(Map<String, dynamic> talent) {
    try {
      return talent.containsKey('name') &&
          talent['name'] != null &&
          talent['name'].toString().isNotEmpty &&
          talent.containsKey('effect') &&
          talent['effect'] != null &&
          talent['effect'].toString().isNotEmpty;
    } catch (e) {
      print('Error validating talent: $e');
      return false;
    }
  }

  /// Backup talents to a timestamped JSON file
  static Future<void> backupTalents() async {
    try {
      final sourceFile = File(_filePath);
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/Talents_$timestamp.json');

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

  /// Restore talents from a backup file
  static Future<void> restoreFromBackup(String backupFileName) async {
    try {
      final backupFile = File('assets/abilities/backups/$backupFileName');
      final targetFile = File(_filePath);

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
