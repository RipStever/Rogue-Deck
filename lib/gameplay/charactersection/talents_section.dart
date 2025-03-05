import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/universal/widgets/talent_card_widget.dart';
import 'package:card_game/gameplay/gameplay_provider.dart';

class TalentsSectionParent extends StatelessWidget {
  const TalentsSectionParent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      child: const TalentsSection(),
    );
  }
}

class TalentsSection extends ConsumerStatefulWidget {
  const TalentsSection({super.key});

  @override
  ConsumerState<TalentsSection> createState() => _TalentsSectionState();
}

class _TalentsSectionState extends ConsumerState<TalentsSection> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final CharacterModel? characterModel = ref.watch(characterModelProvider);

    if (characterModel == null) {
      return Center(
        child: Text(
          'No character loaded',
          style: TextStyle(color: Colors.grey[300]),
        ),
      );
    }

    final selectedTalents = characterModel.selectedTalents ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Talents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${selectedTalents.length} Talents',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Talents List
          Expanded(
            child: selectedTalents.isEmpty
                ? Center(
                    child: Text(
                      'No Talents selected',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final containerWidth = constraints.maxWidth;
                        const double cardWidth = 200;
                        const double hoveredCardWidth = 220;
                        const double cardHeight = 300;
                        const double hoveredCardHeight = 330;
                        const double horizontalSpacing = 8;
                        const double verticalRowSpacing = 8;

                        const totalCardSpace = cardWidth + horizontalSpacing;
                        int cardsPerRow = (containerWidth ~/ totalCardSpace);
                        if (cardsPerRow < 1) {
                          cardsPerRow = 1;
                        }

                        final rowWidgets = <Widget>[];

                        for (int i = 0; i < selectedTalents.length; i += cardsPerRow) {
                          final rowTalents = selectedTalents.sublist(
                            i,
                            (i + cardsPerRow > selectedTalents.length) ? selectedTalents.length : i + cardsPerRow,
                          );

                          rowWidgets.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: verticalRowSpacing),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: rowTalents.asMap().entries.map((entry) {
                                    final localIndex = entry.key;
                                    final talent = entry.value;
                                    final globalIndex = i + localIndex;

                                    final isHovered = _hoveredIndex == globalIndex;

                                    return MouseRegion(
                                      onEnter: (_) => setState(() => _hoveredIndex = globalIndex),
                                      onExit: (_) => setState(() => _hoveredIndex = null),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: horizontalSpacing),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          width: isHovered ? hoveredCardWidth : cardWidth,
                                          height: isHovered ? hoveredCardHeight : cardHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isHovered ? Colors.blue : Colors.grey[800]!,
                                              width: isHovered ? 2 : 1,
                                            ),
                                            boxShadow: isHovered
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: TalentCardWidget(talentData: talent),
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
          ),
        ],
      ),
    );
  }
}
