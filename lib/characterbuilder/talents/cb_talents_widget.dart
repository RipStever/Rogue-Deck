import 'package:flutter/material.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/talents/cb_talents_service.dart';
import 'package:card_game/characterbuilder/talents/cb_talents_displaycard.dart';

class CB_TalentsWidget extends StatefulWidget {
  final CharacterModel characterModel;
  final Function(CharacterModel) onCharacterUpdate;

  const CB_TalentsWidget({
    super.key,
    required this.characterModel,
    required this.onCharacterUpdate,
  });

  @override
  State<CB_TalentsWidget> createState() => _CB_TalentsWidgetState();
}

class _CB_TalentsWidgetState extends State<CB_TalentsWidget> {
  List<Map<String, dynamic>> _allTalents = [];
  List<String> _selectedTalents = [];
  final List<String> _wishlistedTalents = [];
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTalents();
    // If the character already has selectedTalents, store their names
    _selectedTalents = widget.characterModel.selectedTalents
            ?.map((t) => t['name'] as String)
            .toList() 
        ?? [];
  }

  Future<void> _loadTalents() async {
    try {
      final loaded = await TalentService.loadTalents();
      setState(() {
        _allTalents = loaded;
      });
    } catch (e) {
      debugPrint('Error loading talents: $e');
    }
  }

  /// When user toggles selection, update the character's data
  void _updateCharacterTalents() {
    final updated = _allTalents.where(
      (talent) => _selectedTalents.contains(talent['name'])
    ).toList();

    final newChar = widget.characterModel.copyWith(
      selectedTalents: updated,
    );
    widget.onCharacterUpdate(newChar);
  }

  List<Map<String, dynamic>> get _filteredTalents {
    if (_searchQuery.isEmpty) {
      return _allTalents;
    }
    final queryLower = _searchQuery.toLowerCase();
    return _allTalents.where((talent) {
      final name = (talent['name'] ?? '').toLowerCase();
      final effect = (talent['effect'] ?? '').toLowerCase();
      final requirement = (talent['requirement'] ?? '').toLowerCase();
      return name.contains(queryLower)
          || effect.contains(queryLower)
          || requirement.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search talents...',
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

            // Talent List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredTalents.length,
                  itemBuilder: (context, index) {
                    final talent = _filteredTalents[index];
                    final talentName = talent['name'] ?? '??';

                    // Add this debug print to check the effect field
                    debugPrint('Talent data in TalentsSection: $talent');

                    return TalentDisplayCard(
                      talent: talent,
                      isSelected: _selectedTalents.contains(talentName),
                      isWishlisted: _wishlistedTalents.contains(talentName),
                      onSelectedChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTalents.add(talentName);
                          } else {
                            _selectedTalents.remove(talentName);
                          }
                        });
                        _updateCharacterTalents();
                      },
                      onWishlistChanged: (wishlisted) {
                        setState(() {
                          if (wishlisted) {
                            _wishlistedTalents.add(talentName);
                          } else {
                            _wishlistedTalents.remove(talentName);
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
