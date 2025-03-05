// lib/gameplay/cardzone/action_execution_actionwindow.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../universal/models/action_card_data.dart';
import '../../universal/models/hero_ability_card_model.dart';
import '../../universal/widgets/hero_ability_card_widget.dart';
import '../../universal/widgets/card_widget.dart';

class ActionWindow extends ConsumerStatefulWidget {
  final CardData actionCard;
  final HeroAbilityCardModel? heroAbility;
  final Function(CardData)? onActionSideboardSelect; // Keep this callback for now

  const ActionWindow({
    super.key,
    required this.actionCard,
    this.heroAbility,
    this.onActionSideboardSelect,
  });

  @override
  ConsumerState<ActionWindow> createState() => _ActionWindowState();
}

class _ActionWindowState extends ConsumerState<ActionWindow> {
  bool _isAbilityHovered = false;

  Widget _buildActionCardContainer() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Center(
            child: SizedBox(
              width: 220,
              height: 330,
              child: GameCard(
                cardData: widget.actionCard,
                isSelected: false,
                onTap: () {},
                isHovered: false,
                width: 220,
                height: 330,
              ),
            ),
          ),
        ),
        const Text(
          'Action Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAbilityCardContainer() {
    if (widget.heroAbility == null) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isAbilityHovered = true),
            onExit: (_) => setState(() => _isAbilityHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isAbilityHovered ? 300 : 220,
              height: _isAbilityHovered ? 450 : 330,
              child: HeroAbilityCard(
                ability: widget.heroAbility!,
                isHovered: _isAbilityHovered,
                preventFullDialog: true,
              ),
            ),
          ),
        ),
        const Text(
          'Selected Ability',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heroAbility != null) ...[
          Expanded(
            flex: 1,
            child: _buildAbilityCardContainer(),
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          flex: 1,
          child: _buildActionCardContainer(),
        ),
      ],
    );
  }
}