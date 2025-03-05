import 'package:flutter/material.dart';

class BasicTierSection extends StatelessWidget {
  final TextEditingController effectController;
  final TextEditingController apt4ChangeController;
  final TextEditingController apt4FullTextController;
  final TextEditingController apt8ChangeController;
  final TextEditingController apt8FullTextController;

  final TextEditingController basicChanceCardsToHandController;
  final TextEditingController basicChanceCardsDrawController;
  final TextEditingController basicResourceChanceCardsToHandController;
  final TextEditingController basicResourceChanceCardsDrawController;

  final TextEditingController basicApt4ChanceCardsToHandController;
  final TextEditingController basicApt4ChanceCardsDrawController;
  final TextEditingController basicApt4ResourceChanceCardsToHandController;
  final TextEditingController basicApt4ResourceChanceCardsDrawController;

  final TextEditingController basicApt8ChanceCardsToHandController;
  final TextEditingController basicApt8ChanceCardsDrawController;
  final TextEditingController basicApt8ResourceChanceCardsToHandController;
  final TextEditingController basicApt8ResourceChanceCardsDrawController;


  const BasicTierSection({
    super.key,
    required this.effectController,
    required this.apt4ChangeController,
    required this.apt4FullTextController,
    required this.apt8ChangeController,
    required this.apt8FullTextController,
    required this.basicChanceCardsToHandController,
    required this.basicChanceCardsDrawController,
    required this.basicResourceChanceCardsToHandController,
    required this.basicResourceChanceCardsDrawController,
    required this.basicApt4ChanceCardsToHandController,
    required this.basicApt4ChanceCardsDrawController,
    required this.basicApt4ResourceChanceCardsToHandController,
    required this.basicApt4ResourceChanceCardsDrawController,
    required this.basicApt8ChanceCardsToHandController,
    required this.basicApt8ChanceCardsDrawController,
    required this.basicApt8ResourceChanceCardsToHandController,
    required this.basicApt8ResourceChanceCardsDrawController,
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
            colors: [Colors.grey.shade300, Colors.grey.shade100],
          ),
          borderRadius: BorderRadius.circular(12), // Ensures the container also matches
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Tier',
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
                  Expanded(child: TextField(controller: basicChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicResourceChanceCardsDrawController)),
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
                  Expanded(child: TextField(controller: basicApt4ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt4ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt4ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt4ResourceChanceCardsDrawController)),
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
                  Expanded(child: TextField(controller: basicApt8ChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt8ChanceCardsDrawController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt8ResourceChanceCardsToHandController)),
                  const SizedBox(width: 4),
                  Expanded(child: TextField(controller: basicApt8ResourceChanceCardsDrawController)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
