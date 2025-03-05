import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/cb_statswidget.dart';
import 'package:card_game/characterbuilder/cb_ribbon.dart';
import 'package:card_game/characterbuilder/cb_loadcharacter.dart';

class CharacterBuilderScreen extends ConsumerStatefulWidget {
  final String characterFilePath;
  final Map<String, dynamic>? initialCharacterData; // Add this parameter
  final bool isNewCharacter; // Add this parameter
  final bool isWebMode; // Add this field

  const CharacterBuilderScreen({
    super.key,
    required this.characterFilePath,
    this.initialCharacterData, // Add this parameter
    this.isNewCharacter = false, // Add this parameter with default value
    this.isWebMode = false, // Add with default value of false
  });

  @override
  ConsumerState<CharacterBuilderScreen> createState() => _CharacterBuilderScreenState();
}

class _CharacterBuilderScreenState extends ConsumerState<CharacterBuilderScreen> {
  bool _isLoading = true;
  Widget? _activeWidget;
  final TextEditingController _characterNameController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Remove _setupControllers from here since we'll do it after loading
    Future.microtask(() => _initializeCharacter());
  }

  Future<void> _initializeCharacter() async {
    if (widget.initialCharacterData != null) {
      try {
        final character = CharacterModel.fromJson(widget.initialCharacterData!);
        ref.read(characterProvider.notifier).updateCharacter(character);
        // Update controllers after loading character
        _characterNameController.text = character.name;
        _playerNameController.text = character.playerName ?? '';
      } catch (e) {
        if (!mounted) return;
        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading character: $e')),
          );
        });
      }
    }
    
    await ref.read(characterProvider.notifier).loadSavedData();
    
    if (mounted) {
      // Setup controllers after everything is loaded
      _setupControllers();
      setState(() => _isLoading = false);
    }
  }

  void _setupControllers() {
    final state = ref.read(characterProvider);
    
    // Set initial values
    _characterNameController.text = state.character.name;
    _playerNameController.text = state.character.playerName ?? '';

    // Add listeners
    _characterNameController.addListener(() {
      print('Character name changed to: ${_characterNameController.text}'); // Debug print
      _onCharacterNameChanged();
    });
    _playerNameController.addListener(() {
      print('Player name changed to: ${_playerNameController.text}'); // Debug print
      _onPlayerNameChanged();
    });
  }

  void _loadInitialData() {
    Future.microtask(() {
      ref.read(characterProvider.notifier).loadSavedData();
    });
  }

  void _onCharacterNameChanged() {
    final state = ref.read(characterProvider);
    final updatedCharacter = state.character.copyWith(
      name: _characterNameController.text,
    );
    ref.read(characterProvider.notifier).updateCharacter(updatedCharacter);
  }

  void _onPlayerNameChanged() {
    final state = ref.read(characterProvider);
    final updatedCharacter = state.character.copyWith(
      playerName: _playerNameController.text,
    );
    ref.read(characterProvider.notifier).updateCharacter(updatedCharacter);
  }

  void _onStatsChanged(String stat, int bonus) {
    final state = ref.read(characterProvider);
    final currentStats = Map<String, Map<String, int>>.from(state.character.stats ?? {});
    
    if (!currentStats.containsKey(stat)) {
      currentStats[stat] = {'base': 0, 'bonus': 0};
    }
    
    currentStats[stat]!['bonus'] = bonus;
    
    final updatedCharacter = state.character.copyWith(stats: currentStats);
    ref.read(characterProvider.notifier).updateCharacter(updatedCharacter);
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(characterProvider);
    if (!state.hasUnsavedChanges) {
      ref.read(characterProvider.notifier).resetState();
      return true;
    }

    final saveChanges = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Save changes before exiting?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(characterProvider.notifier).resetState();
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (saveChanges == true) {
      await ref.read(characterProvider.notifier).saveCharacter();
    }
    ref.read(characterProvider.notifier).resetState();
    return true;
  }

  Future<void> _handleSave(BuildContext context) async {
    final state = ref.read(characterProvider);
    print('Current character state before save:'); // Debug print
    print('Name: ${state.character.name}');
    print('Player Name: ${state.character.playerName}');
    print('Stats: ${state.character.stats}');
    
    try {
      if (state.character.name.trim().isEmpty) {
        throw Exception('Character name cannot be empty');
      }

      if (widget.isWebMode) {
        // Web implementation: Could save to localStorage or other web storage
        print('Saving in web mode - using local storage');
        // You'll need to implement web-specific storage
        
        // Example of notifying success even in web mode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Character saved (web mode)')),
        );
        
        Navigator.pop(context, true); // Return success
      } else {
        // Original file-based implementation
        await ref.read(characterProvider.notifier).saveCharacter();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Character saved!')),
          );
          ref.read(characterProvider.notifier).resetState();
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      print('Save error: $e'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save character: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteCharacter() async {
    final state = ref.read(characterProvider);
    if (state.character.name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a character name before deleting.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this character?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final characterName = state.character.name;
        // Reset the state before deletion to avoid dropdown issues
        ref.read(characterProvider.notifier).resetState();
        
        final repository = ref.read(characterRepositoryProvider);
        await repository.deleteCharacter(characterName);
        
        if (mounted) {
          // Pop the screen and return true to indicate deletion
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete character: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error messages if any
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Character Builder'),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ribbon Column
            Container(
              width: 300,
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                child: CharacterBuilderRibbon(
                  setActiveWidget: (widget) => setState(() => _activeWidget = widget),
                  characterNameController: _characterNameController,
                  playerNameController: _playerNameController,
                  onSaveCharacter: () => _handleSave(context),
                  onDeleteCharacter: _handleDeleteCharacter,
                  savedDecks: state.savedDecks,
                  selectedDeckPath: state.selectedDeckPath,
                  characterModel: state.character,
                  onDeckSelected: (path) => ref.read(characterProvider.notifier).updateDeckSelection(path),
                  reloadSavedDecks: () async {
                    await ref.read(characterProvider.notifier).loadSavedData();
                  },
                  onCharacterUpdate: (updatedCharacter) {
                    ref.read(characterProvider.notifier).updateCharacter(updatedCharacter);
                  },
                ),
              ),
            ),

            // Stats Column
            Container(
              width: 300,
              color: Colors.blueGrey.shade50,
              child: CharacterBuilderStatsWidget(
                characterModel: state.character,
                onBonusChanged: _onStatsChanged,
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                color: Colors.white,
                child: _activeWidget ?? (widget.isNewCharacter 
                  ? const _DefaultSubscreenContent() 
                  : CBLoadCharacter(characterFilePath: widget.characterFilePath)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ref.read(characterProvider.notifier).resetState();
    _characterNameController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }
}

// Default Subscreen Content Widget
class _DefaultSubscreenContent extends StatelessWidget {
  const _DefaultSubscreenContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Select an option from the menu to view content.',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Character Repository Interface
abstract class CharacterRepository {
  Future<void> saveCharacter(CharacterModel character);
  Future<CharacterModel> loadCharacter(String name);
  Future<void> deleteCharacter(String name);
  Future<List<String>> getSavedCharacters();
  Future<List<File>> getSavedDecks();
}

// File System Implementation
class FileSystemCharacterRepository implements CharacterRepository {
  final String baseDirectory;

  FileSystemCharacterRepository({String? customBaseDirectory}) 
    : baseDirectory = customBaseDirectory ?? _defaultBaseDirectory;

  static String get _defaultBaseDirectory {
    final userProfile = Platform.environment['USERPROFILE'];
    final dir = path.join(userProfile ?? '', 'OneDrive', 'Documents', 'Rogue Deck');
    print('Base directory: $dir'); // Add debug print
    return dir;
  }

  Future<Directory> _ensureDirectoryExists(String subdirectory) async {
    final dirPath = path.join(baseDirectory, subdirectory);
    final directory = Directory(dirPath);
    
    print('Ensuring directory exists: ${directory.path}'); // Add debug print
    
    if (!await directory.exists()) {
      try {
        await directory.create(recursive: true);
        print('Created directory: ${directory.path}'); // Add debug print
      } catch (e) {
        print('Failed to create directory: $e'); // Add debug print
        throw Exception('Failed to create directory: ${directory.path}');
      }
    }
    return directory;
  }

  @override
  Future<void> saveCharacter(CharacterModel character) async {
    if (character.name.trim().isEmpty) {
      throw Exception('Character name cannot be empty');
    }

    try {
      final directory = await _ensureDirectoryExists('Characters');
      final filePath = path.join(directory.path, '${character.name}.json');
      final file = File(filePath);
      
      print('Saving character to: ${file.path}'); // Add debug print
      
      // Convert character to JSON and save
      final jsonData = character.toJson();
      print('Character data to save: $jsonData'); // Add debug print
      
      await file.writeAsString(json.encode(jsonData));
      print('Save completed'); // Add debug print
    } catch (e, stackTrace) {
      print('Save error: $e'); // Add debug print
      print('Stack trace: $stackTrace'); // Add debug print
      throw Exception('Failed to save character: ${e.toString()}');
    }
  }

  @override
  Future<CharacterModel> loadCharacter(String name) async {
    try {
      final directory = await _ensureDirectoryExists('Characters');
      final file = File(path.join(directory.path, '$name.json'));
      
      if (!await file.exists()) {
        throw Exception('Character file not found: $name');
      }

      final jsonString = await file.readAsString();
      return CharacterModel.fromJson(json.decode(jsonString));
    } catch (e) {
      throw Exception('Failed to load character: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCharacter(String name) async {
    try {
      final directory = await _ensureDirectoryExists('Characters');
      final file = File(path.join(directory.path, '$name.json'));
      
      if (!await file.exists()) {
        throw Exception('Character not found: $name');
      }

      await file.delete();
    } catch (e) {
      throw Exception('Failed to delete character: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSavedCharacters() async {
    try {
      final directory = await _ensureDirectoryExists('Characters');
      final files = await directory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .map((file) => path.basenameWithoutExtension(file.path))
          .toList();
      return files;
    } catch (e) {
      throw Exception('Failed to get saved characters: ${e.toString()}');
    }
  }

  @override
  Future<List<File>> getSavedDecks() async {
    try {
      final directory = await _ensureDirectoryExists('Decks');
      final files = await directory
          .list()
          .where((entity) => entity is File)
          .map((file) => file as File)
          .toList();
      return files;
    } catch (e) {
      throw Exception('Failed to get saved decks: ${e.toString()}');
    }
  }
}

// Character Repository Provider
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return FileSystemCharacterRepository();
});

// Character State Notifier Provider
final characterProvider = StateNotifierProvider<CharacterNotifier, CharacterState>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return CharacterNotifier(repository);
});

// Character Model
final characterModelProvider = StateProvider<CharacterModel?>((ref) => null);

// Character State class
class CharacterState {
  final CharacterModel character;
  final List<File> savedDecks;
  final List<String> savedCharacters;
  final String? selectedDeckPath;
  final bool hasUnsavedChanges;
  final String? errorMessage;

  CharacterState({
    required this.character,
    this.savedDecks = const [],
    this.savedCharacters = const [],
    this.selectedDeckPath,
    this.hasUnsavedChanges = false,
    this.errorMessage,
  });

  CharacterState copyWith({
    CharacterModel? character,
    List<File>? savedDecks,
    List<String>? savedCharacters,
    String? selectedDeckPath,
    bool? hasUnsavedChanges,
    String? errorMessage,
  }) {
    return CharacterState(
      character: character ?? this.character,
      savedDecks: savedDecks ?? this.savedDecks,
      savedCharacters: savedCharacters ?? this.savedCharacters,
      selectedDeckPath: selectedDeckPath ?? this.selectedDeckPath,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      errorMessage: errorMessage,
    );
  }
}

// Character Notifier class
class CharacterNotifier extends StateNotifier<CharacterState> {
  final CharacterRepository _repository;
  Timer? _autoSaveDebouncer;  // Define the Timer variable

  CharacterNotifier(this._repository) : super(
    CharacterState(
      character: CharacterModel(
        name: '',
        playerName: '',
        selectedDeckName: 'New Deck',
        selectedLevel: 1,
        selectedClass: null,
        stats: {},
      ),
    )
  );

  Future<void> loadSavedData() async {
    try {
      final decks = await _repository.getSavedDecks();
      final characters = await _repository.getSavedCharacters();
      
      state = state.copyWith(
        savedDecks: decks,
        savedCharacters: characters,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load saved data: ${e.toString()}'
      );
    }
  }

  Future<void> saveCharacter() async {
    print('SaveCharacter called'); // Debug print
    print('Current character name: ${state.character.name}'); // Debug print
    
    if (state.character.name.trim().isEmpty) {
      print('Empty character name detected'); // Debug print
      state = state.copyWith(
        errorMessage: 'Character name cannot be empty'
      );
      return;
    }

    try {
      print('Attempting to save character: ${state.character.toJson()}'); // Debug print
      await _repository.saveCharacter(state.character);
      
      state = state.copyWith(
        hasUnsavedChanges: false,
        errorMessage: null,
      );
      print('Character saved successfully'); // Debug print
    } catch (e, stackTrace) {
      print('Save error: $e'); // Debug print
      print('Stack trace: $stackTrace'); // Debug print
      state = state.copyWith(
        errorMessage: 'Failed to save character: ${e.toString()}'
      );
    }
  }

  void updateCharacter(CharacterModel newCharacter) {
    state = state.copyWith(
      character: newCharacter,
      hasUnsavedChanges: true,
      errorMessage: null,
    );
    
    // Add autosave with debounce
    _autoSaveDebouncer?.cancel();
    _autoSaveDebouncer = Timer(const Duration(seconds: 2), () {
      saveCharacter();
    });
  }

  @override
  void dispose() {
    _autoSaveDebouncer?.cancel();
    super.dispose();
  }

  void updateDeckSelection(String? deckPath) {
    final deckName = deckPath == null
        ? 'New Deck'
        : path.basenameWithoutExtension(deckPath);

    final updatedCharacter = state.character.copyWith(
      selectedDeckName: deckName,
    );

    state = state.copyWith(
      character: updatedCharacter,
      selectedDeckPath: deckPath,
      hasUnsavedChanges: true,
      errorMessage: null,
    );
  }

  void resetState() {
    state = CharacterState(
      character: CharacterModel(
        name: '',
        playerName: '',
        selectedDeckName: 'New Deck',
        selectedLevel: 1,
        selectedClass: null,
        stats: {},
      ),
      savedDecks: [],
      savedCharacters: [],
      selectedDeckPath: null,
      hasUnsavedChanges: false,
      errorMessage: null,
    );
  }
}