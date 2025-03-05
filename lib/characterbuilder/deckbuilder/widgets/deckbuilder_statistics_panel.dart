import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/characterbuilder/deckbuilder/models/deckbuilder_state.dart';

class DeckBuilderStatisticsPanel extends StatelessWidget {
  final DeckBuilderState deckState;
  final List<CardData> availableCards;
  final VoidCallback onClearDeck;
  final Function(String) onSortOptionChanged;

  const DeckBuilderStatisticsPanel({
    super.key,
    required this.deckState,
    required this.availableCards,
    required this.onClearDeck,
    required this.onSortOptionChanged,
  });

  List<Widget> _buildSubTotals() {
    final subTotals = deckState.calculateSubTotals(availableCards);
    
    return subTotals.entries.map((entry) {
      final type = entry.key;
      final totals = entry.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$type:'),
          Row(
            children: [
              Text('${totals['qty']}', textAlign: TextAlign.center),
              const SizedBox(width: 10),
              Text('${totals['pts']} pts', textAlign: TextAlign.center),
            ],
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = deckState.totalCards;
    final totalCost = deckState.calculateTotalCost(availableCards);
    final Color qtyColor = totalQty == deckState.maxDeckSize ? Colors.black : Colors.pink;
    final Color pointsColor = totalCost == deckState.maxPoints ? Colors.black : Colors.pink;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deck Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deck Size:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalQty/${deckState.maxDeckSize}',
                  style: TextStyle(color: qtyColor),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Construction Points:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalCost/${deckState.maxPoints}',
                  style: TextStyle(color: pointsColor),
                ),
              ],
            ),
            const Divider(),
            
            // Type Statistics
            ..._buildSubTotals(),
            const SizedBox(height: 20),

            // Control Buttons
            ElevatedButton(
              onPressed: onClearDeck,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(36),
              ),
              child: const Text(
                'Clear Selections',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            
            // Sort Options
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: deckState.sortOption,
                items: const [
                  DropdownMenuItem(value: 'Type', child: Text('Sort by Type')),
                  DropdownMenuItem(value: 'Cost', child: Text('Sort by Cost')),
                  DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortOptionChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}