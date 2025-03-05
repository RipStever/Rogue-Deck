import 'package:flutter/material.dart';

class GameText extends StatelessWidget {
  final String text;
  final TextStyle? defaultStyle;

  const GameText({
    super.key,
    required this.text,
    this.defaultStyle,
  });

  // This splits the text into parts while preserving the delimiters
  List<String> _splitPreservingTerms(String text) {
    // Matches:
    // 1. Words starting with capital letters that are likely game terms
    // 2. Numbers followed by specific units (1m, 2d6, etc)
    // 3. Special terms like "END of the SCENE"
    final pattern = RegExp(
      r'((?:[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)|(?:\d+(?:m|d\d+|x\d+))|(?:END\s+of\s+(?:the\s+)?SCENE)|(?:Hit)|(?:Push)|(?:LoS)|(?:Prone)|(?:Zone)|(?:Line)|(?:Cone)|(?:Aura))',
      multiLine: true,
    );

    List<String> parts = [];
    int lastMatchEnd = 0;

    for (var match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        parts.add(text.substring(lastMatchEnd, match.start));
      }
      // Add the match itself
      parts.add(match.group(0)!);
      lastMatchEnd = match.end;
    }

    // Add any remaining text
    if (lastMatchEnd < text.length) {
      parts.add(text.substring(lastMatchEnd));
    }

    return parts;
  }

  TextStyle _getStyleForTerm(String term, TextStyle? baseStyle) {
    // Base style combines default widget style with passed style
    final base = baseStyle ?? const TextStyle();

    // Check for different types of terms
    if (term.contains(RegExp(r'\d+[mx]'))) {
      // Distance measurements
      return base.copyWith(
        color: Colors.blue[700],
        fontWeight: FontWeight.bold,
      );
    } else if (term.contains(RegExp(r'\d+d\d+'))) {
      // Dice rolls
      return base.copyWith(
        color: Colors.purple[700],
        fontWeight: FontWeight.bold,
      );
    } else if (term.contains('END of') || term == 'SCENE') {
      // Timing/phase terms
      return base.copyWith(
        color: Colors.red[700],
        fontWeight: FontWeight.bold,
      );
    } else if ([
      'Push', 'Hit', 'LoS', 'Prone',
      'Zone', 'Line', 'Cone', 'Aura', 'Immobilized'
    ].contains(term)) {
      // Game mechanics terms
      return base.copyWith(
        color: Colors.green[700],
        fontWeight: FontWeight.bold,
      );
    } else if (term[0].toUpperCase() == term[0]) {
      // Other capitalized terms are probably game terms
      return base.copyWith(
        fontWeight: FontWeight.bold,
      );
    }

    // Return base style for non-special text
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final parts = _splitPreservingTerms(text);
    final baseStyle = defaultStyle ?? DefaultTextStyle.of(context).style;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: parts.map((part) {
          return TextSpan(
            text: part,
            style: _getStyleForTerm(part, baseStyle),
          );
        }).toList(),
      ),
    );
  }
}