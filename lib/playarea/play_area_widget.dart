import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../universal/models/action_card_data.dart';
import '../universal/models/chance_card_data.dart';

import '../playarea/card_widget.dart';
import '../playarea/chance_card_widget.dart';

class PlayAreaWidget extends StatefulWidget {
  final List<CardData> cards;
  final List<CardData> hand;
  final void Function(int? hoverIndex, CardData? cardData, Offset? position, Size? size)? onHoverChanged;

  const PlayAreaWidget({
    super.key,
    required this.cards,
    required this.hand,
    this.onHoverChanged,
  });

  @override
  _PlayAreaWidgetState createState() => _PlayAreaWidgetState();
}

class _PlayAreaWidgetState extends State<PlayAreaWidget> {
  int? hoveredIndex;
  final List<GlobalKey> cardKeys = [];

  @override
  void initState() {
    super.initState();
    cardKeys.addAll(List.generate(widget.cards.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant PlayAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.length != cardKeys.length) {
      cardKeys.clear();
      cardKeys.addAll(List.generate(widget.cards.length, (_) => GlobalKey()));
    }
  }

  Widget _buildCardDisplay(CardData card) {
    if (_isChanceCardType(card.type)) {
      return ChanceCardWidget(
        cardData: ChanceCardData.fromCardData(card),
        isHovered: false,
      );
    } else {
      return GameCard(
        cardData: card,
        isSelected: false,
        onTap: () {},
        isHovered: false,
      );
    }
  }

  bool _isChanceCardType(String type) {
    return type == 'Blunder' ||
        type == 'Miss' ||
        type == 'Partial Hit' ||
        type == 'Hit' ||
        type == 'Hit+' ||
        type == 'Crit';
  }

  void _handleHoverEnter(int index) {
    setState(() {
      hoveredIndex = index;
    });

    if (widget.onHoverChanged != null && hoveredIndex != null) {
      final box = cardKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);
        final size = box.size;
        widget.onHoverChanged!(hoveredIndex, widget.cards[hoveredIndex!], position, size);
      }
    }
  }

  void _handleHoverExit(int index) {
    setState(() {
      hoveredIndex = null;
    });
    widget.onHoverChanged?.call(null, null, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      color: Colors.black,
      strokeWidth: 2,
      dashPattern: const [6, 3],
      child: Container(
        width: 650,
        height: 180,
        alignment: Alignment.center,
        child: widget.cards.isEmpty
            ? const Text(
                'Play Area',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : Stack(
                clipBehavior: Clip.none,
                children: widget.cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  final isInHand = widget.hand.contains(card);

                  return AnimatedPositioned(
                    key: cardKeys[index],
                    duration: const Duration(milliseconds: 500),
                    left: isInHand ? 0.0 : index * 30.0,
                    top: isInHand ? 270.0 : 0.0,
                    child: MouseRegion(
                      onEnter: (_) => _handleHoverEnter(index),
                      onExit: (_) => _handleHoverExit(index),
                      child: _buildCardDisplay(card),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
