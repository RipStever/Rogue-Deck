import 'package:flutter/material.dart';
import 'package:card_game/characterbuilder/feats/cb_feat_display_card.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/feats/cb_feat_service.dart';

class CB_FeatsWidget extends StatefulWidget {
  final CharacterModel characterModel;
  final Function(CharacterModel) onCharacterUpdate;

  const CB_FeatsWidget({
    super.key,
    required this.characterModel,
    required this.onCharacterUpdate,
  });

  @override
  State<CB_FeatsWidget> createState() => _CB_FeatsWidgetState();
}

class _CB_FeatsWidgetState extends State<CB_FeatsWidget> {
  List<Map<String, dynamic>> _feats = [];
  List<String> _selectedFeats = [];
  final List<String> _wishlistedFeats = [];
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadFeats();
    _selectedFeats = widget.characterModel.selectedFeats
            ?.map((f) => f['name'] as String)
            .toList() ??
        [];
  }

  Future<void> _loadFeats() async {
    try {
      final loadedFeats = await FeatService.loadFeats();
      setState(() {
        _feats = loadedFeats;
      });
    } catch (e) {
      debugPrint('Error loading feats: $e');
    }
  }

  void _updateCharacterFeats() {
    final updatedFeats = _feats
        .where((feat) => _selectedFeats.contains(feat['name']))
        .toList();

    final updatedCharacter = widget.characterModel.copyWith(
      selectedFeats: updatedFeats,
    );

    widget.onCharacterUpdate(updatedCharacter);
  }

    List<Map<String, dynamic>> get _filteredFeats {
    // First filter the feats
    List<Map<String, dynamic>> filtered = _feats.where((feat) {
      if (_searchQuery.isNotEmpty) {
        final name = feat['name'].toString().toLowerCase();
        final type = feat['type'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !type.contains(query)) {
          return false;
        }
      }

      if (_selectedType != 'All' && feat['type'] != _selectedType) {
        return false;
      }

      return true;
    }).toList();

    // Then sort alphabetically by name
    filtered.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search and Filter Row
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search feats...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Types')),
                        DropdownMenuItem(value: 'Attack', child: Text('Attack')),
                        DropdownMenuItem(value: 'Movement', child: Text('Movement')),
                        DropdownMenuItem(value: 'Special', child: Text('Special')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Feats List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredFeats.length,
                  itemBuilder: (context, index) {
                    final feat = _filteredFeats[index];
                    final featName = feat['name'] as String;

                    return FeatDisplayCard(
                      feat: feat,
                      isSelected: _selectedFeats.contains(featName),
                      isWishlisted: _wishlistedFeats.contains(featName),
                      onSelectedChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeats.add(featName);
                          } else {
                            _selectedFeats.remove(featName);
                          }
                        });
                        _updateCharacterFeats();
                      },
                      onWishlistChanged: (wishlisted) {
                        setState(() {
                          if (wishlisted) {
                            _wishlistedFeats.add(featName);
                          } else {
                            _wishlistedFeats.remove(featName);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}