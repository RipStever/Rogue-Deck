// lib/universal/components/formatted_game_text.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../universal/cardtext/keyword_service.dart';

class FormattedGameText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool autoSize;
  final double? minFontSize;
  final double? maxFontSize;

  const FormattedGameText({
    super.key,
    required this.text,
    this.style,
    this.autoSize = false,
    this.minFontSize,
    this.maxFontSize,
  });

  TextSpan _formatText(String text) {
    final List<TextSpan> spans = [];
    final patterns = KeywordService().getAllPatterns();
    
    String remaining = text;
    int lastMatchEnd = 0;

    // Sort matches by their start position
    final allMatches = <({int start, int end, String text, Color color})>[];

    for (final (regex, color) in patterns) {
      final matches = regex.allMatches(text);
      for (final match in matches) {
        allMatches.add((
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          color: color,
        ));
      }
    }

    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // Process matches in order
    for (final match in allMatches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      spans.add(TextSpan(
        text: match.text,
        style: TextStyle(
          color: match.color,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(
      style: style,
      children: spans,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (autoSize) {
      return AutoSizeText.rich(
        _formatText(text),
        minFontSize: minFontSize ?? 8,
        maxFontSize: maxFontSize ?? 14,
        style: style,
      );
    }

    return RichText(
      text: _formatText(text),
    );
  }
}