// lib/gameplay/cardzone/hand_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../universal/models/hero_ability_card_model.dart';
import '../../universal/widgets/card_widget.dart';
import '../gameplay_provider.dart';
import 'action_execution_dialog.dart';
import 'package:card_game/universal/models/action_card_data.dart';

import 'package:card_game/universal/models/chance_card_data.dart';
import 'package:card_game/universal/widgets/chance_card_widget.dart';

/// Outer wrapper that sets a background color of Colors.grey[850]
/// and shows the HandSection inside. We can reuse this in your CardZoneColumn.
class HandSectionParent extends StatelessWidget {
  const HandSectionParent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Parent's background color
      color: Colors.grey[850],
      // Child is your main HandSection logic (which itself has color: Colors.grey[900])
      child: const HandSection(),
    );
  }
}

/// The main HandSection code (with row chunking, hover/selected expansion, etc.)
class HandSection extends ConsumerStatefulWidget {
  const HandSection({super.key});

  @override
  ConsumerState<HandSection> createState() => _HandSectionState();
}

class _HandSectionState extends ConsumerState<HandSection>
    with TickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _pulseController;

  // Normal card size
  static const double cardWidth = 120;
  static const double cardHeight = 180;

  // Expanded (hovered or selected) card size
  static const double hoveredCardWidth = 200;
  static const double hoveredCardHeight = 280;

  // Spacing
  static const double horizontalSpacing = 8;
  static const double verticalRowSpacing = 8;

  // Outer container height (for scrolling)
  static const double containerHeight = 400;

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
    final gameState = ref.watch(gameplayProvider);
    final hand = gameState.hand;

    return Container(
      padding: const EdgeInsets.only(left: 8.0), // Add padding to the left side
      color: Colors.grey[900],
      height: containerHeight,
      // Vertical scroll for multiple rows
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;

            // How much space for one card + horizontal spacing
            const totalCardSpace = cardWidth + horizontalSpacing;
            int cardsPerRow = (containerWidth ~/ totalCardSpace);
            if (cardsPerRow < 1) {
              cardsPerRow = 1;
            }

            final rowWidgets = <Widget>[];

            // Split the hand into rows
            for (int i = 0; i < hand.length; i += cardsPerRow) {
              final rowCards = hand.sublist(
                i,
                (i + cardsPerRow > hand.length) ? hand.length : i + cardsPerRow,
              );

              rowWidgets.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: verticalRowSpacing),
                  // Horizontal scroll so no overflow warnings
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rowCards.asMap().entries.map((entry) {
                        final localIndex = entry.key;
                        final card = entry.value;
                        final globalIndex = i + localIndex;

                        final uniqueId = globalIndex * 10000 + card.id;
                        final isSelected = (gameState.selectedCardId == uniqueId);
                        final isHovered = (_hoveredIndex == globalIndex);

                        // Hovered or selected => expanded
                        final shouldExpand = isHovered || isSelected;
                        final thisCardWidth =
                            shouldExpand ? hoveredCardWidth : cardWidth;
                        final thisCardHeight =
                            shouldExpand ? hoveredCardHeight : cardHeight;

                        return GestureDetector(
                          onLongPress: () => _showContextMenu(context, ref, card, globalIndex),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = globalIndex),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: Padding(
                              padding: const EdgeInsets.only(right: horizontalSpacing),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                transformAlignment: Alignment.topCenter,
                                width: thisCardWidth,
                                height: thisCardHeight,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: _HandGameCard(
                                  cardData: card,
                                  isHovered: isHovered,
                                  isSelected: isSelected,
                                  uniqueId: uniqueId,
                                  pulseAnimation:
                                      isSelected ? _pulseController : null,
                                  onTap: () {
                                    final actionCardMetadata = card.metadata ?? '';
                                    if (actionCardMetadata.isEmpty ||
                                        actionCardMetadata.toLowerCase() == 'none') {
                                      // Clear previously selected
                                      ref
                                          .read(gameplayProvider.notifier)
                                          .toggleCardSelection(card, uniqueId: null);

                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => ActionExecutionDialog(
                                          actionCard: card,
                                          heroAbility: HeroAbilityCardModel(
                                            id: card.id,
                                            name: card.name,
                                            type: card.type,
                                            effect: card.effect,
                                            tier: 'Basic',
                                          ),
                                          onCancel: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      );
                                    } else {
                                      ref
                                          .read(gameplayProvider.notifier)
                                          .toggleCardSelection(
                                              card, uniqueId: uniqueId);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowWidgets,
            );
          },
        ),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context, 
    WidgetRef ref, 
    CardData card, 
    int index
  ) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'discard',
          child: Text('Discard'),
        ),
        const PopupMenuItem<String>(
          value: 'sideboard',
          child: Text('Move to Sideboard'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      switch (value) {
        case 'discard':
          ref.read(gameplayProvider.notifier).deckManager.discardCardByIndex(index);
          break;
        case 'sideboard':
          ref.read(gameplayProvider.notifier).moveFromHandToSideboard(card);
          break;
      }
    });
  }
}

/// Custom GameCard with discard option
class _HandGameCard extends StatelessWidget {
  final CardData cardData;
  final bool isHovered;
  final bool isSelected;
  final int uniqueId;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  const _HandGameCard({
    required this.cardData,
    required this.isHovered,
    required this.isSelected,
    required this.uniqueId,
    required this.onTap,
    this.pulseAnimation,
  });

  Widget _buildCardWidget() {
    if (cardData is ChanceCardData) {
      // If it's a Chance Card, render ChanceCardWidget
      final chanceData = cardData as ChanceCardData;
      return ChanceCardWidget(
        cardData: chanceData, // Corrected: Changed from chanceCardData to cardData
        isHovered: isHovered,
        isSelected: isSelected,
        pulseAnimation: pulseAnimation,
        onTap: onTap,
      );
    } else {
      // Otherwise, it's a normal action card
      return GameCard(
        cardData: cardData,
        isHovered: isHovered,
        isSelected: isSelected,
        pulseAnimation: pulseAnimation,
        onTap: onTap,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Stack(
        children: [
          // Use the _buildCardWidget to render the correct card type
          _buildCardWidget(),
          
          // Move the menu button from bottom right to top left
          if (isHovered)
            Positioned(
              top: 10, // Changed from bottom: 10
              left: 10, // Changed from right: 10
              child: GestureDetector(
                onTap: () {
                  // Get the position of the clicked widget
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  
                  // Calculate the position for the popup
                  final position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(const Offset(0, 0), ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );
                  
                  // Show card options menu
                  showMenu<String>(
                    context: context,
                    position: position,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.grey[850],
                    items: [
                      // Sideboard Option
                      const PopupMenuItem<String>(
                        value: 'sideboard',
                        child: Row(
                          children: [
                            Icon(
                              Icons.archive_outlined, 
                              color: Colors.purple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Move to Sideboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Discard Option
                      const PopupMenuItem<String>(
                        value: 'discard',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline, 
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Discard Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).then((value) {
                    if (value == null) return;
                    
                    // If the card was selected, unselect it
                    if (isSelected) {
                      ref
                        .read(gameplayProvider.notifier)
                        .toggleCardSelection(cardData, uniqueId: null);
                    }
                    
                    // Execute action immediately without confirmation
                    if (value == 'sideboard') {
                      // Move directly to sideboard
                      ref.read(gameplayProvider.notifier).moveFromHandToSideboard(cardData);
                    } else if (value == 'discard') {
                      // Find the index of the card in hand
                      final gameState = ref.read(gameplayProvider);
                      final index = gameState.hand.indexWhere((c) => c == cardData);

                      // Ensure we remove only one instance
                      if (index != -1) {
                        ref.read(gameplayProvider.notifier).deckManager.discardCardByIndex(index);
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}