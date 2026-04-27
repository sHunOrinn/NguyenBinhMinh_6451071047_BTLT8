import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class LogTile extends StatelessWidget {
  final LogEntry entry;

  const LogTile({super.key, required this.entry});

  Color _actionColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = entry.action.toUpperCase();
    if (a.contains('CREATE')) return Colors.green.shade700;
    if (a.contains('UPDATE')) return Colors.orange.shade700;
    if (a.contains('DELETE')) return cs.error;
    if (a.contains('READ'))   return cs.primary;
    return cs.onSurface;
  }

  String _actionEmoji() {
    final a = entry.action.toUpperCase();
    if (a.contains('CREATE')) return '➕';
    if (a.contains('UPDATE')) return '✏️';
    if (a.contains('DELETE')) return '🗑️';
    if (a.contains('READ'))   return '👁️';
    return '📋';
  }

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        dense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Text(_actionEmoji(), style: const TextStyle(fontSize: 20)),
        title: Text(
          entry.action,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        trailing: Text(
          entry.time,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}