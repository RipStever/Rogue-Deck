// lib/gameplay/deckmanager/hover_card_preview.dart
import 'package:flutter/material.dart';
import 'package:card_game/universal/models/action_card_data.dart';

class HoverCardPreview extends StatefulWidget {
  final CardData card;
  final Offset position;
  final BuildContext parentContext;

  const HoverCardPreview({
    super.key,
    required this.card,
    required this.position,
    required this.parentContext,
  });

  @override
  State<HoverCardPreview> createState() => _HoverCardPreviewState();
}

class _HoverCardPreviewState extends State<HoverCardPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Offset _adjustedPosition;
  bool _isPositioned = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Delay the appearance slightly to prevent flicker
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPositioned) {
      _adjustedPosition = _calculatePosition(context);
      _isPositioned = true;
    }

    return Positioned(
      left: _adjustedPosition.dx,
      top: _adjustedPosition.dy,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildPreviewCard(),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            
            // Content Section
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEffectText(),
                    if (widget.card.effect.contains('Mana:'))
                      const SizedBox(height: 12),
                      _buildManaSection(),
                  ],
                ),
              ),
            ),

            // Footer Section
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getHeaderColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.card.type,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTypeIcon(),
        ],
      ),
    );
  }

  Widget _buildEffectText() {
    final effectText = widget.card.effect.split('\n\nMana:')[0];
    return Text(
      effectText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildManaSection() {
    final parts = widget.card.effect.split('\n\nMana:');
    if (parts.length < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                'Mana Effect',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            parts[1].trim(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            widget.card.category,
            style: TextStyle(
              color: _getCategoryColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: _getCategoryColor(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getTypeIcon(),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Offset _calculatePosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const previewWidth = 280.0;
    const previewHeight = 400.0;

    double dx = widget.position.dx + 20;
    double dy = widget.position.dy - 20;

    // Adjust horizontal position if too close to right edge
    if (dx + previewWidth > screenSize.width) {
      dx = widget.position.dx - previewWidth - 20;
    }

    // Adjust vertical position if too close to bottom edge
    if (dy + previewHeight > screenSize.height) {
      dy = screenSize.height - previewHeight - 20;
    }

    // Ensure preview stays within screen bounds
    dx = dx.clamp(10.0, screenSize.width - previewWidth - 10);
    dy = dy.clamp(10.0, screenSize.height - previewHeight - 10);

    return Offset(dx, dy);
  }

  Color _getHeaderColor() {
    switch (widget.card.type.toLowerCase()) {
      case 'attack':
        return Colors.red[900]!;
      case 'movement':
        return Colors.green[900]!;
      case 'special':
        return Colors.purple[900]!;
      default:
        return Colors.grey[800]!;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.card.type.toLowerCase()) {
      case 'attack':
        return Icons.sports_martial_arts;
      case 'movement':
        return Icons.directions_run;
      case 'special':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.card.category.toLowerCase()) {
      case 'common':
        return Icons.circle;
      case 'rare':
        return Icons.star;
      case 'legendary':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor() {
    switch (widget.card.category.toLowerCase()) {
      case 'common':
        return Colors.grey[400]!;
      case 'rare':
        return Colors.blue[400]!;
      case 'legendary':
        return Colors.purple[400]!;
      default:
        return Colors.white70;
    }
  }
}

// Usage example:
// OverlayEntry overlayEntry = OverlayEntry(
//   builder: (context) => HoverCardPreview(
//     card: cardData,
//     position: eventPosition,
//     parentContext: context,
//   ),
// );
// Overlay.of(context).insert(overlayEntry);