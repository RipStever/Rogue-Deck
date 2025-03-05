import 'package:flutter/material.dart';

class WeaponDetailsController {
  bool hasUnsavedChanges = false;
  bool continuousDevelopment = false;
  String selectedType = 'Attack';

  // Controllers for Weapon Information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();
  final TextEditingController aptitudeController = TextEditingController();
  final TextEditingController fluffController = TextEditingController();
  final TextEditingController crunchController = TextEditingController();
  final TextEditingController pillarController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController weaponTypeController = TextEditingController();
  final TextEditingController handednessController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  // Controllers for Basic Tier
  final TextEditingController basicEffectController = TextEditingController();
  final TextEditingController basicChanceCardsToHandController = TextEditingController();
  final TextEditingController basicChanceCardsDrawController = TextEditingController();
  final TextEditingController basicResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController basicResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController basicApt4ChangeController = TextEditingController();
  final TextEditingController basicApt4FullTextController = TextEditingController();
  final TextEditingController basicApt4ChanceCardsToHandController = TextEditingController();
  final TextEditingController basicApt4ChanceCardsDrawController = TextEditingController();
  final TextEditingController basicApt4ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController basicApt4ResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController basicApt8ChangeController = TextEditingController();
  final TextEditingController basicApt8FullTextController = TextEditingController();
  final TextEditingController basicApt8ChanceCardsToHandController = TextEditingController();
  final TextEditingController basicApt8ChanceCardsDrawController = TextEditingController();
  final TextEditingController basicApt8ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController basicApt8ResourceChanceCardsDrawController = TextEditingController();

  // Controllers for Tier 1
  final TextEditingController tier1EffectController = TextEditingController();
  final TextEditingController tier1ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier1ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1ResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController tier1Apt4ChangeController = TextEditingController();
  final TextEditingController tier1Apt4FullTextController = TextEditingController();
  final TextEditingController tier1Apt4ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1Apt4ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier1Apt4ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1Apt4ResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController tier1Apt8ChangeController = TextEditingController();
  final TextEditingController tier1Apt8FullTextController = TextEditingController();
  final TextEditingController tier1Apt8ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1Apt8ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier1Apt8ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier1Apt8ResourceChanceCardsDrawController = TextEditingController();

  // Controllers for Tier 2
  final TextEditingController tier2EffectController = TextEditingController();
  final TextEditingController tier2ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier2ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2ResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController tier2Apt4ChangeController = TextEditingController();
  final TextEditingController tier2Apt4FullTextController = TextEditingController();
  final TextEditingController tier2Apt4ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2Apt4ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier2Apt4ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2Apt4ResourceChanceCardsDrawController = TextEditingController();

  final TextEditingController tier2Apt8ChangeController = TextEditingController();
  final TextEditingController tier2Apt8FullTextController = TextEditingController();
  final TextEditingController tier2Apt8ChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2Apt8ChanceCardsDrawController = TextEditingController();
  final TextEditingController tier2Apt8ResourceChanceCardsToHandController = TextEditingController();
  final TextEditingController tier2Apt8ResourceChanceCardsDrawController = TextEditingController();

  void setupChangeListeners(VoidCallback markChanged) {
    for (var controller in [
      nameController,
      levelController,
      requirementController,
      aptitudeController,
      fluffController,
      crunchController,
      pillarController,
      sourceController,
      weaponTypeController,
      handednessController,
      categoryController,
      tagsController,
      basicEffectController,
      basicChanceCardsToHandController,
      basicChanceCardsDrawController,
      basicResourceChanceCardsToHandController,
      basicResourceChanceCardsDrawController,
      basicApt4ChangeController,
      basicApt4FullTextController,
      basicApt4ChanceCardsToHandController,
      basicApt4ChanceCardsDrawController,
      basicApt4ResourceChanceCardsToHandController,
      basicApt4ResourceChanceCardsDrawController,
      basicApt8ChangeController,
      basicApt8FullTextController,
      basicApt8ChanceCardsToHandController,
      basicApt8ChanceCardsDrawController,
      basicApt8ResourceChanceCardsToHandController,
      basicApt8ResourceChanceCardsDrawController,
      tier1EffectController,
      tier1ChanceCardsToHandController,
      tier1ChanceCardsDrawController,
      tier1ResourceChanceCardsToHandController,
      tier1ResourceChanceCardsDrawController,
      tier1Apt4ChangeController,
      tier1Apt4FullTextController,
      tier1Apt4ChanceCardsToHandController,
      tier1Apt4ChanceCardsDrawController,
      tier1Apt4ResourceChanceCardsToHandController,
      tier1Apt4ResourceChanceCardsDrawController,
      tier1Apt8ChangeController,
      tier1Apt8FullTextController,
      tier1Apt8ChanceCardsToHandController,
      tier1Apt8ChanceCardsDrawController,
      tier1Apt8ResourceChanceCardsToHandController,
      tier1Apt8ResourceChanceCardsDrawController,
      tier2EffectController,
      tier2ChanceCardsToHandController,
      tier2ChanceCardsDrawController,
      tier2ResourceChanceCardsToHandController,
      tier2ResourceChanceCardsDrawController,
      tier2Apt4ChangeController,
      tier2Apt4FullTextController,
      tier2Apt4ChanceCardsToHandController,
      tier2Apt4ChanceCardsDrawController,
      tier2Apt4ResourceChanceCardsToHandController,
      tier2Apt4ResourceChanceCardsDrawController,
      tier2Apt8ChangeController,
      tier2Apt8FullTextController,
      tier2Apt8ChanceCardsToHandController,
      tier2Apt8ChanceCardsDrawController,
      tier2Apt8ResourceChanceCardsToHandController,
      tier2Apt8ResourceChanceCardsDrawController,
    ]) {
      controller.addListener(markChanged);
    }
  }

  void clearFields() {
    print("Clearing all fields..."); // Debugging

    // General Weapon Information
    nameController.clear();
    levelController.clear();
    requirementController.clear();
    aptitudeController.clear();
    fluffController.clear();
    crunchController.clear();
    pillarController.clear();
    sourceController.clear();
    weaponTypeController.clear();
    handednessController.clear();
    categoryController.clear();
    tagsController.clear();

    // Clear Basic Tier Fields
    basicEffectController.clear();
    basicChanceCardsToHandController.clear();
    basicChanceCardsDrawController.clear();
    basicResourceChanceCardsToHandController.clear();
    basicResourceChanceCardsDrawController.clear();

    basicApt4ChangeController.clear();
    basicApt4FullTextController.clear();
    basicApt4ChanceCardsToHandController.clear();
    basicApt4ChanceCardsDrawController.clear();
    basicApt4ResourceChanceCardsToHandController.clear();
    basicApt4ResourceChanceCardsDrawController.clear();

    basicApt8ChangeController.clear();
    basicApt8FullTextController.clear();
    basicApt8ChanceCardsToHandController.clear();
    basicApt8ChanceCardsDrawController.clear();
    basicApt8ResourceChanceCardsToHandController.clear();
    basicApt8ResourceChanceCardsDrawController.clear();

    // Clear Tier 1 Fields
    tier1EffectController.clear();
    tier1ChanceCardsToHandController.clear();
    tier1ChanceCardsDrawController.clear();
    tier1ResourceChanceCardsToHandController.clear();
    tier1ResourceChanceCardsDrawController.clear();

    tier1Apt4ChangeController.clear();
    tier1Apt4FullTextController.clear();
    tier1Apt4ChanceCardsToHandController.clear();
    tier1Apt4ChanceCardsDrawController.clear();
    tier1Apt4ResourceChanceCardsToHandController.clear();
    tier1Apt4ResourceChanceCardsDrawController.clear();

    tier1Apt8ChangeController.clear();
    tier1Apt8FullTextController.clear();
    tier1Apt8ChanceCardsToHandController.clear();
    tier1Apt8ChanceCardsDrawController.clear();
    tier1Apt8ResourceChanceCardsToHandController.clear();
    tier1Apt8ResourceChanceCardsDrawController.clear();

    // Clear Tier 2 Fields
    tier2EffectController.clear();
    tier2ChanceCardsToHandController.clear();
    tier2ChanceCardsDrawController.clear();
    tier2ResourceChanceCardsToHandController.clear();
    tier2ResourceChanceCardsDrawController.clear();

    tier2Apt4ChangeController.clear();
    tier2Apt4FullTextController.clear();
    tier2Apt4ChanceCardsToHandController.clear();
    tier2Apt4ChanceCardsDrawController.clear();
    tier2Apt4ResourceChanceCardsToHandController.clear();
    tier2Apt4ResourceChanceCardsDrawController.clear();

    tier2Apt8ChangeController.clear();
    tier2Apt8FullTextController.clear();
    tier2Apt8ChanceCardsToHandController.clear();
    tier2Apt8ChanceCardsDrawController.clear();
    tier2Apt8ResourceChanceCardsToHandController.clear();
    tier2Apt8ResourceChanceCardsDrawController.clear();

    // Reset selected values
    selectedType = 'Melee';
    hasUnsavedChanges = false;
  }

  void dispose() {
    nameController.dispose();
    levelController.dispose();
    requirementController.dispose();
    aptitudeController.dispose();
    fluffController.dispose();
    crunchController.dispose();
    pillarController.dispose();
    sourceController.dispose();
    weaponTypeController.dispose();
    handednessController.dispose();
    categoryController.dispose();
    tagsController.dispose();

    // Dispose Basic Tier Controllers
    basicEffectController.dispose();
    basicChanceCardsToHandController.dispose();
    basicChanceCardsDrawController.dispose();
    basicResourceChanceCardsToHandController.dispose();
    basicResourceChanceCardsDrawController.dispose();

    basicApt4ChangeController.dispose();
    basicApt4FullTextController.dispose();
    basicApt4ChanceCardsToHandController.dispose();
    basicApt4ChanceCardsDrawController.dispose();
    basicApt4ResourceChanceCardsToHandController.dispose();
    basicApt4ResourceChanceCardsDrawController.dispose();

    basicApt8ChangeController.dispose();
    basicApt8FullTextController.dispose();
    basicApt8ChanceCardsToHandController.dispose();
    basicApt8ChanceCardsDrawController.dispose();
    basicApt8ResourceChanceCardsToHandController.dispose();
    basicApt8ResourceChanceCardsDrawController.dispose();

    // Dispose Tier 1 Controllers
    tier1EffectController.dispose();
    tier1ChanceCardsToHandController.dispose();
    tier1ChanceCardsDrawController.dispose();
    tier1ResourceChanceCardsToHandController.dispose();
    tier1ResourceChanceCardsDrawController.dispose();

    tier1Apt4ChangeController.dispose();
    tier1Apt4FullTextController.dispose();
    tier1Apt4ChanceCardsToHandController.dispose();
    tier1Apt4ChanceCardsDrawController.dispose();
    tier1Apt4ResourceChanceCardsToHandController.dispose();
    tier1Apt4ResourceChanceCardsDrawController.dispose();

    tier1Apt8ChangeController.dispose();
    tier1Apt8FullTextController.dispose();
    tier1Apt8ChanceCardsToHandController.dispose();
    tier1Apt8ChanceCardsDrawController.dispose();
    tier1Apt8ResourceChanceCardsToHandController.dispose();
    tier1Apt8ResourceChanceCardsDrawController.dispose();

    // Dispose Tier 2 Controllers
    tier2EffectController.dispose();
    tier2ChanceCardsToHandController.dispose();
    tier2ChanceCardsDrawController.dispose();
    tier2ResourceChanceCardsToHandController.dispose();
    tier2ResourceChanceCardsDrawController.dispose();

    tier2Apt4ChangeController.dispose();
    tier2Apt4FullTextController.dispose();
    tier2Apt4ChanceCardsToHandController.dispose();
    tier2Apt4ChanceCardsDrawController.dispose();
    tier2Apt4ResourceChanceCardsToHandController.dispose();
    tier2Apt4ResourceChanceCardsDrawController.dispose();

    tier2Apt8ChangeController.dispose();
    tier2Apt8FullTextController.dispose();
    tier2Apt8ChanceCardsToHandController.dispose();
    tier2Apt8ChanceCardsDrawController.dispose();
    tier2Apt8ResourceChanceCardsToHandController.dispose();
    tier2Apt8ResourceChanceCardsDrawController.dispose();
  }
}
