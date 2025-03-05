import 'package:flutter/material.dart';
import 'package:card_game/characterbuilder/weapons/cb_weapon_display_card.dart';
import 'package:card_game/universal/models/character_model.dart';
import 'package:card_game/characterbuilder/weapons/cb_weapon_service.dart';

class CB_WeaponsWidget extends StatefulWidget {
  final CharacterModel characterModel;
  final Function(CharacterModel) onCharacterUpdate;
  final Function(List<Map<String, dynamic>>) onWeaponsChanged;

  const CB_WeaponsWidget({
    super.key,
    required this.characterModel,
    required this.onCharacterUpdate,
    required this.onWeaponsChanged,
  });

  @override
  State<CB_WeaponsWidget> createState() => _CB_WeaponsWidgetState();
}

class _CB_WeaponsWidgetState extends State<CB_WeaponsWidget> {
  List<Map<String, dynamic>> _weapons = [];
  List<String> _selectedWeapons = [];
  final List<String> _wishlistedWeapons = [];
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _loadWeapons();
    _selectedWeapons = widget.characterModel.selectedWeapons
            ?.map((w) => w['name'] as String)
            .toList() ?? [];
  }

  Future<void> _loadWeapons() async {
    try {
      final loadedWeapons = await WeaponService.loadWeapons();
      setState(() {
        _weapons = loadedWeapons;
      });
    } catch (e) {
      debugPrint('Error loading weapons: $e');
    }
  }

  void _updateCharacterWeapons() {
    final updatedWeapons = _weapons
        .where((weapon) => _selectedWeapons.contains(weapon['name']))
        .toList();

    final updatedCharacter = widget.characterModel.copyWith(
      selectedWeapons: updatedWeapons,
    );

    widget.onCharacterUpdate(updatedCharacter);
    widget.onWeaponsChanged(updatedWeapons);
  }

  List<Map<String, dynamic>> get _filteredWeapons {
    // First filter the weapons
    List<Map<String, dynamic>> filtered = _weapons.where((weapon) {
      if (_searchQuery.isNotEmpty) {
        final name = weapon['name'].toString().toLowerCase();
        final type = weapon['type'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !type.contains(query)) {
          return false;
        }
      }

      if (_selectedType != 'All' && weapon['type'] != _selectedType) {
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
                        hintText: 'Search weapons...',
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
                        DropdownMenuItem(value: 'Ranged', child: Text('Ranged')),
                        DropdownMenuItem(value: 'Melee', child: Text('Melee')),
                        DropdownMenuItem(value: 'Exotic', child: Text('Exotic')),
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

            // Weapons List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredWeapons.length,
                  itemBuilder: (context, index) {
                    final weapon = _filteredWeapons[index];
                    final weaponName = weapon['name'] as String;

                    return WeaponDisplayCard(
                      weapon: weapon,
                      isSelected: _selectedWeapons.contains(weaponName),
                      isWishlisted: _wishlistedWeapons.contains(weaponName),
                      onSelectedChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWeapons.add(weaponName);
                          } else {
                            _selectedWeapons.remove(weaponName);
                          }
                        });
                        _updateCharacterWeapons();
                      },
                      onWishlistChanged: (wishlisted) {
                        setState(() {
                          if (wishlisted) {
                            _wishlistedWeapons.add(weaponName);
                          } else {
                            _wishlistedWeapons.remove(weaponName);
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
