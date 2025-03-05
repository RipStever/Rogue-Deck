// lib/gameplay/utils/action_parser.dart

/// Represents a parsed action with type, tier, and count information
class ParsedAction {
  /// The type of action (Attack, Move, Special)
  final List<String> actionTypes;
  
  /// The tier level (null for Basic, 1 or 2 for specific tiers)
  final int? tier;
  
  /// Number of times the action can be performed
  final int count;
  
  /// Whether this allows choice between types
  final bool hasChoice;

  const ParsedAction({
    required this.actionTypes,
    this.tier,
    this.count = 1,
    this.hasChoice = false,
  });

  @override
  String toString() {
    final tierStr = tier == null ? 'Basic' : 'Tier $tier';
    final typesStr = hasChoice ? actionTypes.join(' or ') : actionTypes.first;
    return '$count $tierStr $typesStr';
  }
}

/// Parses action card metadata into structured action information
class ActionParser {
  /// Parses the metadata string into a list of parsed actions
  static List<ParsedAction> parse(String? metadata) {
    // Return empty list for null, empty, or "None" metadata
    if (metadata == null || metadata.trim().isEmpty || metadata.trim().toLowerCase() == 'none') {
      return [];
    }

    // Split combined actions (separated by &)
    final actionStrings = metadata.split('&').map((s) => s.trim());
    final actions = <ParsedAction>[];

    for (final actionStr in actionStrings) {
      final action = _parseAction(actionStr);
      if (action != null) {
        actions.add(action);
      }
    }

    return actions;
  }

  /// Parse a single action string
  static ParsedAction? _parseAction(String actionStr) {
    // Match pattern for action strings
    final match = RegExp(
      r'^(?:(\d+)\s+)?'  // Optional count
      r'(Basic|Tier\s*(\d+))?\s*'  // Optional tier
      r'(\w+)'  // First action type
      r'(?:\s*(?:\/|or)\s*(\w+))?'  // Optional second type
      r'(?:\s*(?:\/|or)\s*(\w+))?'  // Optional third type
      r'$',
      caseSensitive: false,
    ).firstMatch(actionStr);

    if (match == null) return null;

    // Extract count (default to 1)
    final countStr = match.group(1);
    final count = countStr != null ? int.parse(countStr) : 1;

    // Extract and normalize tier
    final tierStr = match.group(2)?.toLowerCase();
    int? tier;
    if (tierStr != null) {
      if (tierStr == 'basic') {
        tier = null; // Basic actions have no tier
      } else {
        // Extract number from "Tier X"
        tier = int.tryParse(match.group(3) ?? '1'); // Default to Tier 1 if no number
      }
    }

    // Extract and normalize action types
    final types = [
      match.group(4), // First type (required)
      match.group(5), // Optional second type
      match.group(6), // Optional third type
    ].where((t) => t != null).map((t) => _normalizeType(t!)).toList();

    if (types.isEmpty) return null;

    return ParsedAction(
      actionTypes: types,
      tier: tier,
      count: count,
      hasChoice: types.length > 1,
    );
  }

  /// Normalize action type strings
  static String _normalizeType(String type) {
    switch (type.toLowerCase()) {
      case 'move':
      case 'movement':
        return 'Movement';
      case 'attack':
      case 'attacks':
        return 'Attack';
      case 'special':
        return 'Special';
      default:
        return type;
    }
  }

  /// Check if an action allows a specific action type at a given tier
  static bool canUseAction(ParsedAction action, String type, {int? tier}) {
    // Normalize the requested type
    final normalizedType = _normalizeType(type);
    
    // Check if action includes this type
    if (!action.actionTypes.contains(normalizedType)) {
      return false;
    }

    // Check tier compatibility
    if (tier != null) {
      // Basic actions (null tier) can only be used for basic abilities
      if (action.tier == null && tier > 0) {
        return false;
      }
      // Otherwise ensure action tier is high enough
      if (action.tier != null && action.tier! < tier) {
        return false;
      }
    }

    return true;
  }
}

/// Helper class to find compatible hero abilities for an action card
// lib/gameplay/cardzone/action_parser.dart

class ActionAbilityMatcher {
  /// Check if a specific action can be used for an ability
  static bool canUseActionForAbility(
    ParsedAction action,
    String abilityType,
    int abilityTier,
  ) {
    // Action allows this type
    if (!action.actionTypes.contains(abilityType)) {
      return false;
    }

    // Check tier compatibility
    final actionTier = action.tier;
    if (actionTier == null) {
      // Basic actions (null tier) can only be used for basic abilities
      return abilityTier == 0;
    } else {
      // Tiered actions can use same tier or lower
      return actionTier >= abilityTier;
    }
  }

  /// Checks if an ability is compatible with any of the parsed actions
  static bool isAbilityCompatible(
    List<ParsedAction> actions,
    String abilityType, 
    int abilityTier
  ) {
    // Check each action for compatibility
    for (final action in actions) {
      if (canUseActionForAbility(action, abilityType, abilityTier)) {
        return true;
      }
    }
    return false;
  }
}