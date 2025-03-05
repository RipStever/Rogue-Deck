import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:card_game/universal/models/character_model.dart';

class LevelChartWidget extends StatefulWidget {
  final CharacterModel? characterModel;
  final Function(int)? onLevelChanged;

  const LevelChartWidget({
    super.key,
    this.characterModel,
    this.onLevelChanged,
  });

  @override
  State<LevelChartWidget> createState() => _LevelChartWidgetState();
}

class _LevelChartWidgetState extends State<LevelChartWidget> {
  List<Map<String, dynamic>> _levelData = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.characterModel?.selectedLevel ?? 1;
    _loadLevelData();
  }

  Future<void> _loadLevelData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/LevelChart.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        _levelData = List<Map<String, dynamic>>.from(jsonData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading level data';
        _isLoading = false;
      });
      debugPrint('Error loading level data: $e');
    }
  }

  Widget _buildLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedLevel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(8, (index) => index + 1)
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text('Level $level'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLevel = value);
                widget.onLevelChanged?.call(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _centeredHeaderText(String text) {
    return SizedBox(
      width: text.contains('\n') ? 60 : 40,  // Wider for multi-line headers
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _centeredText(String text) {
    return SizedBox(
      width: 40,  // Smaller fixed width for single values
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLevelChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 56.0,
        dataRowHeight: 52.0,
        columnSpacing: 8,  // Reduced spacing between columns
        horizontalMargin: 12,  // Reduced margin
        columns: [
          DataColumn(label: _centeredHeaderText('Level')),
          DataColumn(label: _centeredHeaderText('HP')),
          DataColumn(label: _centeredHeaderText('Power')),
          DataColumn(label: _centeredHeaderText('Aptitude\nPoints')),
          DataColumn(label: _centeredHeaderText('Aptitude\nCap')),
          DataColumn(label: _centeredHeaderText('Card\nDraws')),
          DataColumn(label: _centeredHeaderText('Card\nImprovements')),
          DataColumn(label: _centeredHeaderText('Origin\nPerk')),
          DataColumn(label: _centeredHeaderText('Talents')),
          DataColumn(label: _centeredHeaderText('Feats')),
          DataColumn(label: _centeredHeaderText('Evolutions')),
          const DataColumn(
            label: SizedBox(
              width: 150,  // Reduced width for features
              child: Text('Features'),
            ),
          ),
        ],
        rows: _levelData.map((level) {
          final isCurrentLevel = level['level'] == _selectedLevel;
          return DataRow(
            color: isCurrentLevel 
              ? WidgetStateProperty.all(Colors.blue.shade100)
              : null,
            cells: [
              DataCell(_centeredText(level['level'].toString())),
              DataCell(_centeredText(level['hp'].toString())),
              DataCell(_centeredText(level['power'].toString())),
              DataCell(_centeredText(level['aptitudePoints'].toString())),
              DataCell(_centeredText(level['aptitudeCap'].toString())),
              DataCell(_centeredText(level['cardDraws'].toString())),
              DataCell(_centeredText(level['cardImprovements'].toString())),
              DataCell(_centeredText(level['originPerk']?.toString() ?? '-')),
              DataCell(_centeredText(level['talents']?.toString() ?? '-')),
              DataCell(_centeredText(level['feats']?.toString() ?? '-')),
              DataCell(_centeredText(level['evolutions']?.toString() ?? '-')),
              DataCell(
                SizedBox(
                  width: 150,  // Reduced width for features
                  child: Text(level['features']?.toString() ?? '-'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level Selector Column (Flex 1)
        Expanded(
          flex: 1,
          child: _buildLevelSelector(),
        ),
        // Level Chart Column (Flex 2)
        Expanded(
          flex: 7,
          child: _buildLevelChart(),
        ),
      ],
    );
  }
}