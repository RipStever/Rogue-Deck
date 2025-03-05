// lib/newcontent/feats/FeatsListColumn.dart

import 'package:flutter/material.dart';
import 'package:card_game/NewContent/feats/nc_feat_service.dart';

class FeatsListColumn extends StatefulWidget {
  final Function(String)? onFeatSelected;

  const FeatsListColumn({
    super.key,
    this.onFeatSelected,
  });

  @override
  FeatsListColumnState createState() => FeatsListColumnState(); // Changed to public state class
}

class FeatsListColumnState extends State<FeatsListColumn> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  List<Map<String, dynamic>> _feats = [];

  @override
  void initState() {
    super.initState();
    _loadFeats();
  }

  Future<void> _loadFeats() async {
  print("Loading feats..."); // Debugging statement
  try {
    final loadedFeats = await FeatService.loadFeats();
    setState(() {
      _feats = loadedFeats;
    });
  } catch (e) {
    print('Error loading feats: $e');
  }
}

 // Add this public method
  Future<void> refreshFeats() async {
    await _loadFeats();
  }

  // In FeatsListColumn, modify the _filteredAndSortedFeats getter:

List<Map<String, dynamic>> get _filteredAndSortedFeats {
  // First, group feats by their base name
  Map<String, List<Map<String, dynamic>>> groupedFeats = {};
  
  for (var feat in _feats) {
    // Extract base name by removing the tier and aptitude info
    String baseName = feat['name'].toString()
        .replaceAll(RegExp(r'\s-\s(Basic|Tier \d+).*'), '')
        .trim();
    
    if (!groupedFeats.containsKey(baseName)) {
      groupedFeats[baseName] = [];
    }
    groupedFeats[baseName]!.add(feat);
  }

  // Convert grouped feats into a list of unique feats
  List<Map<String, dynamic>> uniqueFeats = groupedFeats.entries.map((entry) {
    // Use the first feat in each group for display
    var firstFeat = entry.value.first;
    return {
      'name': entry.key,
      'level': firstFeat['level'],
      'type': firstFeat['type'],
      'requirement': firstFeat['requirement'],
      'allVariants': entry.value,
    };
  }).toList();

  // Apply filtering and sorting
  return uniqueFeats.where((feat) {
    if (_searchQuery.isNotEmpty) {
      final name = feat['name'].toString().toLowerCase();
      if (!name.contains(_searchQuery.toLowerCase())) {
        return false;
      }
    }
    
    if (_selectedFilter != 'All') {
      return feat['type'] == _selectedFilter;
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
    final filteredFeats = _filteredAndSortedFeats;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
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

        // Feat List Column
        Expanded(
          child: ListView.builder(
            itemCount: filteredFeats.length,
            itemBuilder: (context, index) {
              final feat = filteredFeats[index]; // Access each feat in the list
              Color cardColor;

              switch (feat['type']) {
                case 'Attack':
                  cardColor = const Color.fromARGB(200, 244, 67, 54);
                  break;
                case 'Movement':
                  cardColor = Colors.green;
                  break;
                case 'Special':
                  cardColor = const Color.fromARGB(255, 173, 66, 192);
                  break;
                default:
                  cardColor = Colors.white;
              }

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(feat['name'].toString()),
                  subtitle: Text(
                    'Level ${feat['level']} - ${feat['type']} - ${feat['tier']}',
                  ),
                  onTap: () {
                    widget.onFeatSelected?.call(feat['name'].toString());
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