import 'package:flutter/material.dart';
import '../../universal/models/chance_card_data.dart';
import '../../universal/widgets/card_widget.dart';

class ChanceSideboardSelectionDialog extends StatefulWidget {
  final List<ChanceCardData> sideboardCards;
  final Function(List<ChanceCardData>, List<ChanceCardData>) onExecute;
  final VoidCallback onCancel;

  const ChanceSideboardSelectionDialog({
    super.key,
    required this.sideboardCards,
    required this.onExecute,
    required this.onCancel,
  });

  @override
  _ChanceSideboardSelectionDialogState createState() => _ChanceSideboardSelectionDialogState();
}

class _ChanceSideboardSelectionDialogState extends State<ChanceSideboardSelectionDialog> {
  final Set<ChanceCardData> _selectedDrawCards = {};
  final Set<ChanceCardData> _selectedHandCards = {};
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
                color: Colors.purple.shade700,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Select Chance Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection instructions
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade700,
              child: const Text(
                'Click cards to toggle selection. Add cards to either the drawn pile or directly to your hand.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            
            // Card Grid
            Expanded(
              child: widget.sideboardCards.isEmpty
                ? const Center(child: Text('No chance cards available', style: TextStyle(color: Colors.white)))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.sideboardCards.length,
                    itemBuilder: (context, index) {
                      final card = widget.sideboardCards[index];
                      final bool isInDrawSelection = _selectedDrawCards.contains(card);
                      final bool isInHandSelection = _selectedHandCards.contains(card);
                      
                      return Stack(
                        children: [
                          GameCard(
                            cardData: card,
                            isSelected: isInDrawSelection || isInHandSelection,
                            onTap: () => _toggleCardSelection(card),
                            isHovered: false, // Add required isHovered parameter
                          ),
                          if (isInDrawSelection)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.visibility, color: Colors.white, size: 16),
                              ),
                            ),
                          if (isInHandSelection)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.pan_tool, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
            ),
            
            // Selection summary
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Draw selection: ${_selectedDrawCards.length} cards',
                    style: TextStyle(color: Colors.amber.shade200),
                  ),
                  Text(
                    'Hand selection: ${_selectedHandCards.length} cards',
                    style: TextStyle(color: Colors.green.shade200),
                  ),
                ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Draw Selected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                        ),
                        onPressed: _selectedDrawCards.isEmpty ? null : _selectAsDrawn,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.pan_tool),
                        label: const Text('Add to Hand'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        onPressed: _selectedHandCards.isEmpty ? null : _selectAsHand,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _hasAnySelection()
                          ? () => widget.onExecute(
                              _selectedDrawCards.toList(),
                              _selectedHandCards.toList(),
                            )
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text('Execute'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCardSelection(ChanceCardData card) {
    setState(() {
      if (_selectedDrawCards.contains(card)) {
        _selectedDrawCards.remove(card);
        _selectedHandCards.add(card);
      } else if (_selectedHandCards.contains(card)) {
        _selectedHandCards.remove(card);
      } else {
        _selectedDrawCards.add(card);
      }
    });
  }

  void _selectAsDrawn() {
    setState(() {
      // Move all cards to drawn selection
      _selectedDrawCards.addAll(_selectedHandCards);
      _selectedHandCards.clear();
    });
  }

  void _selectAsHand() {
    setState(() {
      // Move all cards to hand selection
      _selectedHandCards.addAll(_selectedDrawCards);
      _selectedDrawCards.clear();
    });
  }

  bool _hasAnySelection() {
    return _selectedDrawCards.isNotEmpty || _selectedHandCards.isNotEmpty;
  }
}
