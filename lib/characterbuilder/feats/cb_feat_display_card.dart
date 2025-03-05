import 'package:flutter/material.dart';
import 'package:card_game/universal/components/game_text.dart';

class FeatDisplayCard extends StatefulWidget {
  final Map<String, dynamic> feat;
  final bool isSelected;
  final bool isWishlisted;
  final Function(bool) onSelectedChanged;
  final Function(bool) onWishlistChanged;

  const FeatDisplayCard({
    super.key,
    required this.feat,
    required this.isSelected,
    required this.isWishlisted,
    required this.onSelectedChanged,
    required this.onWishlistChanged,
  });

  @override
  State<FeatDisplayCard> createState() => _FeatDisplayCardState();
}

class _FeatDisplayCardState extends State<FeatDisplayCard> {
  bool _isExpanded = false;

  Widget _buildTierPanel({
    required String title,
    required Color headerColor,
    required String mainEffect,
    Map<String, String>? aptitudeChanges,
  }) {
    if (mainEffect.isEmpty && (aptitudeChanges?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    // Extract Mana text if it exists
    final List<String> parts = mainEffect.split('\r\n\r\nMana:');
    final String effectText = parts[0];
    final String? manaText = parts.length > 1 ? parts[1].trim() : null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // Main Effect
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameText(text: effectText),
                if (manaText != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Mana',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: GameText(text: manaText)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Aptitude Changes
          if (aptitudeChanges != null) ...[
            for (final entry in aptitudeChanges.entries)
              if (entry.value.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Aptitude ${entry.key}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GameText(text: entry.value),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Selection controls
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (value) => widget.onSelectedChanged(value ?? false),
                    ),
                    const Text('Add to Character'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: widget.isWishlisted,
                      onChanged: (value) => widget.onWishlistChanged(value ?? false),
                    ),
                    const Text('Add to Wishlist'),
                  ],
                ),
              ],
            ),
          ),
          // Right side: Name and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.feat['name'] ?? 'Unknown Feat',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aptitude: ${widget.feat['associatedAptitude'] ?? "Unknown"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.feat['fluff'] != null && widget.feat['fluff'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Fluff: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          widget.feat['fluff'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.feat['crunch'] != null && widget.feat['crunch'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Crunch: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          widget.feat['crunch'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return Colors.red.shade700;
      case 'movement':
        return Colors.green.shade700;
      case 'special':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildTypeBanner() {
    final type = widget.feat['type'] as String? ?? 'Unknown';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: _getTypeColor(type),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTypeBanner(),  // Add type banner at the top
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Expanded(child: _buildHeader()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTierPanel(
                      title: 'Basic',
                      headerColor: Colors.red.shade700,
                      mainEffect: widget.feat['basicEffect'] ?? '',
                      aptitudeChanges: {
                        '4': widget.feat['basicApt4Change'] ?? '',
                        '8': widget.feat['basicApt8Change'] ?? '',
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTierPanel(
                      title: 'Tier 1',
                      headerColor: Colors.red.shade800,
                      mainEffect: widget.feat['tier1Effect'] ?? '',
                      aptitudeChanges: {
                        '4': widget.feat['tier1Apt4Change'] ?? '',
                        '8': widget.feat['tier1Apt8Change'] ?? '',
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTierPanel(
                      title: 'Tier 2',
                      headerColor: Colors.red.shade900,
                      mainEffect: widget.feat['tier2Effect'] ?? '',
                      aptitudeChanges: {
                        '4': widget.feat['tier2Apt4Change'] ?? '',
                        '8': widget.feat['tier2Apt8Change'] ?? '',
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}