import 'package:flutter/material.dart';
import 'package:card_game/newcontent/weapons/nc_weapon_details_controller.dart';

class TierTwoSection extends StatelessWidget {
  final WeaponDetailsController controller;

  const TierTwoSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade400, Colors.grey.shade200],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tier 2',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Base Effect
              const Text(
                'Base Effect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: controller.tier2EffectController,
                maxLines: null,
                minLines: 3,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),
              const SizedBox(height: 16),

              // Base Tier - Chance Card Draws with Labels & Tooltip
              const Row(
                children: [
                  Text('Chance Card Draws', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Tooltip(
                    message: 'C2H: Cards to Hand\nC2D: Cards Drawn\nR+C2H: Resource + Cards to Hand\nR+C2D: Resource + Cards Drawn',
                    child: Icon(Icons.info_outline, size: 18),
                  ),
                ],
              ),
              const Row(
                children: [
                  Expanded(child: Text('C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('C2D', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2D', textAlign: TextAlign.center)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.tier2ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2ResourceChanceCardsDrawController)),
                ],
              ),

              const SizedBox(height: 24),

              // Divider + Aptitude 4
              const Divider(thickness: 2, color: Colors.blueGrey),
              const SizedBox(height: 8),
              const Text(
                'Aptitude 4',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Change Text'),
              TextField(
                controller: controller.tier2Apt4ChangeController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),

              const Text('Full Text'),
              TextField(
                controller: controller.tier2Apt4FullTextController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),

              // Aptitude 4 - Chance Card Draws with Labels
              const Row(
                children: [
                  Expanded(child: Text('C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('C2D', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2D', textAlign: TextAlign.center)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.tier2Apt4ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt4ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt4ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt4ResourceChanceCardsDrawController)),
                ],
              ),

              const SizedBox(height: 24),

              // Divider + Aptitude 8
              const Divider(thickness: 2, color: Colors.blueGrey),
              const SizedBox(height: 8),
              const Text(
                'Aptitude 8',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Change Text'),
              TextField(
                controller: controller.tier2Apt8ChangeController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),
              const Text('Full Text'),
              TextField(
                controller: controller.tier2Apt8FullTextController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),

              // Aptitude 8 - Chance Card Draws with Labels
              const Row(
                children: [
                  Expanded(child: Text('C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('C2D', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2H', textAlign: TextAlign.center)),
                  Expanded(child: Text('R+C2D', textAlign: TextAlign.center)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.tier2Apt8ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt8ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt8ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: controller.tier2Apt8ResourceChanceCardsDrawController)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
