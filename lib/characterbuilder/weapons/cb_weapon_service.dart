import 'dart:convert';
import 'dart:io';

class WeaponService {
  static Future<List<Map<String, dynamic>>> loadWeapons() async {
    try {
      final file = File('assets/abilities/Weapons.json');
      
      if (await file.exists()) {
        print('=== WeaponService loadWeapons ===');
        final content = await file.readAsString();       
        print('Content loaded, length: ${content.length}');
        
        final List<dynamic> weapons = json.decode(content);
        print('Parsed ${weapons.length} weapons');
        
        if (weapons.isNotEmpty) {
          print('First weapon data:');
          print('Name: ${weapons.first['name']}');
          print('Basic Effect: ${weapons.first['basicEffect']}');
          print('Tier 1 Effect: ${weapons.first['tier1Effect']}');
          print('Tier 2 Effect: ${weapons.first['tier2Effect']}');
        }

        // Convert directly to List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(weapons);
      }
      print('Weapons.json file not found');
      return [];
    } catch (e) {
      print('Error loading Weapons: $e');
      rethrow;
    }
  }

  static Future<void> saveWeapon(List<Map<String, dynamic>> weapons) async {
    try {
      final file = File('assets/abilities/Weapons.json');
      print('=== Saving Weapons ===');
      print('Saving ${weapons.length} weapons');
      if (weapons.isNotEmpty) {
        print('First weapon being saved:');
        print('Name: ${weapons.first['name']}');
        print('Basic Effect: ${weapons.first['basicEffect']}');
      }
      
      final jsonString = json.encode(weapons);
      await file.writeAsString(jsonString);
      print('Save completed');
    } catch (e) {
      print('Error saving Weapons: $e');
      rethrow;
    }
  }

  static Future<void> deleteWeapon(String name) async {
    try {
      final file = File('assets/abilities/Weapons.json');
      print('=== Deleting Weapon ===');
      print('Attempting to delete weapon: $name');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final allWeapons = List<Map<String, dynamic>>.from(json.decode(content));

        final lengthBefore = allWeapons.length;
        allWeapons.removeWhere((weapon) => weapon['name'] == name);
        final lengthAfter = allWeapons.length;
        
        print('Removed ${lengthBefore - lengthAfter} weapons');

        await file.writeAsString(json.encode(allWeapons));
        print('Delete completed');
      }
    } catch (e) {
      print('Error deleting Weapon: $e');
      rethrow;
    }
  }

  static Future<bool> validateWeapon(Map<String, dynamic> weapon) async {
    try {
      print('=== Validating Weapon ===');
      print('Validating weapon: ${weapon['name']}');
      
      // Basic validation of required fields
      if (weapon['name'] == null || weapon['name'].toString().isEmpty) {
        print('Validation failed: missing name');
        return false;
      }
      
      if (weapon['type'] == null || weapon['type'].toString().isEmpty) {
        print('Validation failed: missing type');
        return false;
      }
      
      if (weapon['level'] == null) {
        print('Validation failed: missing level');
        return false;
      }

      print('Validation passed');
      return true;
    } catch (e) {
      print('Error validating weapon: $e');
      return false;
    }
  }

  static Future<void> backupWeapons() async {
    try {
      final sourceFile = File('assets/abilities/Weapons.json');
      print('=== Creating Backup ===');
      
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('assets/abilities/backups/Weapons_$timestamp.json');
        
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
      final targetFile = File('assets/abilities/Weapons.json');
      
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
