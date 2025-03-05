import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:card_game/newcontent/feats/nc_feat_details_controller.dart';

class FeatParserDialog extends StatefulWidget {
  final FeatDetailsController controller;

  const FeatParserDialog({
    super.key,
    required this.controller,
  });

  @override
  State<FeatParserDialog> createState() => _FeatParserDialogState();
}

class _FeatParserDialogState extends State<FeatParserDialog> {
  final TextEditingController _textController = TextEditingController();

  Map<String, dynamic> _parseFeat(String text) {
    try {
      return Map<String, dynamic>.from(json.decode(text));
    } catch (e) {
      print('Error parsing JSON: $e');
      return {};
    }
  }

  void _handleParse() {
    final parsedFeat = _parseFeat(_textController.text);
    if (parsedFeat.isNotEmpty) {
      setState(() {
        var c = widget.controller; // Short alias for clarity

        // General Info
        c.nameController.text = parsedFeat['name'] ?? '';
        c.levelController.text = parsedFeat['level']?.toString() ?? '';
        c.requirementController.text = parsedFeat['requirement'] ?? '';
        c.aptitudeController.text = parsedFeat['associatedAptitude'] ?? '';
        c.pillarController.text = parsedFeat['pillar'] ?? '';
        c.sourceController.text = parsedFeat['source'] ?? '';
        c.fluffController.text = parsedFeat['fluff'] ?? '';
        c.crunchController.text = parsedFeat['crunch'] ?? '';

        // Basic Tier
        c.basicEffectController.text = parsedFeat['basicEffect'] ?? '';
        c.basicApt4ChangeController.text = parsedFeat['basicApt4Change'] ?? '';
        c.basicApt4FullTextController.text = parsedFeat['basicApt4FullText'] ?? '';
        c.basicApt8ChangeController.text = parsedFeat['basicApt8Change'] ?? '';
        c.basicApt8FullTextController.text = parsedFeat['basicApt8FullText'] ?? '';

        c.basicChanceCardsToHandController.text = parsedFeat['basicChanceCardsToHand']?.toString() ?? '0';
        c.basicChanceCardsDrawController.text = parsedFeat['basicChanceCardsDraw']?.toString() ?? '0';
        c.basicResourceChanceCardsToHandController.text = parsedFeat['basicResourceChanceCardsToHand']?.toString() ?? '0';
        c.basicResourceChanceCardsDrawController.text = parsedFeat['basicResourceChanceCardsDraw']?.toString() ?? '0';

        c.basicApt4ChanceCardsToHandController.text = parsedFeat['basicApt4ChanceCardsToHand']?.toString() ?? '0';
        c.basicApt4ChanceCardsDrawController.text = parsedFeat['basicApt4ChanceCardsDraw']?.toString() ?? '0';
        c.basicApt4ResourceChanceCardsToHandController.text = parsedFeat['basicApt4ResourceChanceCardsToHand']?.toString() ?? '0';
        c.basicApt4ResourceChanceCardsDrawController.text = parsedFeat['basicApt4ResourceChanceCardsDraw']?.toString() ?? '0';

        c.basicApt8ChanceCardsToHandController.text = parsedFeat['basicApt8ChanceCardsToHand']?.toString() ?? '0';
        c.basicApt8ChanceCardsDrawController.text = parsedFeat['basicApt8ChanceCardsDraw']?.toString() ?? '0';
        c.basicApt8ResourceChanceCardsToHandController.text = parsedFeat['basicApt8ResourceChanceCardsToHand']?.toString() ?? '0';
        c.basicApt8ResourceChanceCardsDrawController.text = parsedFeat['basicApt8ResourceChanceCardsDraw']?.toString() ?? '0';

        // Tier 1
        c.tier1EffectController.text = parsedFeat['tier1Effect'] ?? '';
        c.tier1Apt4ChangeController.text = parsedFeat['tier1Apt4Change'] ?? '';
        c.tier1Apt4FullTextController.text = parsedFeat['tier1Apt4FullText'] ?? '';
        c.tier1Apt8ChangeController.text = parsedFeat['tier1Apt8Change'] ?? '';
        c.tier1Apt8FullTextController.text = parsedFeat['tier1Apt8FullText'] ?? '';

        c.tier1ChanceCardsToHandController.text = parsedFeat['tier1ChanceCardsToHand']?.toString() ?? '0';
        c.tier1ChanceCardsDrawController.text = parsedFeat['tier1ChanceCardsDraw']?.toString() ?? '0';
        c.tier1ResourceChanceCardsToHandController.text = parsedFeat['tier1ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier1ResourceChanceCardsDrawController.text = parsedFeat['tier1ResourceChanceCardsDraw']?.toString() ?? '0';

        c.tier1Apt4ChanceCardsToHandController.text = parsedFeat['tier1Apt4ChanceCardsToHand']?.toString() ?? '0';
        c.tier1Apt4ChanceCardsDrawController.text = parsedFeat['tier1Apt4ChanceCardsDraw']?.toString() ?? '0';
        c.tier1Apt4ResourceChanceCardsToHandController.text = parsedFeat['tier1Apt4ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier1Apt4ResourceChanceCardsDrawController.text = parsedFeat['tier1Apt4ResourceChanceCardsDraw']?.toString() ?? '0';

        c.tier1Apt8ChanceCardsToHandController.text = parsedFeat['tier1Apt8ChanceCardsToHand']?.toString() ?? '0';
        c.tier1Apt8ChanceCardsDrawController.text = parsedFeat['tier1Apt8ChanceCardsDraw']?.toString() ?? '0';
        c.tier1Apt8ResourceChanceCardsToHandController.text = parsedFeat['tier1Apt8ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier1Apt8ResourceChanceCardsDrawController.text = parsedFeat['tier1Apt8ResourceChanceCardsDraw']?.toString() ?? '0';

        // Tier 2
        c.tier2EffectController.text = parsedFeat['tier2Effect'] ?? '';
        c.tier2Apt4ChangeController.text = parsedFeat['tier2Apt4Change'] ?? '';
        c.tier2Apt4FullTextController.text = parsedFeat['tier2Apt4FullText'] ?? '';
        c.tier2Apt8ChangeController.text = parsedFeat['tier2Apt8Change'] ?? '';
        c.tier2Apt8FullTextController.text = parsedFeat['tier2Apt8FullText'] ?? '';

        c.tier2ChanceCardsToHandController.text = parsedFeat['tier2ChanceCardsToHand']?.toString() ?? '0';
        c.tier2ChanceCardsDrawController.text = parsedFeat['tier2ChanceCardsDraw']?.toString() ?? '0';
        c.tier2ResourceChanceCardsToHandController.text = parsedFeat['tier2ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier2ResourceChanceCardsDrawController.text = parsedFeat['tier2ResourceChanceCardsDraw']?.toString() ?? '0';

        c.tier2Apt4ChanceCardsToHandController.text = parsedFeat['tier2Apt4ChanceCardsToHand']?.toString() ?? '0';
        c.tier2Apt4ChanceCardsDrawController.text = parsedFeat['tier2Apt4ChanceCardsDraw']?.toString() ?? '0';
        c.tier2Apt4ResourceChanceCardsToHandController.text = parsedFeat['tier2Apt4ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier2Apt4ResourceChanceCardsDrawController.text = parsedFeat['tier2Apt4ResourceChanceCardsDraw']?.toString() ?? '0';

        c.tier2Apt8ChanceCardsToHandController.text = parsedFeat['tier2Apt8ChanceCardsToHand']?.toString() ?? '0';
        c.tier2Apt8ChanceCardsDrawController.text = parsedFeat['tier2Apt8ChanceCardsDraw']?.toString() ?? '0';
        c.tier2Apt8ResourceChanceCardsToHandController.text = parsedFeat['tier2Apt8ResourceChanceCardsToHand']?.toString() ?? '0';
        c.tier2Apt8ResourceChanceCardsDrawController.text = parsedFeat['tier2Apt8ResourceChanceCardsDraw']?.toString() ?? '0';

        c.hasUnsavedChanges = true;
      });

      Navigator.of(context).pop();
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
            const Text('Feat Text Parser', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 15,
              decoration: const InputDecoration(
                hintText: 'Paste JSON feat data here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _handleParse, child: const Text('Parse Feat')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
