// weapon_info_form 

import 'package:flutter/material.dart';

class WeaponInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController levelController;
  final TextEditingController requirementController;
  final TextEditingController aptitudeController;
  final TextEditingController pillarController;
  final TextEditingController sourceController;
  final TextEditingController fluffController;
  final TextEditingController crunchController;
  final TextEditingController weaponTypeController;
  final TextEditingController handednessController;
  final TextEditingController categoryController;
  final TextEditingController tagsController;
  final String selectedType;
  final bool continuousDevelopment;
  final Function(String) onTypeChanged;
  final Function(bool) onContinuousDevelopmentChanged;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onParseFromText;

  const WeaponInfoForm({
    super.key,
    required this.nameController,
    required this.levelController,
    required this.requirementController,
    required this.aptitudeController,
    required this.pillarController,
    required this.sourceController,
    required this.fluffController,
    required this.crunchController,
    required this.weaponTypeController,
    required this.handednessController,
    required this.categoryController,
    required this.tagsController,
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
              'Weapon Information',
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

            // Form fields with labels above
            const Text('Weapon Name'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Type'),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
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

            const Text('Level'),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            const Text('Requirement'),
            TextField(
              controller: requirementController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Associated Aptitude'),
            TextField(
              controller: aptitudeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Pillar'),
            TextField(
              controller: pillarController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Source Book'),
            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Weapon Type'),
            TextField(
              controller: weaponTypeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Handedness'),
            TextField(
              controller: handednessController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Category'),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Tags'),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Fluff'),
            TextField(
              controller: fluffController,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            const Text('Crunch'),
            TextField(
              controller: crunchController,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
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
