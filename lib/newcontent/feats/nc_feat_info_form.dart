// lib/newcontent/feats/components/feat_info_form.dart
import 'package:flutter/material.dart';

class FeatInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController levelController;
  final TextEditingController requirementController;
  final TextEditingController aptitudeController;
  final TextEditingController pillarController;
  final TextEditingController sourceController;
  final TextEditingController fluffController;
  final TextEditingController crunchController;
  final String selectedType;
  final bool continuousDevelopment;
  final Function(String) onTypeChanged;
  final Function(bool) onContinuousDevelopmentChanged;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onParseFromText;

  const FeatInfoForm({
    super.key,
    required this.nameController,
    required this.levelController,
    required this.requirementController,
    required this.aptitudeController,
    required this.pillarController,
    required this.sourceController,
    required this.fluffController,
    required this.crunchController,
    required this.selectedType,
    required this.continuousDevelopment,
    required this.onTypeChanged,
    required this.onContinuousDevelopmentChanged,
    required this.onSave,
    required this.onClear,
    required this.onDelete,
    required this.onParseFromText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feat Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),

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
            const SizedBox(height: 16),

            // Parse from Text button
            ElevatedButton.icon(
              onPressed: onParseFromText,
              icon: const Icon(Icons.paste),
              label: const Text('Parse from Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),

            // Form fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Feat Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Attack', child: Text('Attack')),
                DropdownMenuItem(value: 'Movement', child: Text('Movement')),
                DropdownMenuItem(value: 'Special', child: Text('Special')),
              ],
              onChanged: (value) {
                if (value != null) onTypeChanged(value);
              },
            ),
            const SizedBox(height: 8),

            TextField(
              controller: levelController,
              decoration: const InputDecoration(
                labelText: 'Level',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            TextField(
              controller: requirementController,
              decoration: const InputDecoration(
                labelText: 'Requirement',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: aptitudeController,
              decoration: const InputDecoration(
                labelText: 'Associated Aptitude',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: pillarController,
              decoration: const InputDecoration(
                labelText: 'Pillar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: 'Source Book',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: fluffController,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Fluff',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: crunchController,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Crunch',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            CheckboxListTile(
              title: const Text('Continuous Development'),
              value: continuousDevelopment,
              onChanged: (value) {
                if (value != null) onContinuousDevelopmentChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
