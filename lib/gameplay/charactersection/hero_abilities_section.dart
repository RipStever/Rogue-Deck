// lib/gameplay/charactersection/hero_abilities_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../universal/models/hero_ability_card_model.dart';
import '../../universal/widgets/hero_ability_card_widget.dart';
import '../gameplay_provider.dart';

class HeroAbilitiesSection extends ConsumerStatefulWidget {
  const HeroAbilitiesSection({super.key});

  @override
  ConsumerState<HeroAbilitiesSection> createState() => _HeroAbilitiesSectionState();
}

class _HeroAbilitiesSectionState extends ConsumerState<HeroAbilitiesSection> {
  // Card sizing constants
  static const double baseCardWidth = 180.0;
  static const double baseCardHeight = 250.0;
  static const double hoveredCardWidth = 220.0;
  static const double hoveredCardHeight = 330.0;
  static const double horizontalSpacing = 12.0;
  static const double verticalSpacing = 12.0;
  static const double containerHeight = 400.0;

  // Sorting and filtering
  String _sortType = 'type';
  String _filterType = 'all';
  int? _hoveredIndex;

  // State management for hero abilities
  List<HeroAbilityCardModel> _heroAbilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeroAbilities();
  }

  Future<void> _loadHeroAbilities() async {
    final gameState = ref.read(gameplayProvider);
    
    // Load both feat and weapon abilities
    final abilities = await Future.wait([
      // Feat abilities
      ...gameState.heroAbilities
        .map((card) => HeroAbilityCardModel.fromCardData(card))
        ,
      
      // Weapon abilities
      ...gameState.weaponAbilities
        .map((card) => HeroAbilityCardModel.fromCardData(card))
        ,
    ]);

    setState(() {
      _heroAbilities = abilities;
      _isLoading = false;
    });
  }

  void _updateSort(String newSort) {
    setState(() => _sortType = newSort);
  }

  void _updateFilter(String newFilter) {
    setState(() => _filterType = newFilter);
  }

  List<HeroAbilityCardModel> _getFilteredAndSortedAbilities(List<HeroAbilityCardModel> abilities) {
    var filtered = abilities.where((ability) {
      if (_filterType == 'all') return true;
      return ability.type.toLowerCase() == _filterType.toLowerCase();
    }).toList();

    filtered.sort((a, b) {
      switch (_sortType) {
        case 'tier':
          final tierOrder = {'Tier 2': 0, 'Tier 1': 1, 'Basic': 2};
          final tierCompare = (tierOrder[a.tier] ?? 3).compareTo(tierOrder[b.tier] ?? 3);
          return tierCompare != 0 ? tierCompare : a.name.compareTo(b.name);
        case 'type':
          final typeCompare = a.type.compareTo(b.type);
          return typeCompare != 0 ? typeCompare : a.name.compareTo(b.name);
        case 'name':
          return a.name.compareTo(b.name);
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredAbilities = _getFilteredAndSortedAbilities(_heroAbilities);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hero Abilities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${filteredAbilities.length} Abilities',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Controls Row
                Row(
                  children: [
                    // Sort Dropdown
                    Expanded(
                      child: _buildDropdown(
                        value: _sortType,
                        items: const [
                          ('type', 'Sort by Type'),
                          ('tier', 'Sort by Tier'),
                          ('name', 'Sort by Name'),
                        ],
                        onChanged: _updateSort,
                        icon: Icons.sort,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Filter Dropdown
                    Expanded(
                      child: _buildDropdown(
                        value: _filterType,
                        items: const [
                          ('all', 'All Types'),
                          ('attack', 'Attack'),
                          ('movement', 'Movement'),
                          ('special', 'Special'),
                        ],
                        onChanged: _updateFilter,
                        icon: Icons.filter_list,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Abilities Grid
          Expanded(
            child: filteredAbilities.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate cards per row based on available width
                        final containerWidth = constraints.maxWidth;
                        const totalCardSpace = hoveredCardWidth + horizontalSpacing;
                        int cardsPerRow = (containerWidth ~/ totalCardSpace);
                        if (cardsPerRow < 1) cardsPerRow = 1;

                        final rowWidgets = <Widget>[];

                        // Split abilities into rows
                        for (int i = 0; i < filteredAbilities.length; i += cardsPerRow) {
                          final rowAbilities = filteredAbilities.sublist(
                            i,
                            (i + cardsPerRow > filteredAbilities.length) 
                              ? filteredAbilities.length 
                              : i + cardsPerRow,
                          );

                          rowWidgets.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: verticalSpacing),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: rowAbilities.asMap().entries.map((entry) {
                                    final localIndex = entry.key;
                                    final ability = entry.value;
                                    final globalIndex = i + localIndex;

                                    final isHovered = _hoveredIndex == globalIndex;

                                    return MouseRegion(
                                      onEnter: (_) => setState(() => _hoveredIndex = globalIndex),
                                      onExit: (_) => setState(() => _hoveredIndex = null),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: horizontalSpacing),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          width: isHovered ? hoveredCardWidth : baseCardWidth,
                                          height: isHovered ? hoveredCardHeight : baseCardHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isHovered ? Colors.blue : Colors.grey[800]!,
                                              width: isHovered ? 2 : 1,
                                            ),
                                            boxShadow: isHovered
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: HeroAbilityCard(
                                            ability: ability,
                                            isHovered: isHovered,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rowWidgets,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<(String, String)> items,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(icon, color: Colors.white70, size: 18),
          dropdownColor: Colors.grey[850],
          style: const TextStyle(color: Colors.white),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item.$1,
              child: Text(
                item.$2,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) => onChanged(value!),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            _filterType == 'all'
                ? 'No Hero Abilities Available'
                : 'No ${_filterType.substring(0, 1).toUpperCase()}${_filterType.substring(1)} Abilities Found',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select feats to gain new abilities',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}