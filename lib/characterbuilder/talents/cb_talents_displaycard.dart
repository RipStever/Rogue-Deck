import 'package:flutter/material.dart';

class TalentDisplayCard extends StatefulWidget {
  final Map<String, dynamic> talent;
  final bool isSelected;
  final bool isWishlisted;
  final Function(bool) onSelectedChanged;
  final Function(bool) onWishlistChanged;

  const TalentDisplayCard({
    super.key,
    required this.talent,
    required this.isSelected,
    required this.isWishlisted,
    required this.onSelectedChanged,
    required this.onWishlistChanged,
  });

  @override
  State<TalentDisplayCard> createState() => _TalentDisplayCardState();
}

class _TalentDisplayCardState extends State<TalentDisplayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final talentName = widget.talent['name'] ?? 'Unknown Talent';
    final requirement = widget.talent['requirement'] ?? '';
    final pillar = widget.talent['pillar'] ?? '';
    final source = widget.talent['source'] ?? '';
    final effectText = widget.talent['effect'] ?? 'No effect text.';
    debugPrint('Displaying Talent: $talentName, Effect: $effectText');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with short info
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talentName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (requirement.isNotEmpty)
                          Text('Requirement: $requirement'),
                        if (pillar.isNotEmpty)
                          Text('Pillar: $pillar'),
                        if (source.isNotEmpty)
                          Text('Source: $source'),
                      ],
                    ),
                  ),
                ),
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

          // Selection row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (value) => widget.onSelectedChanged(value ?? false),
                ),
                const Text('Add to Character'),
                const SizedBox(width: 16),
                Checkbox(
                  value: widget.isWishlisted,
                  onChanged: (value) => widget.onWishlistChanged(value ?? false),
                ),
                const Text('Add to Wishlist'),
              ],
            ),
          ),

          // Expanded details
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Text(effectText),
            ),
        ],
      ),
    );
  }
}
