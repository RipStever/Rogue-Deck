import 'package:flutter/material.dart';

class TierTwoSection extends StatelessWidget {
  final TextEditingController effectController;
  final TextEditingController apt4ChangeController;
  final TextEditingController apt4FullTextController;
  final TextEditingController apt8ChangeController;
  final TextEditingController apt8FullTextController;

  final TextEditingController tier2ChanceCardsToHandController;
  final TextEditingController tier2ChanceCardsDrawController;
  final TextEditingController tier2ResourceChanceCardsToHandController;
  final TextEditingController tier2ResourceChanceCardsDrawController;

  final TextEditingController tier2Apt4ChanceCardsToHandController;
  final TextEditingController tier2Apt4ChanceCardsDrawController;
  final TextEditingController tier2Apt4ResourceChanceCardsToHandController;
  final TextEditingController tier2Apt4ResourceChanceCardsDrawController;

  final TextEditingController tier2Apt8ChanceCardsToHandController;
  final TextEditingController tier2Apt8ChanceCardsDrawController;
  final TextEditingController tier2Apt8ResourceChanceCardsToHandController;
  final TextEditingController tier2Apt8ResourceChanceCardsDrawController;

  const TierTwoSection({
    super.key,
    required this.effectController,
    required this.apt4ChangeController,
    required this.apt4FullTextController,
    required this.apt8ChangeController,
    required this.apt8FullTextController,
    required this.tier2ChanceCardsToHandController,
    required this.tier2ChanceCardsDrawController,
    required this.tier2ResourceChanceCardsToHandController,
    required this.tier2ResourceChanceCardsDrawController,
    required this.tier2Apt4ChanceCardsToHandController,
    required this.tier2Apt4ChanceCardsDrawController,
    required this.tier2Apt4ResourceChanceCardsToHandController,
    required this.tier2Apt4ResourceChanceCardsDrawController,
    required this.tier2Apt8ChanceCardsToHandController,
    required this.tier2Apt8ChanceCardsDrawController,
    required this.tier2Apt8ResourceChanceCardsToHandController,
    required this.tier2Apt8ResourceChanceCardsDrawController,
  });

  @override
  Widget build(BuildContext context) {
   return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounds all corners
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade500, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12), // Ensures the container also matches
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
                controller: effectController,
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
                  Expanded(child: TextField(controller: tier2ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2ResourceChanceCardsDrawController)),
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
                controller: apt4ChangeController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),
              const Text('Full Text'),
              TextField(
                controller: apt4FullTextController,
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
                  Expanded(child: TextField(controller: tier2Apt4ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt4ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt4ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt4ResourceChanceCardsDrawController)),
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
                controller: apt8ChangeController,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
              ),
              const Text('Full Text'),
              TextField(
                controller: apt8FullTextController,
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
                  Expanded(child: TextField(controller: tier2Apt8ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt8ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt8ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: tier2Apt8ResourceChanceCardsDrawController)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
