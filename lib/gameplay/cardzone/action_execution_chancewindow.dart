// lib/gameplay/cardzone/action_execution_chancewindow.dart
import 'package:flutter/material.dart';
import '../../universal/models/chance_card_data.dart';
import '../../universal/widgets/chance_card_widget.dart';

class ChanceWindow extends StatelessWidget {
  final int chanceDeckCount;
  final List<ChanceCardData> drawnCards;
  final List<ChanceCardData> chanceCardsToHand;
  final VoidCallback onDraw;
  final VoidCallback onUndo;  // Keep the callback, but we'll use it differently

  const ChanceWindow({
    super.key,
    required this.chanceDeckCount,
    required this.drawnCards,
    required this.chanceCardsToHand,
    required this.onDraw,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Drawn Chance Cards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: drawnCards.isEmpty
                    ? const Center(
                        child: Text(
                          'No Chance Cards Drawn',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: drawnCards.length,
                        itemBuilder: (context, index) {
                          return ChanceCardWidget(
                            cardData: drawnCards[index],
                            isHovered: false,
                            isSelected: false,
                            onTap: () {},
                            pulseAnimation: null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Chance Card to Hand',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: chanceCardsToHand.isEmpty
                    ? const Center(
                        child: Text(
                          'No Cards Staged',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: chanceCardsToHand.length,
                        itemBuilder: (context, index) {
                          return ChanceCardWidget(
                            cardData: chanceCardsToHand[index],
                            isHovered: false,
                            isSelected: false,
                            onTap: () {},
                            pulseAnimation: null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}