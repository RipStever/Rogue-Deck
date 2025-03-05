import 'dart:convert';
import 'dart:io';

class WeaponService {
  static Future<List<Map<String, dynamic>>> loadWeapons() async {
    try {
      final file = File('assets/abilities/Weapons.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) {
          return [];
        }
        return List<Map<String, dynamic>>.from(json.decode(content));
      }
    } catch (e) {
      print('Error loading weapons: $e');
      // Consider throwing the error to let the UI handle it
    }
    return [];
  }

  static Future<void> saveWeapons(List<Map<String, dynamic>> weapons) async {
    try {
      final file = File('assets/abilities/Weapons.json');
      final jsonString = json.encode(weapons);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving weapons: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  static Future<void> deleteWeapon(String name) async {
    try {
      final file = File('assets/abilities/Weapons.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final allWeapons = List<Map<String, dynamic>>.from(json.decode(content));

        // Remove the weapon by name
        allWeapons.removeWhere((weapon) => weapon['name'] == name);

        await file.writeAsString(json.encode(allWeapons));
      }
    } catch (e) {
      print('Error deleting weapon: $e');
      rethrow;
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> groupWeaponsByBaseName(List<Map<String, dynamic>> weapons) async {
    final Map<String, List<Map<String, dynamic>>> groupedWeapons = {};
    
    for (var weapon in weapons) {
      String baseName = weapon['name']
          .toString()
          .replaceAll(RegExp(r'\s-\s(Basic|Tier \d+).*'), '')
          .trim();
      
      if (!groupedWeapons.containsKey(baseName)) {
        groupedWeapons[baseName] = [];
      }
      groupedWeapons[baseName]!.add(weapon);
    }

    return groupedWeapons;
  }

  static Future<bool> validateWeapon(Map<String, dynamic> weapon) async {
    try {
      // Basic validation of required fields
      if (weapon['name'] == null || weapon['name'].toString().isEmpty) {
        return false;
      }
      
      if (weapon['type'] == null || weapon['type'].toString().isEmpty) {
        return false;
      }
      
      if (weapon['level'] == null) {
        return false;
      }
      
      if (weapon['basicEffect'] == null || weapon['basicEffect'].toString().isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating weapon: $e');
      return false;
    }
  }

  static Future<void> backupWeapons() async {
    try {
      final sourceFile = File('assets/abilities/Weapons.json');
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/Weapons_$timestamp.json');
        
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
      final targetFile = File('assets/abilities/Weapons.json');
      
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
