import 'package:flutter/material.dart';
import '../models/word.dart';

class WordListItem extends StatelessWidget {
  final Word word;
  final String highlight;

  const WordListItem({
    super.key,
    required this.word,
    this.highlight = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            word.word[0].toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: _buildHighlightedText(
          word.word,
          highlight,
          const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF424242)),
          TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
              backgroundColor: Colors.yellow.withOpacity(0.4)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            word.meaning,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
      String text,
      String query,
      TextStyle normal,
      TextStyle highlighted,
      ) {
    if (query.isEmpty) return Text(text, style: normal);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return Text(text, style: normal);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: normal),
          TextSpan(
              text: text.substring(index, index + query.length),
              style: highlighted),
          TextSpan(text: text.substring(index + query.length), style: normal),
        ],
      ),
    );
  }
}