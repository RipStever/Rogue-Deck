// lib/gameplay/charactersection/stat_display_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatDisplay extends StatefulWidget {
  final String title;
  final int value;
  final int maxValue;
  final int? overhealth;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onReset;
  final Function(int)? onCustomValueChange;
  final Color? color;
  final bool showBar;
  final bool allowCustomInput;
  final String? customValueDisplay;
  final Function(int)? onOverhealthChange;
  final int armor; 

  const StatDisplay({
    super.key,
    required this.title,
    required this.value,
    required this.maxValue,
    this.overhealth,
    required this.onIncrement,
    required this.onDecrement,
    this.onReset,
    this.onCustomValueChange,
    this.color,
    this.showBar = true,
    this.allowCustomInput = false,
    this.customValueDisplay,
    this.onOverhealthChange,
    this.armor = 0,
  });

  @override
  _StatDisplayState createState() => _StatDisplayState();
}

class _StatDisplayState extends State<StatDisplay> {
  final TextEditingController _damageController = TextEditingController();
  final TextEditingController _healController = TextEditingController();
  final TextEditingController _overhealthController = TextEditingController();

  @override
  void dispose() {
    _damageController.dispose();
    _healController.dispose();
    _overhealthController.dispose();
    super.dispose();
  }

  void _applyHealthChange() {
    if (widget.onCustomValueChange == null) return;

    final damageValue = int.tryParse(_damageController.text) ?? 0;
    final healValue = int.tryParse(_healController.text) ?? 0;
    final overhealthValue = int.tryParse(_overhealthController.text) ?? 0;

    if (damageValue > 0 || healValue > 0 || overhealthValue > 0) {
      if (overhealthValue > 0) {
        widget.onOverhealthChange?.call(overhealthValue);
      } else if (damageValue > 0) {
        widget.onCustomValueChange!(-damageValue);
      } else if (healValue > 0) {
        widget.onCustomValueChange!(healValue);
      }

      // Clear all controllers
      _damageController.clear();
      _healController.clear();
      _overhealthController.clear();
    }
  }

  Color _getButtonColor() {
    final damageValue = int.tryParse(_damageController.text) ?? 0;
    final healValue = int.tryParse(_healController.text) ?? 0;
    final overhealthValue = int.tryParse(_overhealthController.text) ?? 0;

    if (overhealthValue > 0) return Colors.purple;
    if (damageValue > healValue) return Colors.red;
    if (healValue > damageValue) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Colors.blue[700]!;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In stat_display_widget.dart, modify the Row inside build method:

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      widget.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    Row(
      children: [
        // If this is HP and armor is active, show shield icon
        if (widget.title == 'Hit Points' && widget.armor > 0) ...[
          Icon(
            Icons.shield,
            size: 16,
            color: Colors.blue[400],
          ),
          const SizedBox(width: 4),
        ],
        Text(
          widget.customValueDisplay ?? (
            widget.maxValue > 0 
              ? '${widget.value}/${widget.maxValue}' 
              : widget.value.toString()
          ),
          style: TextStyle(
            color: effectiveColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.overhealth != null && widget.overhealth! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'OH: ${widget.overhealth}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    ),
  ],
),
          if (widget.showBar && widget.maxValue > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0,
                  end: widget.value / widget.maxValue,
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  minHeight: 6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (widget.title != 'Hit Points')
            Row(
              children: [
                _buildControlButton(
                  icon: Icons.remove,
                  onPressed: widget.value > 0 ? widget.onDecrement : null,
                  color: effectiveColor,
                ),
                const SizedBox(width: 4),
                _buildControlButton(
                  icon: Icons.add,
                  onPressed: widget.maxValue == 0 || widget.value < widget.maxValue 
                    ? widget.onIncrement 
                    : null,
                  color: effectiveColor,
                ),
                if (widget.onReset != null) ...[
                  const SizedBox(width: 4),
                  _buildControlButton(
                    icon: Icons.close,
                    onPressed: widget.onReset,
                    color: Colors.red[700]!,
                  ),
                ],
              ],
            ),
          if (widget.allowCustomInput) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _damageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Damage',
                      prefixIcon: Icon(Icons.health_and_safety, color: Colors.red[400]),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _applyHealthChange(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _healController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Heal',
                      prefixIcon: Icon(Icons.healing, color: Colors.green[400]),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _applyHealthChange(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _overhealthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Overhealth',
                      prefixIcon: Icon(Icons.shield, color: Colors.purple[400]),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _applyHealthChange(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyHealthChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final isEnabled = onPressed != null;
    
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.2) : Colors.grey[800],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnabled ? color : Colors.grey[600]!,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: isEnabled ? color : Colors.grey[600],
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}