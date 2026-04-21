import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_database.dart';
import '../widget/note_form.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  Future<void> _saveNote(String title, String content) async {
    if (widget.note == null) {
      await NoteDatabase.instance.insertNote(
        Note(title: title, content: content),
      );
    } else {
      await NoteDatabase.instance.updateNote(
        widget.note!.copyWith(
          title: title,
          content: content,
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteNote() async {
    if (widget.note?.id != null) {
      await NoteDatabase.instance.deleteNote(widget.note!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa ghi chú' : 'Tạo ghi chú'),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Column(
        children: [
          NoteForm(
            initialTitle: widget.note?.title ?? '',
            initialContent: widget.note?.content ?? '',
            onSave: _saveNote,
          ),
          Text('Nguyễn Bình Minh - 6451071047'),
        ]
      )
    );
  }
}