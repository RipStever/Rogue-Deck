import 'package:flutter/material.dart';
import 'nc_weapon_details_controller.dart';
import 'package:card_game/newcontent/weapons/nc_weaponservice.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_info_form.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_tier_basic_section.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_tier_one_section.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_tier_two_section.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_parser_dialog.dart';

class WeaponsDetailsColumn extends StatefulWidget {
  final String selectedWeaponName;
  final VoidCallback onWeaponListRefresh;

  const WeaponsDetailsColumn({
    super.key,
    required this.selectedWeaponName,
    required this.onWeaponListRefresh,
  });

  @override
  State<WeaponsDetailsColumn> createState() => _WeaponsDetailsColumnState();
}

class _WeaponsDetailsColumnState extends State<WeaponsDetailsColumn> {
  final WeaponDetailsController _controller = WeaponDetailsController();

  void _openWeaponParserDialog() {
    showDialog(
      context: context,
      builder: (context) => WeaponParserDialog(controller: _controller),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.setupChangeListeners(() => setState(() => _controller.hasUnsavedChanges = true));
  }

  @override
  void didUpdateWidget(WeaponsDetailsColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWeaponName != oldWidget.selectedWeaponName) {
      _loadWeaponDetails();
    }
  }

  Future<void> _loadWeaponDetails() async {
    if (widget.selectedWeaponName.isEmpty) {
      _controller.clearFields();
      return;
    }

    try {
      final weapons = await WeaponService.loadWeapons();
      final weapon = weapons.firstWhere(
        (w) => w['name'] == widget.selectedWeaponName,
        orElse: () => <String, dynamic>{},
      );

      if (weapon.isNotEmpty) {
        _controller.nameController.text = weapon['name'] ?? '';
        _controller.levelController.text = (weapon['level'] ?? '').toString();
        _controller.requirementController.text = weapon['requirement'] ?? '';
        _controller.aptitudeController.text = weapon['associatedAptitude'] ?? '';
        _controller.fluffController.text = weapon['fluff'] ?? '';
        _controller.crunchController.text = weapon['crunch'] ?? '';
        _controller.pillarController.text = weapon['pillar'] ?? '';
        _controller.sourceController.text = weapon['source'] ?? '';
        _controller.weaponTypeController.text = weapon['weaponType'] ?? '';
        _controller.handednessController.text = weapon['handedness'] ?? '';
        _controller.categoryController.text = weapon['category'] ?? '';
        _controller.tagsController.text = weapon['tags'] ?? '';

        // Populate Basic Tier
        _controller.basicEffectController.text = weapon['basicEffect'] ?? '';
        _controller.basicApt4ChangeController.text = weapon['basicApt4Change'] ?? '';
        _controller.basicApt4FullTextController.text = weapon['basicApt4FullText'] ?? '';
        _controller.basicApt8ChangeController.text = weapon['basicApt8Change'] ?? '';
        _controller.basicApt8FullTextController.text = weapon['basicApt8FullText'] ?? '';

        _controller.basicChanceCardsToHandController.text = weapon['basicChanceCardsToHand'] ?? '0';
        _controller.basicChanceCardsDrawController.text = weapon['basicChanceCardsDraw'] ?? '0';
        _controller.basicResourceChanceCardsToHandController.text = weapon['basicResourceChanceCardsToHand'] ?? '0';
        _controller.basicResourceChanceCardsDrawController.text = weapon['basicResourceChanceCardsDraw'] ?? '0';

        // Populate Tier 1
        _controller.tier1EffectController.text = weapon['tier1Effect'] ?? '';
        _controller.tier1Apt4ChangeController.text = weapon['tier1Apt4Change'] ?? '';
        _controller.tier1Apt4FullTextController.text = weapon['tier1Apt4FullText'] ?? '';
        _controller.tier1Apt8ChangeController.text = weapon['tier1Apt8Change'] ?? '';
        _controller.tier1Apt8FullTextController.text = weapon['tier1Apt8FullText'] ?? '';

        _controller.tier1ChanceCardsToHandController.text = weapon['tier1ChanceCardsToHand'] ?? '0';
        _controller.tier1ChanceCardsDrawController.text = weapon['tier1ChanceCardsDraw'] ?? '0';
        _controller.tier1ResourceChanceCardsToHandController.text = weapon['tier1ResourceChanceCardsToHand'] ?? '0';
        _controller.tier1ResourceChanceCardsDrawController.text = weapon['tier1ResourceChanceCardsDraw'] ?? '0';

        // Populate Tier 2
        _controller.tier2EffectController.text = weapon['tier2Effect'] ?? '';
        _controller.tier2Apt4ChangeController.text = weapon['tier2Apt4Change'] ?? '';
        _controller.tier2Apt4FullTextController.text = weapon['tier2Apt4FullText'] ?? '';
        _controller.tier2Apt8ChangeController.text = weapon['tier2Apt8Change'] ?? '';
        _controller.tier2Apt8FullTextController.text = weapon['tier2Apt8FullText'] ?? '';

        _controller.tier2ChanceCardsToHandController.text = weapon['tier2ChanceCardsToHand'] ?? '0';
        _controller.tier2ChanceCardsDrawController.text = weapon['tier2ChanceCardsDraw'] ?? '0';
        _controller.tier2ResourceChanceCardsToHandController.text = weapon['tier2ResourceChanceCardsToHand'] ?? '0';
        _controller.tier2ResourceChanceCardsDrawController.text = weapon['tier2ResourceChanceCardsDraw'] ?? '0';

        setState(() {
          _controller.selectedType = weapon['type'] ?? 'Attack';
          _controller.hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      print('Error loading weapon details: $e');
    }
  }

  Future<void> _handleSave() async {
    if (_controller.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a weapon name before saving.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final weapon = {
        'name': _controller.nameController.text,
        'fluff': _controller.fluffController.text,
        'crunch': _controller.crunchController.text,
        'associatedAptitude': _controller.aptitudeController.text,
        'type': _controller.selectedType,
        'requirement': _controller.requirementController.text,
        'pillar': _controller.pillarController.text,
        'level': int.tryParse(_controller.levelController.text) ?? 0,
        'source': _controller.sourceController.text,
        'weaponType': _controller.weaponTypeController.text,
        'handedness': _controller.handednessController.text,
        'category': _controller.categoryController.text,
        'tags': _controller.tagsController.text,

        // Basic Tier
        'basicEffect': _controller.basicEffectController.text,
        'basicApt4Change': _controller.basicApt4ChangeController.text,
        'basicApt4FullText': _controller.basicApt4FullTextController.text,
        'basicApt8Change': _controller.basicApt8ChangeController.text,
        'basicApt8FullText': _controller.basicApt8FullTextController.text,

        'basicChanceCardsToHand': _controller.basicChanceCardsToHandController.text,
        'basicChanceCardsDraw': _controller.basicChanceCardsDrawController.text,
        'basicResourceChanceCardsToHand': _controller.basicResourceChanceCardsToHandController.text,
        'basicResourceChanceCardsDraw': _controller.basicResourceChanceCardsDrawController.text,

        'basicApt4ChanceCardsToHand': _controller.basicApt4ChanceCardsToHandController.text,
        'basicApt4ChanceCardsDraw': _controller.basicApt4ChanceCardsDrawController.text,
        'basicApt4ResourceChanceCardsToHand': _controller.basicApt4ResourceChanceCardsToHandController.text,
        'basicApt4ResourceChanceCardsDraw': _controller.basicApt4ResourceChanceCardsDrawController.text,

        'basicApt8ChanceCardsToHand': _controller.basicApt8ChanceCardsToHandController.text,
        'basicApt8ChanceCardsDraw': _controller.basicApt8ChanceCardsDrawController.text,
        'basicApt8ResourceChanceCardsToHand': _controller.basicApt8ResourceChanceCardsToHandController.text,
        'basicApt8ResourceChanceCardsDraw': _controller.basicApt8ResourceChanceCardsDrawController.text,

        // Tier 1
        'tier1Effect': _controller.tier1EffectController.text,
        'tier1Apt4Change': _controller.tier1Apt4ChangeController.text,
        'tier1Apt4FullText': _controller.tier1Apt4FullTextController.text,
        'tier1Apt8Change': _controller.tier1Apt8ChangeController.text,
        'tier1Apt8FullText': _controller.tier1Apt8FullTextController.text,

        'tier1ChanceCardsToHand': _controller.tier1ChanceCardsToHandController.text,
        'tier1ChanceCardsDraw': _controller.tier1ChanceCardsDrawController.text,
        'tier1ResourceChanceCardsToHand': _controller.tier1ResourceChanceCardsToHandController.text,
        'tier1ResourceChanceCardsDraw': _controller.tier1ResourceChanceCardsDrawController.text,

        'tier1Apt4ChanceCardsToHand': _controller.tier1Apt4ChanceCardsToHandController.text,
        'tier1Apt4ChanceCardsDraw': _controller.tier1Apt4ChanceCardsDrawController.text,
        'tier1Apt4ResourceChanceCardsToHand': _controller.tier1Apt4ResourceChanceCardsToHandController.text,
        'tier1Apt4ResourceChanceCardsDraw': _controller.tier1Apt4ResourceChanceCardsDrawController.text,

        'tier1Apt8ChanceCardsToHand': _controller.tier1Apt8ChanceCardsToHandController.text,
        'tier1Apt8ChanceCardsDraw': _controller.tier1Apt8ChanceCardsDrawController.text,
        'tier1Apt8ResourceChanceCardsToHand': _controller.tier1Apt8ResourceChanceCardsToHandController.text,
        'tier1Apt8ResourceChanceCardsDraw': _controller.tier1Apt8ResourceChanceCardsDrawController.text,

        // Tier 2
        'tier2Effect': _controller.tier2EffectController.text,
        'tier2Apt4Change': _controller.tier2Apt4ChangeController.text,
        'tier2Apt4FullText': _controller.tier2Apt4FullTextController.text,
        'tier2Apt8Change': _controller.tier2Apt8ChangeController.text,
        'tier2Apt8FullText': _controller.tier2Apt8FullTextController.text,

        'tier2ChanceCardsToHand': _controller.tier2ChanceCardsToHandController.text,
        'tier2ChanceCardsDraw': _controller.tier2ChanceCardsDrawController.text,
        'tier2ResourceChanceCardsToHand': _controller.tier2ResourceChanceCardsToHandController.text,
        'tier2ResourceChanceCardsDraw': _controller.tier2ResourceChanceCardsDrawController.text,

        'tier2Apt4ChanceCardsToHand': _controller.tier2Apt4ChanceCardsToHandController.text,
        'tier2Apt4ChanceCardsDraw': _controller.tier2Apt4ChanceCardsDrawController.text,
        'tier2Apt4ResourceChanceCardsToHand': _controller.tier2Apt4ResourceChanceCardsToHandController.text,
        'tier2Apt4ResourceChanceCardsDraw': _controller.tier2Apt4ResourceChanceCardsDrawController.text,

        'tier2Apt8ChanceCardsToHand': _controller.tier2Apt8ChanceCardsToHandController.text,
        'tier2Apt8ChanceCardsDraw': _controller.tier2Apt8ChanceCardsDrawController.text,
        'tier2Apt8ResourceChanceCardsToHand': _controller.tier2Apt8ResourceChanceCardsToHandController.text,
        'tier2Apt8ResourceChanceCardsDraw': _controller.tier2Apt8ResourceChanceCardsDrawController.text,
      };

      final allWeapons = await WeaponService.loadWeapons();
      allWeapons.removeWhere((w) => w['name'] == _controller.nameController.text);
      allWeapons.add(weapon);

      await WeaponService.saveWeapons(allWeapons);
      widget.onWeaponListRefresh();

      setState(() {
        _controller.hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weapon saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving weapon: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (_controller.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a weapon to delete.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
                'Are you sure you want to delete this weapon? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        final allWeapons = await WeaponService.loadWeapons();
        allWeapons.removeWhere((w) => w['name'] == _controller.nameController.text);
        await WeaponService.saveWeapons(allWeapons);

        widget.onWeaponListRefresh();

        _controller.clearFields();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weapon deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting weapon: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: WeaponInfoForm(
              nameController: _controller.nameController,
              levelController: _controller.levelController,
              requirementController: _controller.requirementController,
              aptitudeController: _controller.aptitudeController,
              pillarController: _controller.pillarController,
              sourceController: _controller.sourceController,
              fluffController: _controller.fluffController,
              crunchController: _controller.crunchController,
              weaponTypeController: _controller.weaponTypeController,
              handednessController: _controller.handednessController,
              categoryController: _controller.categoryController,
              tagsController: _controller.tagsController,
              selectedType: _controller.selectedType,
              continuousDevelopment: _controller.continuousDevelopment,
              onTypeChanged: (value) => setState(() => _controller.selectedType = value),
              onContinuousDevelopmentChanged: (value) => setState(() => _controller.continuousDevelopment = value),
              onSave: _handleSave,
              onClear: _controller.clearFields,
              onDelete: _handleDelete,
              onParseFromText: _openWeaponParserDialog,
            ),
          ),
          Expanded(child: TierBasicSection(controller: _controller)),
          Expanded(child: TierOneSection(controller: _controller)),
          Expanded(child: TierTwoSection(controller: _controller)),
        ],
      ),
    );
  }
}
