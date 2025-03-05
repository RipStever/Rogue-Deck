// lib/gameplay/deckmanager/deck_area_widget.dart
import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';
import 'deck_area_decksizes.dart';

enum DeckType {
  chance,
  chanceDiscard,
  action,
  actionDiscard,
  sideboard, // Add sideboard type
}

class DeckAreaWidget extends StatefulWidget {
  final String title;
  final int count;
  final CardData? topCard;
  final VoidCallback onTap;
  final DeckType deckType;
  final Color? customColor; // Add support for custom color
  
  const DeckAreaWidget({
    super.key,
    required this.title,
    required this.count,
    this.topCard,
    required this.onTap,
    required this.deckType,
    this.customColor, // New optional parameter
  });

  @override
  State<DeckAreaWidget> createState() => _DeckAreaWidgetState();
}

class _DeckAreaWidgetState extends State<DeckAreaWidget> {
  bool isHovered = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final style = DeckAreaSizes.getStyleForDeck(widget.deckType);

    // Determine the color based on deck type or custom color
    Color deckColor;
    IconData deckIcon;
    
    switch (widget.deckType) {
      case DeckType.action:
        deckColor = Colors.blue;
        deckIcon = Icons.bolt;
        break;
      case DeckType.chance:
        deckColor = Colors.red;
        deckIcon = Icons.auto_awesome;
        break;
      case DeckType.actionDiscard:
        deckColor = Colors.blue.withOpacity(0.6);
        deckIcon = Icons.restore_from_trash;
        break;
      case DeckType.chanceDiscard:
        deckColor = Colors.red.withOpacity(0.6);
        deckIcon = Icons.restore_from_trash;
        break;
      case DeckType.sideboard:
        deckColor = widget.customColor ?? Colors.deepPurple; 
        deckIcon = Icons.auto_awesome; // Changed from business_center to auto_awesome
        break;
    }

    return MouseRegion(
      onEnter: (event) {
        setState(() => isHovered = true);
        if (widget.topCard != null) {
        }
      },
      onExit: (event) {
        setState(() => isHovered = false);
        _removeOverlay();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: style.width,
          height: style.height, // Keep height constant
          transform: Matrix4.identity()
            ..translate(
              0.0,
              isHovered ? -5.0 : 0.0, // Still applies vertical translation
              0.0,
            ),
          // Use custom decoration for sideboard type
          decoration: widget.deckType == DeckType.sideboard 
            ? _getSideboardDecoration(isHovered)
            : DeckAreaSizes.getDecoration(widget.deckType, isHovered: isHovered),
          child: Stack(
            children: [
              // Add background pattern for sideboard type
              if (widget.deckType == DeckType.sideboard)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      deckIcon,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: DeckAreaSizes.getTitleStyle(widget.deckType, isHovered: isHovered),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: DeckAreaSizes.getCardCountDecoration(),
                      child: Text(
                        '${widget.count} cards',
                        style: DeckAreaSizes.getCardCountStyle(widget.deckType),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Custom decoration for sideboard to match the sideboard widget style
  BoxDecoration _getSideboardDecoration(bool isHovered) {
    return BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.purple,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(isHovered ? 0.6 : 0.4),
          blurRadius: isHovered ? 12 : 8,
          spreadRadius: isHovered ? 2 : 1,
        ),
      ],
    );
  }
}