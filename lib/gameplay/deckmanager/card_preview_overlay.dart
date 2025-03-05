// lib/gameplay/deckmanager/card_preview_overlay.dart
import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';

class CardPreviewOverlay extends StatelessWidget {
  final CardData card;
  final Offset position;

  const CardPreviewOverlay({
    super.key,
    required this.card,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    const previewWidth = 220.0;
    const previewHeight = 308.0; // Using 2.5:3.5 ratio

    return Positioned(
      left: position.dx + 20,
      top: position.dy - 120,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: previewWidth,
          height: previewHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    card.effect,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}