import 'package:flutter/material.dart';
import 'package:card_game/universal/models/character_model.dart';

class CharacterBuilderStatsWidget extends StatefulWidget {
  final CharacterModel characterModel;
  final Function(String stat, int bonus)? onBonusChanged;

  const CharacterBuilderStatsWidget({
    super.key,
    required this.characterModel,
    this.onBonusChanged,
  });

  @override
  _CharacterBuilderStatsWidgetState createState() => _CharacterBuilderStatsWidgetState();
}

class _CharacterBuilderStatsWidgetState extends State<CharacterBuilderStatsWidget> {
  static const List<String> _statLabels = [
    'HP',
    'Speed',
    'Aptitude Cap',
    'Max Hand Size',
    'Card Improvements',
    'Origin Perks',
    'Talents',
    'Feats',
    'Evolutions',
    'Weapon Slots',
    'Item Slots',
  ];

  final Map<String, TextEditingController> _bonusControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final stat in _statLabels) {
      final bonusValue = widget.characterModel.stats?[stat]?['bonus'] ?? 0;
      _bonusControllers[stat] = TextEditingController(text: bonusValue.toString())
        ..addListener(() => _onBonusChanged(stat));
    }
  }

  void _onBonusChanged(String stat) {
    final controller = _bonusControllers[stat];
    if (controller == null) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    final parsedBonus = int.tryParse(text) ?? 0;
    widget.onBonusChanged?.call(stat, parsedBonus);
  }

  @override
  void didUpdateWidget(CharacterBuilderStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if model changes externally
    for (final stat in _statLabels) {
      final newBonus = widget.characterModel.stats?[stat]?['bonus'] ?? 0;
      final currentText = _bonusControllers[stat]?.text;
      if (currentText != newBonus.toString()) {
        _bonusControllers[stat]?.text = newBonus.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[850],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _statLabels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildStatCard(_statLabels[index]),
    );
  }

  Widget _buildStatCard(String stat) {
    final baseValue = widget.characterModel.stats?[stat]?['base'] ?? 0;
    final bonusValue = widget.characterModel.stats?[stat]?['bonus'] ?? 0;
    final totalValue = baseValue + bonusValue;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildStatLabel(stat),
            _buildStatValue('Base', baseValue),
            _buildBonusInput(stat),
            _buildStatValue('Total', totalValue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatLabel(String stat) {
    return Expanded(
      flex: 2,
      child: Text(
        stat,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatValue(String label, int value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text('$value', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBonusInput(String stat) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Bonus', style: TextStyle(fontSize: 12)),
          TextField(
            controller: _bonusControllers[stat],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _bonusControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}