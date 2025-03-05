import 'package:flutter/material.dart';
import 'package:card_game/newcontent/talents/nc_talent_service.dart';

class TalentDetailsColumn extends StatefulWidget {
  final String selectedTalentName;
  final VoidCallback onTalentListRefresh;

  const TalentDetailsColumn({
    super.key,
    required this.selectedTalentName,
    required this.onTalentListRefresh,
  });

  @override
  State<TalentDetailsColumn> createState() => _TalentDetailsColumnState();
}

class _TalentDetailsColumnState extends State<TalentDetailsColumn> {
  bool _hasUnsavedChanges = false;
  bool _continuousDevelopment = false;

  // Controllers for Talent Fields
  final _nameController = TextEditingController();
  final _requirementController = TextEditingController();
  final _pillarController = TextEditingController();
  final _levelController = TextEditingController();
  final _effectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupChangeListeners();
  }

  @override
  void didUpdateWidget(TalentDetailsColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTalentName != oldWidget.selectedTalentName) {
      _loadTalentDetails();
    }
  }

  void _setupChangeListeners() {
    void markChanged() {
      setState(() => _hasUnsavedChanges = true);
    }

    for (var controller in [
      _nameController,
      _requirementController,
      _pillarController,
      _levelController,
      _effectController,
    ]) {
      controller.addListener(markChanged);
    }
  }

  Future<void> _loadTalentDetails() async {
    if (widget.selectedTalentName.isEmpty) {
      _clearFields();
      return;
    }

    try {
      final talents = await TalentService.loadTalents();
      final talent = talents.firstWhere(
        (t) => t['name'] == widget.selectedTalentName,
        orElse: () => {},
      );

      if (talent.isNotEmpty) {
        setState(() {
          _nameController.text = talent['name'] ?? '';
          _requirementController.text = talent['requirement'] ?? '';
          _pillarController.text = talent['pillar'] ?? '';
          _levelController.text = talent['level']?.toString() ?? '';
          _effectController.text = talent['effect'] ?? '';
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      print('Error loading talent details: $e');
    }
  }

  void _clearFields() {
    _nameController.clear();
    _requirementController.clear();
    _pillarController.clear();
    _levelController.clear();
    _effectController.clear();
    setState(() => _hasUnsavedChanges = false);
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty || _effectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required fields (Name, Effect).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final newTalent = {
        'category': 'talent',
        'name': _nameController.text.trim(),
        'requirement': _requirementController.text.trim(),
        'pillar': _pillarController.text.trim(),
        'level': int.tryParse(_levelController.text.trim()) ?? 0,
        'effect': _effectController.text.trim(),
      };

      final allTalents = await TalentService.loadTalents();
      allTalents.removeWhere((talent) => talent['name'] == _nameController.text.trim());
      allTalents.add(newTalent);

      await TalentService.saveTalents(allTalents);
      widget.onTalentListRefresh();

      setState(() => _hasUnsavedChanges = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talent saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form if Continuous Development is not checked
      if (!_continuousDevelopment) {
        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving talent: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a talent to delete.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this talent? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TalentService.deleteTalent(_nameController.text.trim());
        widget.onTalentListRefresh();
        _clearFields();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talent deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting talent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Header
          const Text(
            'Manage/Add Talents',
            style: TextStyle(
              fontSize: 16, // Adjust the font size as needed
              fontWeight: FontWeight.bold, // Makes the font bold
            ),
          ),
                   
          
          // Name Field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // requirement Field
          TextField(
            controller: _requirementController,
            decoration: const InputDecoration(
              labelText: 'Requirement',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // Pillar Field
          TextField(
            controller: _pillarController,
            decoration: const InputDecoration(
              labelText: 'Pillar',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // Level Field
          TextField(
            controller: _levelController,
            decoration: const InputDecoration(
              labelText: 'Level',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),

          // Effect Field
          TextField(
            controller: _effectController,
            decoration: const InputDecoration(
              labelText: 'Effect',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            minLines: 3,
          ),
          const SizedBox(height: 16),

          // Continuous Development Checkbox
          SizedBox(
            width: 200, // Adjusted width
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Continuous Development'),
              value: _continuousDevelopment,
              onChanged: (value) {
                setState(() {
                  _continuousDevelopment = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Vertically Stacked Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _clearFields,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
