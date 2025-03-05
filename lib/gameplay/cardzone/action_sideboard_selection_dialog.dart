import 'package:flutter/material.dart';
import '../../universal/models/action_card_data.dart';
import '../../universal/widgets/card_widget.dart';

class ActionSideboardSelectionDialog extends StatefulWidget {
  final List<CardData> sideboardCards;
  final Function(CardData) onSelect;
  final VoidCallback onCancel;

  const ActionSideboardSelectionDialog({
    super.key,
    required this.sideboardCards,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  _ActionSideboardSelectionDialogState createState() => _ActionSideboardSelectionDialogState();
}

class _ActionSideboardSelectionDialogState extends State<ActionSideboardSelectionDialog> {
  CardData? selectedCard;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Select Action Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Card Grid
            Expanded(
              child: widget.sideboardCards.isEmpty
                ? const Center(child: Text('No action cards available', style: TextStyle(color: Colors.white)))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.sideboardCards.length,
                    itemBuilder: (context, index) {
                      final card = widget.sideboardCards[index];
                      final isSelected = selectedCard == card;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedCard = card;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(color: Colors.yellow, width: 3)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GameCard(
                            cardData: card,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                selectedCard = card;
                              });
                            },
                            isHovered: false, // Add required isHovered parameter
                          ),
                        ),
                      );
                    },
                  ),
            ),
            
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: selectedCard == null
                        ? null
                        : () => widget.onSelect(selectedCard!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      disabledBackgroundColor: Colors.grey.shade600,
                    ),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
