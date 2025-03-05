import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class DeckBuilderManagementPanel extends StatelessWidget {
  final String? selectedDeckPath;
  final String selectedDeckName;
  final List<File> savedDecks;
  final Function(String?) onDeckSelected;
  final Function() onNewDeck;
  final Function(String) onRenameDeck;
  final Function() onDuplicateDeck;
  final Function() onDeleteDeck;
  final Function() onSaveDeck;

  const DeckBuilderManagementPanel({
    super.key,
    required this.selectedDeckPath,
    required this.selectedDeckName,
    required this.savedDecks,
    required this.onDeckSelected,
    required this.onNewDeck,
    required this.onRenameDeck,
    required this.onDuplicateDeck,
    required this.onDeleteDeck,
    required this.onSaveDeck,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNewDeck = selectedDeckPath == null;

    // Normalize the selected path
    final normalizedSelectedPath = selectedDeckPath?.replaceAll('\\', '/');

    // Debug prints
    debugPrint('ManagementPanel - selectedDeckPath: $normalizedSelectedPath');
    debugPrint('Available decks:');
    for (var deck in savedDecks) {
      debugPrint('  ${deck.path.replaceAll('\\', '/')}');
    }

    // Validate that selectedDeckPath exists in savedDecks
    final validSelection = selectedDeckPath == null || 
        savedDecks.any((deck) => deck.path == selectedDeckPath);
    
    // If selection is invalid, use null
    final effectiveValue = validSelection ? selectedDeckPath : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deck Selection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Deck Selection Dropdown
            DropdownButtonFormField<String?>(
              isExpanded: true,
              value: normalizedSelectedPath,  // Use normalized path
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('New Deck'),
                ),
                ...savedDecks.map((deck) {
                  final normalizedPath = deck.path.replaceAll('\\', '/');
                  final deckName = path.basenameWithoutExtension(deck.path);
                  debugPrint('Creating item: $deckName with path: $normalizedPath');
                  return DropdownMenuItem<String>(
                    value: normalizedPath,
                    child: Text(deckName),
                  );
                }),
              ],
              onChanged: (value) {
                debugPrint('Dropdown selection changed to: $value');
                onDeckSelected(value);
              },
            ),
            
            const SizedBox(height: 8),
            
            // Action Buttons
            if (isNewDeck)
              ElevatedButton(
                onPressed: onNewDeck,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Create New Deck'),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => onRenameDeck(selectedDeckName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      minimumSize: const Size.fromHeight(36),
                    ),
                    child: const Text('Edit Name'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onSaveDeck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(36),
                    ),
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onDuplicateDeck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(36),
                    ),
                    child: const Text('Duplicate'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onDeleteDeck,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(36),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}