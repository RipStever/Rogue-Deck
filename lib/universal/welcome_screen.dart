import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:card_game/newcontent/nc_screen.dart';
import 'package:card_game/characterbuilder/cb_screen.dart';
import 'package:card_game/gameplay/gameplay_screen.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/universal/character_deck_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

class WelcomeScreen extends ConsumerStatefulWidget {
  final String? initialSelectedCharacter;

  const WelcomeScreen({
    super.key, 
    this.initialSelectedCharacter,
  });

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<String> savedCharacters = [];
  String? _selectedCharacter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;
    
    await _loadSavedCharacters();
    
    if (!mounted) return;
    
    setState(() {
      // Only set the initial character if it exists in the loaded characters
      if (widget.initialSelectedCharacter != null &&
          savedCharacters.contains(widget.initialSelectedCharacter)) {
        _selectedCharacter = widget.initialSelectedCharacter;
      }
      _isLoading = false;
    });
  }

  void _openCharacterBuilder(Map<String, dynamic>? initialCharacterData) async {
    print("Opening Character Builder with data: $initialCharacterData");
    
    // Use an empty string or web-specific path instead of null for web mode
    final characterPath = kIsWeb ? 'web_characters' : '${_getDocumentsPath()}/Characters';
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterBuilderScreen(
          characterFilePath: characterPath,  // Now always providing a non-null String
          initialCharacterData: initialCharacterData,
          isWebMode: kIsWeb,
        ),
      ),
    );
    
    // If the result is true (character was saved or modified), reload the characters
    if (result == true) {
      setState(() => _selectedCharacter = null);  // Reset selection
      await _loadSavedCharacters();
    }
  }

  String _getDocumentsPath() {
    // This is only used in desktop mode
    return '${_getPlatformSpecificPath()}/Rogue Deck';
  }

  String _getPlatformSpecificPath() {
    // Simplified for this example - would need proper implementation for different platforms
    return '${Uri.base.path}/assets';
  }

  Future<void> _loadSavedCharacters() async {
    try {
      if (kIsWeb) {
        // In web mode, we'll load predefined characters from assets
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        
        // Filter for stock character files
        final characterPaths = manifestMap.keys
            .where((String key) => key.startsWith('assets/stock characters/') && key.endsWith('.json'))
            .toList();
        
        setState(() {
          // Extract character names from paths
          savedCharacters = characterPaths.map((path) {
            final filename = path.split('/').last;
            return filename.replaceAll('.json', '');
          }).toList();
        });
      } else {
        // Desktop implementation remains similar, but would need proper file system access
        // For demo purposes, we'll just use the same stock characters
        setState(() {
          savedCharacters = [
            'Tracer',
            'Road Hog',
            'Moira',
            'Ashe',
          ];
        });
      }
    } catch (e) {
      print('Error loading saved characters: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadCharacterData(String characterName) async {
    print("Loading character: $characterName");
    try {
      // Load character data from assets in web mode
      final jsonString = await rootBundle.loadString('assets/stock characters/$characterName.json');
      final characterData = json.decode(jsonString) as Map<String, dynamic>;
      print("Successfully loaded character JSON: $characterData");

      // Extract the deck name
      final deckName = characterData['deck'] as String;
      print('Loading deck: $deckName');

      // If the deck name is not "New Deck" (or empty), parse it
      if (deckName.isNotEmpty && deckName != 'New Deck') {
        final deckParser = CharacterDeckParser();
        final deckData = await deckParser.loadDeckData(deckName);

        // Convert int keys to strings, so that `fromJson` can parse them back to int
        final deckDataStringKeys = deckData.map((k, v) => MapEntry(k.toString(), v));
        characterData['deckData'] = deckDataStringKeys;

        print('Converted deck data: $deckDataStringKeys');
      } else {
        // If it's "New Deck", store an empty map (with string keys).
        characterData['deckData'] = <String,int>{};
        print('New Deck detected, skipping deck load');
      }

      return characterData;
    } catch (e, stackTrace) {
      print('Error loading character data: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rogue Deck',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[100],
                          ),
                        ),
                        const SizedBox(height: 40),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCharacter,
                            hint: const Text('Select a character'),
                            dropdownColor: Colors.grey[300],
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('New Character'),
                              ),
                              ...savedCharacters.map((name) {
                                return DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                );
                              }),
                            ],
                            onChanged: (name) {
                              if (!mounted) return;
                              setState(() {
                                _selectedCharacter = name;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildButton(
                                context: context,
                                icon: Icons.play_arrow,
                                label: 'Play Game',
                                onPressed: () async {
                                  if (_selectedCharacter == null) {
                                    _showErrorMessage('You must select a character to play the game.');
                                    return;
                                  }
                                  
                                  final characterData = await _loadCharacterData(_selectedCharacter!);
                                  if (characterData == null || characterData['deckData'] == null) {
                                    _showErrorMessage('Error loading character data (deckData null).');
                                    return;
                                  }

                                  if (characterData['deckData'] is! Map) {
                                    _showErrorMessage('Error loading character data (deckData not a map).');
                                    return;
                                  }

                                  try {
                                    // Create character model from the loaded data
                                    final characterModel = CharacterModel.fromJson(characterData);
                                    
                                    // Navigate to GameplayScreen with the character model
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GameplayScreen(
                                          characterModel: characterModel,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print('Error setting up game: $e');
                                    _showErrorMessage('Error starting game: ${e.toString()}');
                                  }
                                },
                                color: Colors.green[700]!,
                              ),
                              const SizedBox(height: 20),
                              _buildButton(
                                context: context,
                                icon: Icons.person,
                                label: 'Character Builder',
                                onPressed: () async {
                                  Map<String, dynamic>? characterData;
                                  if (_selectedCharacter != null) {
                                    print("Selected character: $_selectedCharacter");
                                    characterData = await _loadCharacterData(_selectedCharacter!);
                                    print("Loaded character data: $characterData");
                                  }
                                  _openCharacterBuilder(characterData);
                                },
                                color: Colors.orange[800]!,
                              ),
                              const SizedBox(height: 20),

                              _buildButton(
                                context: context,
                                icon: Icons.add_circle,
                                label: 'New Content',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NewContentScreen(),
                                  ),
                                ),
                                color: Colors.blue[700]!,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          'Version: Pre-Alpha (Web)',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    // ...existing code...
    return SizedBox(
      width: 300,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}