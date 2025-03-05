import 'dart:io';
import 'package:flutter/material.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/deckbuilder/deckbuilder_widget.dart';
import 'package:card_game/characterbuilder/levelchart/levelchartwidget.dart';
import 'package:card_game/characterbuilder/feats/cb_feat_widget.dart';
import 'package:card_game/characterbuilder/herocards/herocards_widget.dart';
import 'package:card_game/characterbuilder/weapons/cb_WeaponsWidget.dart';
import 'package:card_game/characterbuilder/talents/cb_talents_widget.dart';

// Navigation item model for type safety
class RibbonNavItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Widget Function() buildWidget;

  const RibbonNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.buildWidget,
  });
}

class CharacterBuilderRibbon extends StatefulWidget {
  final void Function(Widget) setActiveWidget;
  final TextEditingController characterNameController;
  final TextEditingController playerNameController;
  final Future<void> Function() onSaveCharacter;
  final Future<void> Function() onDeleteCharacter;
  final List<File> savedDecks;
  final String? selectedDeckPath;
  final CharacterModel characterModel;
  final Function(String?) onDeckSelected;
  final Future<void> Function() reloadSavedDecks;
  final Function(CharacterModel) onCharacterUpdate;

  const CharacterBuilderRibbon({
    super.key,
    required this.setActiveWidget,
    required this.characterNameController,
    required this.playerNameController,
    required this.onSaveCharacter,
    required this.onDeleteCharacter,
    required this.savedDecks,
    required this.selectedDeckPath,
    required this.characterModel,
    required this.onDeckSelected,
    required this.reloadSavedDecks,
    required this.onCharacterUpdate,
  });

  @override
  State<CharacterBuilderRibbon> createState() => _CharacterBuilderRibbonState();
}

class _CharacterBuilderRibbonState extends State<CharacterBuilderRibbon> {
  List<RibbonNavItem> get _navigationItems => [
    RibbonNavItem(
      icon: Icons.bookmarks,
      label: 'Deck',
      color: const Color.fromARGB(255, 22, 158, 117),
      textColor: Colors.white,
      buildWidget: () => DeckBuilderWidget(
        initialDeckPath: widget.selectedDeckPath,
        onDeckChanged: widget.onDeckSelected,
        characterModel: widget.characterModel,
      ),
    ),
    RibbonNavItem(
      icon: Icons.style,
      label: 'Hero Cards',
      color: Colors.indigo,
      textColor: Colors.white,
      buildWidget: () => HeroCardsWidget(
        characterModel: widget.characterModel,
      ),
    ),
    RibbonNavItem(
      icon: Icons.dashboard,
      label: 'Level Chart',
      color: Colors.blue,
      textColor: Colors.white,
      buildWidget: () => const LevelChartWidget(),
    ),
    RibbonNavItem(
      icon: Icons.stars,
      label: 'Feats',
      color: Colors.purple,
      textColor: Colors.white,
      buildWidget: () => CB_FeatsWidget(
        characterModel: widget.characterModel,
        onCharacterUpdate: widget.onCharacterUpdate,
      ),
    ),
    RibbonNavItem(
      icon: Icons.security,
      label: 'Weapons',
      color: Colors.brown,
      textColor: Colors.white,
      buildWidget: () => CB_WeaponsWidget(
        characterModel: widget.characterModel,
        onCharacterUpdate: widget.onCharacterUpdate,
        onWeaponsChanged: (weapons) {
          final updatedCharacter = widget.characterModel.copyWith(selectedWeapons: weapons);
          widget.onCharacterUpdate(updatedCharacter);
        },
      ),
    ),
    RibbonNavItem(
      icon: Icons.lightbulb,
      label: 'Talents',
      color: Colors.orange,
      textColor: Colors.white,
      buildWidget: () => CB_TalentsWidget(
        characterModel: widget.characterModel,
        onCharacterUpdate: widget.onCharacterUpdate,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Container(
            color: const Color.fromARGB(255, 197, 197, 197),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(context),
                const SizedBox(height: 10),
                _buildCharacterInfo(),
                const Divider(),
                ..._buildNavButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildSaveButton(context),
        const SizedBox(width: 10),
        _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save),
      label: const Text('Save Character'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      onPressed: () => _handleSave(context),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.delete),
      label: const Text('Delete'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
      ),
      onPressed: () => _handleDelete(context),
    );
  }

  Widget _buildCharacterInfo() {
    return Column(
      children: [
        _buildTextField(
          controller: widget.characterNameController,
          icon: Icons.person,
          label: 'Character Name',
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: widget.playerNameController,
          icon: Icons.person_outline,
          label: 'Player Name',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      subtitle: TextField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }

  List<Widget> _buildNavButtons() {
    return _navigationItems.map((item) => _buildNavButton(item)).toList();
  }

  Widget _buildNavButton(RibbonNavItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: item.color,
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.textColor,
          semanticLabel: 'Navigate to ${item.label}',
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: item.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => widget.setActiveWidget(item.buildWidget()),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    try {
      await widget.onSaveCharacter();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Character saved!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save character: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    try {
      await widget.onDeleteCharacter();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Character deleted.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete character: $e')),
        );
      }
    }
  }
}