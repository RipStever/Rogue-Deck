// lib/gameplay/cardzone/hero_actions_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../universal/models/hero_ability_card_model.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import '../gameplay_provider.dart';
import 'action_execution_dialog.dart';
import '../../universal/widgets/hero_ability_card_widget.dart';

class HeroActionsSection extends ConsumerStatefulWidget {
  const HeroActionsSection({super.key});

  @override
  ConsumerState<HeroActionsSection> createState() => _HeroActionsSectionState();
}

class _HeroActionsSectionState extends ConsumerState<HeroActionsSection> {
  int? _hoveredIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Select an Action Card',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an action card from your hand to view compatible abilities',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoAbilitiesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 48,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No Compatible Abilities',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesGrid(BuildContext context, List<CardData> abilities, CardData selectedCard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Card dimensions
        const baseCardWidth = 180.0;
        const baseCardHeight = 250.0;
        const hoveredCardWidth = 220.0;
        const hoveredCardHeight = 330.0;
        const spacing = 12.0;

        // Calculate cards per row
        final cardsPerRow = (constraints.maxWidth / (baseCardWidth + spacing)).floor().clamp(1, 5);

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < abilities.length; i += cardsPerRow)
                Padding(
                  padding: const EdgeInsets.only(bottom: spacing),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        // Ensure we don't exceed list length
                        (i + cardsPerRow > abilities.length) 
                          ? abilities.length - i 
                          : cardsPerRow,
                        (rowIndex) {
                          final globalIndex = i + rowIndex;
                          final ability = abilities[globalIndex];
                          final uniqueId = ability.id * 10000 + globalIndex;

                          return FutureBuilder<HeroAbilityCardModel>(
                            future: HeroAbilityCardModel.fromCardData(ability),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return MouseRegion(
                                onEnter: (_) => setState(() => _hoveredIndex = globalIndex),
                                onExit: (_) => setState(() => _hoveredIndex = null),
                                child: Padding(
                                  padding: EdgeInsets.only(right: globalIndex == abilities.length - 1 ? 0 : spacing),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    width: _hoveredIndex == globalIndex ? hoveredCardWidth : baseCardWidth,
                                    height: _hoveredIndex == globalIndex ? hoveredCardHeight : baseCardHeight,
                                    transformAlignment: Alignment.topCenter,
                                    child: HeroAbilityCard(
                                      ability: snapshot.data!,
                                      onTap: () => _showExecutionDialog(
                                        context,
                                        ref,
                                        selectedCard,
                                        snapshot.data!,
                                      ),
                                      isHovered: _hoveredIndex == globalIndex,
                                      preventFullDialog: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showExecutionDialog(
    BuildContext context,
    WidgetRef ref,
    CardData actionCard,
    HeroAbilityCardModel ability,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActionExecutionDialog(
        actionCard: actionCard,
        heroAbility: ability,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameplayProvider);
    final selectedCard = gameState.selectedCard;
   
    return Container(
      padding: const EdgeInsets.only(left: 8.0), // Add padding to the left side
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedCard != null ? Colors.blue[700]! : Colors.white10,
          width: selectedCard != null ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCard != null 
                    ? 'Compatible Abilities for ${selectedCard.name}'
                    : 'Select an Action Card to view compatible abilities',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedCard != null)
                  Text(
                    '${gameState.compatibleAbilities.length} Abilities',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Abilities List or Empty State
          Expanded(
            child: selectedCard == null
                ? _buildEmptyState()
                : gameState.compatibleAbilities.isEmpty
                    ? _buildNoAbilitiesState()
                    : _buildAbilitiesGrid(
                        context,
                        gameState.compatibleAbilities,
                        selectedCard,
                      ),
          ),
        ],
      ),
    );
  }
}