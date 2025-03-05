import 'package:flutter/material.dart';
import 'package:card_game/newcontent/weapons/nc_weaponservice.dart';

class WeaponsListColumn extends StatefulWidget {
  final Function(String)? onWeaponSelected;

  const WeaponsListColumn({
    super.key,
    this.onWeaponSelected,
  });

  @override
  WeaponsListColumnState createState() => WeaponsListColumnState();
}

class WeaponsListColumnState extends State<WeaponsListColumn> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  List<Map<String, dynamic>> _weapons = [];

  @override
  void initState() {
    super.initState();
    _loadWeapons();
  }

  Future<void> _loadWeapons() async {
    print("Loading weapons..."); // Debugging statement
    try {
      final loadedWeapons = await WeaponService.loadWeapons();
      setState(() {
        _weapons = loadedWeapons;
      });
    } catch (e) {
      print('Error loading weapons: $e');
    }
  }

  Future<void> refreshWeapons() async {
    await _loadWeapons();
  }

  List<Map<String, dynamic>> get _filteredAndSortedWeapons {
    Map<String, List<Map<String, dynamic>>> groupedWeapons = {};
    
    for (var weapon in _weapons) {
      String baseName = weapon['name'].toString()
          .replaceAll(RegExp(r'\s-\s(Basic|Tier \d+).*'), '')
          .trim();
      
      if (!groupedWeapons.containsKey(baseName)) {
        groupedWeapons[baseName] = [];
      }
      groupedWeapons[baseName]!.add(weapon);
    }

    List<Map<String, dynamic>> uniqueWeapons = groupedWeapons.entries.map((entry) {
      var firstWeapon = entry.value.first;
      return {
        'name': entry.key,
        'level': firstWeapon['level'],
        'type': firstWeapon['type'],
        'requirement': firstWeapon['requirement'],
        'allVariants': entry.value,
      };
    }).toList();

    return uniqueWeapons.where((weapon) {
      if (_searchQuery.isNotEmpty) {
        final name = weapon['name'].toString().toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      if (_selectedFilter != 'All') {
        return weapon['type'] == _selectedFilter;
      }
      
      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Name':
            return a['name'].toString().compareTo(b['name'].toString());
          case 'Level':
            return (a['level'] as int).compareTo(b['level'] as int);
          case 'Type':
            return a['type'].toString().compareTo(b['type'].toString());
          default:
            return 0;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final filteredWeapons = _filteredAndSortedWeapons;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
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

        // Filter and Sort Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              // Filter Dropdown
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Types')),
                    DropdownMenuItem(value: 'Attack', child: Text('Attack')),
                    DropdownMenuItem(value: 'Movement', child: Text('Movement')),
                    DropdownMenuItem(value: 'Special', child: Text('Special')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFilter = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Sort Dropdown
              Expanded(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Name', child: Text('Sort by Name')),
                    DropdownMenuItem(value: 'Level', child: Text('Sort by Level')),
                    DropdownMenuItem(value: 'Type', child: Text('Sort by Type')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortBy = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Weapon List Column
        Expanded(
          child: ListView.builder(
            itemCount: filteredWeapons.length,
            itemBuilder: (context, index) {
              final weapon = filteredWeapons[index];
              Color borderColor;

              switch (weapon['type']) {
                case 'Attack':
                  borderColor = const Color.fromARGB(200, 244, 67, 54);
                  break;
                case 'Movement':
                  borderColor = Colors.green;
                  break;
                case 'Special':
                  borderColor = const Color.fromARGB(255, 173, 66, 192);
                  break;
                default:
                  borderColor = Colors.grey;
              }

              return Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(weapon['name'].toString()),
                  subtitle: Text(
                    'Level ${weapon['level']} - ${weapon['type']} - ${weapon['tier']}',
                  ),
                  onTap: () {
                    widget.onWeaponSelected?.call(weapon['name'].toString());
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
