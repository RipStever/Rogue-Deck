// lib/gameplay/cardzone/chance_discard_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'package:card_game/universal/models/chance_card_data.dart';
import 'package:card_game/universal/widgets/chance_card_widget.dart';
import 'package:card_game/gameplay/gameplay_provider.dart';

class ChanceDiscardDialog extends ConsumerStatefulWidget {
  final List<CardData> discardPile;
  final VoidCallback onReshuffle;

  const ChanceDiscardDialog({
    super.key, 
    required this.discardPile,
    required this.onReshuffle,
  });

  @override
  ConsumerState<ChanceDiscardDialog> createState() => _ChanceDiscardDialogState();
}

class _ChanceDiscardDialogState extends ConsumerState<ChanceDiscardDialog> with TickerProviderStateMixin {
  int? _selectedCardIndex;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Chance Discard Pile', 
                style: TextStyle(color: Colors.blue[100]),
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.discardPile.length} Cards',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.discardPile.length,
                itemBuilder: (context, index) {
                  final card = widget.discardPile[index];
                  final isSelected = _selectedCardIndex == index;

                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.identity()
                          ..translate(0.0, isSelected ? -10.0 : 0.0),
                        decoration: isSelected ? BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3 + (_pulseController.value * 0.2)),
                              blurRadius: 8 + (_pulseController.value * 4),
                              spreadRadius: 2 + (_pulseController.value * 2),
                            )
                          ],
                        ) : null,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCardIndex = _selectedCardIndex == index ? null : index;
                            });
                          },
                          child: ChanceCardWidget(
                            cardData: ChanceCardData.fromCardData(card),
                            isHovered: false,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCardIndex = _selectedCardIndex == index ? null : index;
                              });
                            },
                            pulseAnimation: _pulseController,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDeckManipulationButton(
                      icon: Icons.undo,
                      label: 'Return to Hand',
                      color: Colors.blue[600], // You can change this color
                      onPressed: _selectedCardIndex == null ? null : () {
                        final selectedCard = widget.discardPile[_selectedCardIndex!];
                        ref.read(gameplayProvider.notifier).deckManager.returnChanceDiscardToHand(selectedCard);
                        Navigator.of(context).pop();
                      },
                    ),
                    _buildDeckManipulationButton(
                      icon: Icons.vertical_align_top,
                      label: 'Add to Top',
                      color: Colors.blue[700],
                      onPressed: _selectedCardIndex == null ? null : () {
                      final selectedCard = widget.discardPile[_selectedCardIndex!];
                      print('Selected card for moving to top: ${selectedCard.name}');
                      ref.read(gameplayProvider.notifier).deckManager.moveDiscardToTop(selectedCard);
                      Navigator.of(context).pop();
                    },
                    ),
                    _buildDeckManipulationButton(
                      icon: Icons.vertical_align_bottom,
                      label: 'Add to Bottom',
                      color: Colors.red[700],
                      onPressed: _selectedCardIndex == null ? null : () {
                        final selectedCard = widget.discardPile[_selectedCardIndex!];
                        print('Selected card for moving to bottom: ${selectedCard.name}');
                        ref.read(gameplayProvider.notifier).deckManager.moveDiscardToBottom(selectedCard);
                        Navigator.of(context).pop();
                      },
                    ),
                    _buildDeckManipulationButton(
                      icon: Icons.shuffle,
                      label: 'Add & Shuffle',
                      color: Colors.orange[700],
                      onPressed: _selectedCardIndex == null ? null : () {
                        final selectedCard = widget.discardPile[_selectedCardIndex!];
                        print('Selected card for moving and shuffling: ${selectedCard.name}');
                        ref.read(gameplayProvider.notifier).deckManager.moveDiscardAndShuffle(selectedCard);
                        Navigator.of(context).pop();
                      },
                    ),
                    _buildDeckManipulationButton(
                      icon: Icons.refresh,
                      label: 'Reshuffle',
                      color: Colors.green[700],
                      onPressed: () {
                        widget.onReshuffle();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDeckManipulationButton({
    required IconData icon,
    required String label,
    required Color? color,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      decoration: BoxDecoration(
        color: isEnabled 
          ? color?.withOpacity(0.2) 
          : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled 
            ? color ?? Colors.grey[600]! 
            : Colors.grey[600]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon, 
                    color: isEnabled ? color : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isEnabled ? Colors.white : Colors.grey[600],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}