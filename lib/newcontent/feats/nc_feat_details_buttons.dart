// lib/newcontent/feats/components/feat_details_buttons.dart
import 'package:flutter/material.dart';

class FeatDetailsButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final bool hasUnsavedChanges;
  final bool continuousDevelopment;

  const FeatDetailsButtons({
    super.key,
    required this.onSave,
    required this.onClear,
    required this.onDelete,
    this.hasUnsavedChanges = false,
    this.continuousDevelopment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Save Button
        ElevatedButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save),
          label: Text(
            hasUnsavedChanges 
              ? 'Save Changes' 
              : (continuousDevelopment ? 'Save and Continue' : 'Save'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 8),

        // Clear Button
        ElevatedButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear Contents'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 8),

        // Delete Button
        ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}