import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_item.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onTapNote;

  const NoteList({
    super.key,
    required this.notes,
    required this.onTapNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteItem(
          note: note,
          onTap: () => onTapNote(note),
        );
      },
    );
  }
}