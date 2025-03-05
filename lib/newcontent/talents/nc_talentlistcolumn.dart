// lib/newcontent/talents/TalentListColumn.dart
import 'package:flutter/material.dart';
import 'package:card_game/newcontent/talents/nc_talent_service.dart';

class TalentListColumn extends StatefulWidget {
  final Function(String)? onTalentSelected;

  const TalentListColumn({
    super.key,
    this.onTalentSelected,
  });

   @override
  TalentListColumnState createState() => TalentListColumnState(); // Public state
}

class TalentListColumnState extends State<TalentListColumn> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  List<Map<String, dynamic>> _talents = [];

  @override
  void initState() {
    super.initState();
    _loadTalents();
  }

  Future<void> _loadTalents() async {
    try {
      final loadedTalents = await TalentService.loadTalents();
      setState(() {
        _talents = loadedTalents;
      });
    } catch (e) {
      print('Error loading talents: $e');
    }
  }

  // Public method for refreshing talents
  Future<void> refreshTalents() async {
    await _loadTalents();
  }

  // Filters and sorts the talents list
  List<Map<String, dynamic>> get _filteredAndSortedTalents {
    return _talents
        .where((talent) {
          // Filter based on search query
          if (_searchQuery.isNotEmpty) {
            final name = talent['name'].toString().toLowerCase();
            if (!name.contains(_searchQuery.toLowerCase())) {
              return false;
            }
          }
          // Filter by type (e.g., Pillar)
          if (_selectedFilter != 'All') {
            return talent['pillar'] == _selectedFilter;
          }
          return true;
        })
        .toList()
        ..sort((a, b) {
          // Sorting options
          switch (_sortBy) {
            case 'Name':
              return a['name'].toString().compareTo(b['name'].toString());
            case 'Level':
              return (a['level'] as int).compareTo(b['level'] as int);
            case 'Pillar':
              return a['pillar'].toString().compareTo(b['pillar'].toString());
            default:
              return 0;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTalents = _filteredAndSortedTalents;

    return Column(
      children: [
        // Header
        const SizedBox(height: 8),
        const Text(
          'Talent List',
          style: TextStyle(
            fontSize: 16, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // Makes the font bold
          ),
        ),

        
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
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
                    DropdownMenuItem(value: 'All', child: Text('All Pillars')),
                    DropdownMenuItem(value: 'Body Modification', child: Text('Body Modification')),
                    DropdownMenuItem(value: 'Mind Expansion', child: Text('Mind Expansion')),
                    DropdownMenuItem(value: 'Energy Manipulation', child: Text('Energy Manipulation')),
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
                    DropdownMenuItem(value: 'Pillar', child: Text('Sort by Pillar')),
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

        // Talent List Column
        Expanded(
          child: ListView.builder(
            itemCount: filteredTalents.length,
            itemBuilder: (context, index) {
              final talent = filteredTalents[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(talent['name'].toString()),
                  subtitle: Text(
                    'Level ${talent['level']} - ${talent['pillar']}',
                  ),
                  onTap: () {
                    widget.onTalentSelected?.call(talent['name'].toString());
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
