import 'package:flutter/material.dart';
import 'dart:convert';
import 'nc_weapon_details_controller.dart';

class WeaponParserDialog extends StatefulWidget {
  final WeaponDetailsController controller;

  const WeaponParserDialog({super.key, required this.controller});

  @override
  _WeaponParserDialogState createState() => _WeaponParserDialogState();
}

class _WeaponParserDialogState extends State<WeaponParserDialog> {
  final TextEditingController _textController = TextEditingController();
  String _errorMessage = '';

  void _parseWeaponDetails() {
    final text = _textController.text;
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Input text cannot be empty.';
      });
      return;
    }

    try {
      final Map<String, dynamic> weaponData = json.decode(text);

      widget.controller.nameController.text = weaponData['name'] ?? '';
      widget.controller.fluffController.text = weaponData['fluff'] ?? '';
      widget.controller.crunchController.text = weaponData['crunch'] ?? '';
      widget.controller.aptitudeController.text = weaponData['associatedAptitude'] ?? '';
      widget.controller.requirementController.text = weaponData['requirement'] ?? '';
      widget.controller.pillarController.text = weaponData['pillar'] ?? '';
      widget.controller.levelController.text = (weaponData['level'] ?? '').toString();
      widget.controller.sourceController.text = weaponData['source'] ?? '';
      widget.controller.weaponTypeController.text = weaponData['weaponType'] ?? '';
      widget.controller.handednessController.text = weaponData['handedness'] ?? '';
      widget.controller.categoryController.text = weaponData['category'] ?? '';
      widget.controller.tagsController.text = (weaponData['tags'] as List<dynamic>).join(', ');

      // Populate Tier 1
      widget.controller.tier1EffectController.text = weaponData['tier1Effect'] ?? '';
      widget.controller.tier1ChanceCardsToHandController.text = (weaponData['tier1ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1ChanceCardsDrawController.text = (weaponData['tier1ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier1ResourceChanceCardsToHandController.text = (weaponData['tier1ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1ResourceChanceCardsDrawController.text = (weaponData['tier1ResourceChanceCardsDraw'] ?? '0').toString();

      widget.controller.tier1Apt4ChangeController.text = weaponData['tier1Apt4Change'] ?? '';
      widget.controller.tier1Apt4FullTextController.text = weaponData['tier1Apt4FullText'] ?? '';
      widget.controller.tier1Apt4ChanceCardsToHandController.text = (weaponData['tier1Apt4ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1Apt4ChanceCardsDrawController.text = (weaponData['tier1Apt4ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier1Apt4ResourceChanceCardsToHandController.text = (weaponData['tier1Apt4ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1Apt4ResourceChanceCardsDrawController.text = (weaponData['tier1Apt4ResourceChanceCardsDraw'] ?? '0').toString();

      widget.controller.tier1Apt8ChangeController.text = weaponData['tier1Apt8Change'] ?? '';
      widget.controller.tier1Apt8FullTextController.text = weaponData['tier1Apt8FullText'] ?? '';
      widget.controller.tier1Apt8ChanceCardsToHandController.text = (weaponData['tier1Apt8ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1Apt8ChanceCardsDrawController.text = (weaponData['tier1Apt8ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier1Apt8ResourceChanceCardsToHandController.text = (weaponData['tier1Apt8ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier1Apt8ResourceChanceCardsDrawController.text = (weaponData['tier1Apt8ResourceChanceCardsDraw'] ?? '0').toString();

      // Populate Tier 2
      widget.controller.tier2EffectController.text = weaponData['tier2Effect'] ?? '';
      widget.controller.tier2ChanceCardsToHandController.text = (weaponData['tier2ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2ChanceCardsDrawController.text = (weaponData['tier2ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier2ResourceChanceCardsToHandController.text = (weaponData['tier2ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2ResourceChanceCardsDrawController.text = (weaponData['tier2ResourceChanceCardsDraw'] ?? '0').toString();

      widget.controller.tier2Apt4ChangeController.text = weaponData['tier2Apt4Change'] ?? '';
      widget.controller.tier2Apt4FullTextController.text = weaponData['tier2Apt4FullText'] ?? '';
      widget.controller.tier2Apt4ChanceCardsToHandController.text = (weaponData['tier2Apt4ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2Apt4ChanceCardsDrawController.text = (weaponData['tier2Apt4ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier2Apt4ResourceChanceCardsToHandController.text = (weaponData['tier2Apt4ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2Apt4ResourceChanceCardsDrawController.text = (weaponData['tier2Apt4ResourceChanceCardsDraw'] ?? '0').toString();

      widget.controller.tier2Apt8ChangeController.text = weaponData['tier2Apt8Change'] ?? '';
      widget.controller.tier2Apt8FullTextController.text = weaponData['tier2Apt8FullText'] ?? '';
      widget.controller.tier2Apt8ChanceCardsToHandController.text = (weaponData['tier2Apt8ChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2Apt8ChanceCardsDrawController.text = (weaponData['tier2Apt8ChanceCardsDraw'] ?? '0').toString();
      widget.controller.tier2Apt8ResourceChanceCardsToHandController.text = (weaponData['tier2Apt8ResourceChanceCardsToHand'] ?? '0').toString();
      widget.controller.tier2Apt8ResourceChanceCardsDrawController.text = (weaponData['tier2Apt8ResourceChanceCardsDraw'] ?? '0').toString();

      setState(() {
        _errorMessage = '';
      });
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error parsing weapon details: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Weapon Text Parser', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 15,
              decoration: const InputDecoration(
                hintText: 'Paste JSON weapon data here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _parseWeaponDetails, child: const Text('Parse Weapon')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
