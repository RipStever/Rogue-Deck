import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/universal/models/action_card_data.dart';


import 'package:card_game/characterbuilder/deckbuilder/deckbuilder_card_grid.dart';
import 'package:card_game/characterbuilder/deckbuilder/services/deckbuilder_file_service.dart';
import 'package:card_game/characterbuilder/deckbuilder/models/deckbuilder_state.dart';
import 'package:card_game/characterbuilder/deckbuilder/widgets/deckbuilder_management_panel.dart';
import 'package:card_game/characterbuilder/deckbuilder/widgets/deckbuilder_statistics_panel.dart';

class DeckBuilderWidget extends StatefulWidget {
  final String? initialDeckPath;
  final Function(String?) onDeckChanged;
  final CharacterModel characterModel;

  const DeckBuilderWidget({
    super.key,
    this.initialDeckPath,
    required this.onDeckChanged,
    required this.characterModel,
  });

  @override
  _DeckBuilderWidgetState createState() => _DeckBuilderWidgetState();
}

class _DeckBuilderWidgetState extends State<DeckBuilderWidget> {
  late final DeckBuilderFileService _fileService;
  late DeckBuilderState _deckState;
  List<CardData> availableCards = [];
  List<File> savedDecks = [];
  int? hoveredIndex;

  String get _baseDirectory {
    final userProfile = Platform.environment['USERPROFILE'];
    return path.join(userProfile ?? '', 'OneDrive', 'Documents', 'Rogue Deck', 'Decks');
  }

  @override
  void initState() {
    super.initState();
    _fileService = DeckBuilderFileService(baseDirectory: _baseDirectory);
    _deckState = DeckBuilderState(
      selectedDeckPath: widget.initialDeckPath,
    );
    
    // Delay initialization to avoid dropdown flash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    await _loadDeckbuilderJson();
    await _loadSavedDecks();
    if (widget.initialDeckPath != null) {
      await _loadSelectedDeck();
    }
  }

  Future<void> _loadDeckbuilderJson() async {
    final cards = await _fileService.loadDeckbuilderJson(context);
    if (cards != null) {
      setState(() {
        availableCards = cards;
      });
    }
  }

  Future<void> _loadSavedDecks() async {
    final decks = await _fileService.loadSavedDecks();
    setState(() {
      savedDecks = decks;
      // Validate current selection
      if (_deckState.selectedDeckPath != null && 
          !decks.any((deck) => deck.path == _deckState.selectedDeckPath)) {
        _deckState.clearDeck();
      }
    });
  }

  Future<void> _loadSelectedDeck() async {
    if (_deckState.selectedDeckPath != null) {
      final deckData = await _fileService.loadDeck(_deckState.selectedDeckPath!);
      if (deckData != null) {
        setState(() {
          _deckState.cardQuantities = {};
          final cardsList = deckData['cards'] as List;
          for (var cardData in cardsList) {
            _deckState.cardQuantities[cardData['id'] as int] = cardData['qty'] as int;
          }
          _deckState.selectedDeckName = deckData['deckName'] as String;
        });
      }
    }
  }

  Future<void> _showNewDeckDialog() async {
    final TextEditingController nameController = TextEditingController();
    if (widget.characterModel.name.isNotEmpty) {
      nameController.text = "${widget.characterModel.name}'s Deck";
    }

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),  // Remove default title padding
          title: Container(
            padding: const EdgeInsets.only(left: 24, right: 8), // Match default AlertDialog padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Name Your Deck'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          content: StatefulBuilder( // Use StatefulBuilder to manage local state
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Deck Name',
                      hintText: 'Enter deck name',
                    ),
                    autofocus: true, // Automatically focus the text field
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final deckName = nameController.text.trim();
                            if (deckName.isEmpty || deckName == "New Deck") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please provide a valid deck name (cannot be "New Deck")'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return; // Don't close the dialog
                            }
                            Navigator.pop(context);
                            await _createNewDeck(deckName, true);
                          },
                          child: const Text('Start from Default Deck'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final deckName = nameController.text.trim();
                            if (deckName.isEmpty || deckName == "New Deck") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please provide a valid deck name (cannot be "New Deck")'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return; // Don't close the dialog
                            }
                            Navigator.pop(context);
                            await _createNewDeck(deckName, false);
                          },
                          child: const Text('Start from Scratch'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _createNewDeck(String deckName, bool useDefaultDeck) async {
    if (deckName.trim().isEmpty || deckName == "New Deck") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid deck name (cannot be "New Deck")')),
      );
      return;
    }

    Map<int, int> newDeck = {};
    if (useDefaultDeck) {
      final defaultDeckData = await _fileService.loadDefaultDeck(context);
      if (defaultDeckData != null) {
        final cardsList = defaultDeckData['cards'] as List;
        for (var cardData in cardsList) {
          newDeck[cardData['id'] as int] = cardData['qty'] as int;
        }
      }
    }

    final deckData = {
      'deckName': deckName,
      'cards': newDeck.entries.map((entry) {
        final card = availableCards.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => throw Exception('Card not found with id: ${entry.key}'),
        );
        return {
          'id': entry.key,
          'name': card.name,
          'qty': entry.value,
        };
      }).toList(),
    };

    final newDeckPath = path.join(_baseDirectory, '$deckName.json').replaceAll('\\', '/');
    
    if (await _fileService.saveDeck(deckName, deckData)) {
      await _loadSavedDecks();
      
      setState(() {
        _deckState = DeckBuilderState(
          cardQuantities: newDeck,
          selectedDeckName: deckName,
          selectedDeckPath: newDeckPath,
        );
      });

      // Force the dropdown to update by explicitly selecting the new deck
      _onDeckSelected(newDeckPath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create deck')),
      );
    }
  }

  Future<void> _showEditNameDialog() async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = _deckState.selectedDeckName;

    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Deck Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Name',
              hintText: 'Enter new deck name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nameController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await _renameDeck(newName);
    }
  }

  Future<void> _renameDeck(String newName) async {
    if (_deckState.selectedDeckPath != null &&
        await _fileService.renameDeck(_deckState.selectedDeckPath!, newName)) {
      await _loadSavedDecks();
      setState(() {
        _deckState.selectedDeckName = newName;
        _deckState.selectedDeckPath = '$_baseDirectory/$newName.json';
      });
      widget.onDeckChanged(_deckState.selectedDeckPath);
    }
  }

  Future<void> _duplicateDeck() async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = '${_deckState.selectedDeckName} Copy';

    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Name Duplicate Deck'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Name',
              hintText: 'Enter name for duplicate deck',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nameController.text),
              child: const Text('Create Duplicate'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.trim().isNotEmpty && _deckState.selectedDeckPath != null) {
      final newPath = await _fileService.duplicateDeck(_deckState.selectedDeckPath!, newName);
      if (newPath != null) {
        await _loadSavedDecks();
        setState(() {
          _deckState.selectedDeckName = newName;
          _deckState.selectedDeckPath = newPath;
        });
        widget.onDeckChanged(newPath);
      }
    }
  }

  Future<void> _deleteDeck() async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${_deckState.selectedDeckName}"?\nThis cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete && _deckState.selectedDeckPath != null) {
      if (await _fileService.deleteDeck(_deckState.selectedDeckPath!)) {
        await _loadSavedDecks();
        setState(() {
          _deckState.clearDeck();
        });
        widget.onDeckChanged(null);
      }
    }
  }

  void _onDeckSelected(String? value) {
    debugPrint('Deck selected: $value'); // Debug print
    
    // Normalize paths to handle any potential path separator issues
    final normalizedValue = value?.replaceAll('\\', '/');
    
    setState(() {
      if (normalizedValue == null) {
        _deckState.clearDeck();
      } else {
        _deckState.selectedDeckPath = normalizedValue;
        _loadSelectedDeck();
      }
    });
    
    // Make sure we also notify the parent widget
    widget.onDeckChanged(normalizedValue);
    
    // Debug prints to verify state
    debugPrint('Updated state - selectedDeckPath: ${_deckState.selectedDeckPath}');
    debugPrint('Current deck state - selectedDeckName: ${_deckState.selectedDeckName}');
  }

  void _updateCardQuantity(int cardId, bool increment) {
    setState(() {
      if (increment) {
        _deckState.incrementCard(cardId);
      } else {
        _deckState.decrementCard(cardId);
      }
    });
  }

  Future<void> _saveDeck() async {
    if (_deckState.selectedDeckPath != null) {
      final deckData = {
        'deckName': _deckState.selectedDeckName,
        'cards': _deckState.cardQuantities.entries.map((entry) => {
          'id': entry.key,
          'name': availableCards.firstWhere((c) => c.id == entry.key).name,
          'qty': entry.value,
        }).toList(),
      };

      if (await _fileService.saveDeck(_deckState.selectedDeckName, deckData)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deck saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save deck')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Control Zone
        Container(
          width: 250,
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          child: Column(
            children: [
              DeckBuilderManagementPanel(
                selectedDeckPath: _deckState.selectedDeckPath,
                selectedDeckName: _deckState.selectedDeckName,
                savedDecks: savedDecks,
                onDeckSelected: _onDeckSelected,
                onNewDeck: _showNewDeckDialog,
                onRenameDeck: (_) => _showEditNameDialog(),
                onDuplicateDeck: _duplicateDeck,
                onDeleteDeck: _deleteDeck,
                onSaveDeck: _saveDeck,
              ),
              const SizedBox(height: 20),
              DeckBuilderStatisticsPanel(
                deckState: _deckState,
                availableCards: availableCards,
                onClearDeck: () => setState(() => _deckState.clearDeck()),
                onSortOptionChanged: (value) => setState(() => _deckState.sortOption = value),
              ),
            ],
          ),
        ),
        
        // Card Grid
        Expanded(
          child: DeckBuilderCardGrid(
            availableCards: availableCards,
            deckState: _deckState,
            onCardQuantityChanged: _updateCardQuantity,
            hoveredIndex: hoveredIndex,
            onHoverChanged: (index) => setState(() => hoveredIndex = index),
          ),
        ),
      ],
    );
  }
}