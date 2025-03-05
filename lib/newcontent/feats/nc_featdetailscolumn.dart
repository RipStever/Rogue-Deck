import 'package:flutter/material.dart';
import 'nc_feat_details_controller.dart';
import 'package:card_game/newcontent/feats/nc_feat_service.dart';
import 'package:card_game/newcontent/feats/nc_feat_info_form.dart';
import 'package:card_game/newcontent/feats/nc_tier_basic_section.dart';
import 'package:card_game/newcontent/feats/nc_tier_one_section.dart';
import 'package:card_game/newcontent/feats/nc_tier_two_section.dart';
import 'package:card_game/newcontent/feats/nc_feat_parser_dialog.dart';


class FeatDetailsColumn extends StatefulWidget {
  final String selectedFeatName;
  final VoidCallback onFeatListRefresh;

  const FeatDetailsColumn({
    super.key,
    required this.selectedFeatName,
    required this.onFeatListRefresh,
  });

  @override
  State<FeatDetailsColumn> createState() => _FeatDetailsColumnState();
}

class _FeatDetailsColumnState extends State<FeatDetailsColumn> {
  final FeatDetailsController _controller = FeatDetailsController();

  void _openFeatParserDialog() {
  showDialog(
    context: context,
    builder: (context) => FeatParserDialog(controller: _controller),
  );
  }


  @override
  void initState() {
    super.initState();
    _controller.setupChangeListeners(() => setState(() => _controller.hasUnsavedChanges = true));
  }

  @override
  void didUpdateWidget(FeatDetailsColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFeatName != oldWidget.selectedFeatName) {
      _loadFeatDetails();
    }
  }

  Future<void> _loadFeatDetails() async {
    if (widget.selectedFeatName.isEmpty) {
      _controller.clearFields();
      return;
    }

    try {
      final feats = await FeatService.loadFeats();
      final feat = feats.firstWhere(
        (f) => f['name'] == widget.selectedFeatName,
        orElse: () => <String, dynamic>{},
      );

      if (feat.isNotEmpty) {
        print("Loading feat: ${feat['name']}"); // Debugging

        _controller.nameController.text = feat['name'] ?? '';
        _controller.levelController.text = (feat['level'] ?? '').toString();
        _controller.requirementController.text = feat['requirement'] ?? '';
        _controller.aptitudeController.text = feat['associatedAptitude'] ?? '';
        _controller.fluffController.text = feat['fluff'] ?? '';
        _controller.crunchController.text = feat['crunch'] ?? '';
        _controller.pillarController.text = feat['pillar'] ?? '';
        _controller.sourceController.text = feat['sourceBook'] ?? '';

        // 🔹 Populate Basic Tier
        _controller.basicEffectController.text = feat['basicEffect'] ?? '';
        _controller.basicApt4ChangeController.text = feat['basicApt4Change'] ?? '';
        _controller.basicApt4FullTextController.text = feat['basicApt4FullText'] ?? '';
        _controller.basicApt8ChangeController.text = feat['basicApt8Change'] ?? '';
        _controller.basicApt8FullTextController.text = feat['basicApt8FullText'] ?? '';

        _controller.basicChanceCardsToHandController.text = feat['basicChanceCardsToHand'] ?? '';
        _controller.basicChanceCardsDrawController.text = feat['basicChanceCardsDraw'] ?? '';
        _controller.basicResourceChanceCardsToHandController.text = feat['basicResourceChanceCardsToHand'] ?? '';
        _controller.basicResourceChanceCardsDrawController.text = feat['basicResourceChanceCardsDraw'] ?? '';

        _controller.basicApt4ChanceCardsToHandController.text = feat['basicApt4ChanceCardsToHand'] ?? '';
        _controller.basicApt4ChanceCardsDrawController.text = feat['basicApt4ChanceCardsDraw'] ?? '';
        _controller.basicApt4ResourceChanceCardsToHandController.text = feat['basicApt4ResourceChanceCardsToHand'] ?? '';
        _controller.basicApt4ResourceChanceCardsDrawController.text = feat['basicApt4ResourceChanceCardsDraw'] ?? '';

        _controller.basicApt8ChanceCardsToHandController.text = feat['basicApt8ChanceCardsToHand'] ?? '';
        _controller.basicApt8ChanceCardsDrawController.text = feat['basicApt8ChanceCardsDraw'] ?? '';
        _controller.basicApt8ResourceChanceCardsToHandController.text = feat['basicApt8ResourceChanceCardsToHand'] ?? '';
        _controller.basicApt8ResourceChanceCardsDrawController.text = feat['basicApt8ResourceChanceCardsDraw'] ?? '';

        // 🔹 Populate Tier 1
        _controller.tier1EffectController.text = feat['tier1Effect'] ?? '';
        _controller.tier1Apt4ChangeController.text = feat['tier1Apt4Change'] ?? '';
        _controller.tier1Apt4FullTextController.text = feat['tier1Apt4FullText'] ?? '';
        _controller.tier1Apt8ChangeController.text = feat['tier1Apt8Change'] ?? '';
        _controller.tier1Apt8FullTextController.text = feat['tier1Apt8FullText'] ?? '';

        _controller.tier1ChanceCardsToHandController.text = feat['tier1ChanceCardsToHand'] ?? '';
        _controller.tier1ChanceCardsDrawController.text = feat['tier1ChanceCardsDraw'] ?? '';
        _controller.tier1ResourceChanceCardsToHandController.text = feat['tier1ResourceChanceCardsToHand'] ?? '';
        _controller.tier1ResourceChanceCardsDrawController.text = feat['tier1ResourceChanceCardsDraw'] ?? '';

        _controller.tier1Apt4ChanceCardsToHandController.text = feat['tier1Apt4ChanceCardsToHand'] ?? '';
        _controller.tier1Apt4ChanceCardsDrawController.text = feat['tier1Apt4ChanceCardsDraw'] ?? '';
        _controller.tier1Apt4ResourceChanceCardsToHandController.text = feat['tier1Apt4ResourceChanceCardsToHand'] ?? '';
        _controller.tier1Apt4ResourceChanceCardsDrawController.text = feat['tier1Apt4ResourceChanceCardsDraw'] ?? '';

        _controller.tier1Apt8ChanceCardsToHandController.text = feat['tier1Apt8ChanceCardsToHand'] ?? '';
        _controller.tier1Apt8ChanceCardsDrawController.text = feat['tier1Apt8ChanceCardsDraw'] ?? '';
        _controller.tier1Apt8ResourceChanceCardsToHandController.text = feat['tier1Apt8ResourceChanceCardsToHand'] ?? '';
        _controller.tier1Apt8ResourceChanceCardsDrawController.text = feat['tier1Apt8ResourceChanceCardsDraw'] ?? '';

        // 🔹 Populate Tier 2
        _controller.tier2EffectController.text = feat['tier2Effect'] ?? '';
        _controller.tier2Apt4ChangeController.text = feat['tier2Apt4Change'] ?? '';
        _controller.tier2Apt4FullTextController.text = feat['tier2Apt4FullText'] ?? '';
        _controller.tier2Apt8ChangeController.text = feat['tier2Apt8Change'] ?? '';
        _controller.tier2Apt8FullTextController.text = feat['tier2Apt8FullText'] ?? '';

        _controller.tier2ChanceCardsToHandController.text = feat['tier2ChanceCardsToHand'] ?? '';
        _controller.tier2ChanceCardsDrawController.text = feat['tier2ChanceCardsDraw'] ?? '';
        _controller.tier2ResourceChanceCardsToHandController.text = feat['tier2ResourceChanceCardsToHand'] ?? '';
        _controller.tier2ResourceChanceCardsDrawController.text = feat['tier2ResourceChanceCardsDraw'] ?? '';

        _controller.tier2Apt4ChanceCardsToHandController.text = feat['tier2Apt4ChanceCardsToHand'] ?? '';
        _controller.tier2Apt4ChanceCardsDrawController.text = feat['tier2Apt4ChanceCardsDraw'] ?? '';
        _controller.tier2Apt4ResourceChanceCardsToHandController.text = feat['tier2Apt4ResourceChanceCardsToHand'] ?? '';
        _controller.tier2Apt4ResourceChanceCardsDrawController.text = feat['tier2Apt4ResourceChanceCardsDraw'] ?? '';

        _controller.tier2Apt8ChanceCardsToHandController.text = feat['tier2Apt8ChanceCardsToHand'] ?? '';
        _controller.tier2Apt8ChanceCardsDrawController.text = feat['tier2Apt8ChanceCardsDraw'] ?? '';
        _controller.tier2Apt8ResourceChanceCardsToHandController.text = feat['tier2Apt8ResourceChanceCardsToHand'] ?? '';
        _controller.tier2Apt8ResourceChanceCardsDrawController.text = feat['tier2Apt8ResourceChanceCardsDraw'] ?? '';

        setState(() {
          _controller.selectedType = feat['type'] ?? 'Attack';
          _controller.hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      print('Error loading feat details: $e');
    }
  }


  Future<void> _handleSave() async {
    if (_controller.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a feat name before saving.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final feat = {
        'name': _controller.nameController.text,
        'type': _controller.selectedType,
        'associatedAptitude': _controller.aptitudeController.text,
        'level': int.tryParse(_controller.levelController.text) ?? 0,
        'requirement': _controller.requirementController.text,
        'pillar': _controller.pillarController.text,
        'fluff': _controller.fluffController.text,
        'crunch': _controller.crunchController.text,
        'sourceBook': _controller.sourceController.text,

        // 🔹 Basic Tier
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

        // 🔹 Tier 1
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

        // 🔹 Tier 2
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

      // 🔹 Load existing feats, remove old entry, and add updated one
      final allFeats = await FeatService.loadFeats();
      allFeats.removeWhere((f) => f['name'] == _controller.nameController.text);
      allFeats.add(feat);

      await FeatService.saveFeat(allFeats);

      widget.onFeatListRefresh();

      setState(() {
        _controller.hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feat saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving feat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _handleDelete() async {
    if (_controller.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a feat to delete.'),
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
                'Are you sure you want to delete this feat? This action cannot be undone.'),
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
        final allFeats = await FeatService.loadFeats();
        allFeats.removeWhere((f) => f['name'] == _controller.nameController.text);
        await FeatService.saveFeat(allFeats);

        widget.onFeatListRefresh();

        _controller.clearFields();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feat deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting feat: ${e.toString()}'),
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
          // Basic Info Section
          Expanded(
            child: FeatInfoForm(
              nameController: _controller.nameController,
              levelController: _controller.levelController,
              requirementController: _controller.requirementController,
              aptitudeController: _controller.aptitudeController,
              fluffController: _controller.fluffController,
              crunchController: _controller.crunchController,
              pillarController: _controller.pillarController,
              sourceController: _controller.sourceController,
              selectedType: _controller.selectedType,
              continuousDevelopment: _controller.continuousDevelopment,
              onTypeChanged: (value) => setState(() => _controller.selectedType = value),
              onContinuousDevelopmentChanged: (value) => setState(() => _controller.continuousDevelopment = value),
              onSave: _handleSave, // Use the _handleSave method
              onClear: _controller.clearFields, // Add the onClear callback
              onDelete: _handleDelete, // Add the onDelete callback
              onParseFromText: _openFeatParserDialog,
            ),
          ),

          const SizedBox(width: 1),

          // Basic Tier Section
          Expanded(
            child: BasicTierSection(
              effectController: _controller.basicEffectController,
              apt4ChangeController: _controller.basicApt4ChangeController,
              apt4FullTextController: _controller.basicApt4FullTextController,
              apt8ChangeController: _controller.basicApt8ChangeController,
              apt8FullTextController: _controller.basicApt8FullTextController,
              
              basicChanceCardsToHandController: _controller.basicChanceCardsToHandController,
              basicChanceCardsDrawController: _controller.basicChanceCardsDrawController,
              basicResourceChanceCardsToHandController: _controller.basicResourceChanceCardsToHandController,
              basicResourceChanceCardsDrawController: _controller.basicResourceChanceCardsDrawController,

              basicApt4ChanceCardsToHandController: _controller.basicApt4ChanceCardsToHandController,
              basicApt4ChanceCardsDrawController: _controller.basicApt4ChanceCardsDrawController,
              basicApt4ResourceChanceCardsToHandController: _controller.basicApt4ResourceChanceCardsToHandController,
              basicApt4ResourceChanceCardsDrawController: _controller.basicApt4ResourceChanceCardsDrawController,

              basicApt8ChanceCardsToHandController: _controller.basicApt8ChanceCardsToHandController,
              basicApt8ChanceCardsDrawController: _controller.basicApt8ChanceCardsDrawController,
              basicApt8ResourceChanceCardsToHandController: _controller.basicApt8ResourceChanceCardsToHandController,
              basicApt8ResourceChanceCardsDrawController: _controller.basicApt8ResourceChanceCardsDrawController,
            ),
          ),

          const SizedBox(width: 1),

          // Tier 1 Section
          Expanded(
            child: TierOneSection(
              effectController: _controller.tier1EffectController,
              apt4ChangeController: _controller.tier1Apt4ChangeController,
              apt4FullTextController: _controller.tier1Apt4FullTextController,
              apt8ChangeController: _controller.tier1Apt8ChangeController,
              apt8FullTextController: _controller.tier1Apt8FullTextController,

              tier1ChanceCardsToHandController: _controller.tier1ChanceCardsToHandController,
              tier1ChanceCardsDrawController: _controller.tier1ChanceCardsDrawController,
              tier1ResourceChanceCardsToHandController: _controller.tier1ResourceChanceCardsToHandController,
              tier1ResourceChanceCardsDrawController: _controller.tier1ResourceChanceCardsDrawController,

              tier1Apt4ChanceCardsToHandController: _controller.tier1Apt4ChanceCardsToHandController,
              tier1Apt4ChanceCardsDrawController: _controller.tier1Apt4ChanceCardsDrawController,
              tier1Apt4ResourceChanceCardsToHandController: _controller.tier1Apt4ResourceChanceCardsToHandController,
              tier1Apt4ResourceChanceCardsDrawController: _controller.tier1Apt4ResourceChanceCardsDrawController,

              tier1Apt8ChanceCardsToHandController: _controller.tier1Apt8ChanceCardsToHandController,
              tier1Apt8ChanceCardsDrawController: _controller.tier1Apt8ChanceCardsDrawController,
              tier1Apt8ResourceChanceCardsToHandController: _controller.tier1Apt8ResourceChanceCardsToHandController,
              tier1Apt8ResourceChanceCardsDrawController: _controller.tier1Apt8ResourceChanceCardsDrawController,
            ),
          ),


          const SizedBox(width: 1),

          // Tier 2 Section
          Expanded(
            child: TierTwoSection(
              effectController: _controller.tier2EffectController,
              apt4ChangeController: _controller.tier2Apt4ChangeController,
              apt4FullTextController: _controller.tier2Apt4FullTextController,
              apt8ChangeController: _controller.tier2Apt8ChangeController,
              apt8FullTextController: _controller.tier2Apt8FullTextController,

              tier2ChanceCardsToHandController: _controller.tier2ChanceCardsToHandController,
              tier2ChanceCardsDrawController: _controller.tier2ChanceCardsDrawController,
              tier2ResourceChanceCardsToHandController: _controller.tier2ResourceChanceCardsToHandController,
              tier2ResourceChanceCardsDrawController: _controller.tier2ResourceChanceCardsDrawController,

              tier2Apt4ChanceCardsToHandController: _controller.tier2Apt4ChanceCardsToHandController,
              tier2Apt4ChanceCardsDrawController: _controller.tier2Apt4ChanceCardsDrawController,
              tier2Apt4ResourceChanceCardsToHandController: _controller.tier2Apt4ResourceChanceCardsToHandController,
              tier2Apt4ResourceChanceCardsDrawController: _controller.tier2Apt4ResourceChanceCardsDrawController,

              tier2Apt8ChanceCardsToHandController: _controller.tier2Apt8ChanceCardsToHandController,
              tier2Apt8ChanceCardsDrawController: _controller.tier2Apt8ChanceCardsDrawController,
              tier2Apt8ResourceChanceCardsToHandController: _controller.tier2Apt8ResourceChanceCardsToHandController,
              tier2Apt8ResourceChanceCardsDrawController: _controller.tier2Apt8ResourceChanceCardsDrawController,
            ),
          ),
        ],
      ),
    );
  }
}