import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_database.dart';
import '../widget/empty_notes.dart';
import '../widget/note_list.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await NoteDatabase.instance.getAllNotes();
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  Future<void> _goToAddNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NoteFormScreen(),
      ),
    );
    _loadNotes();
  }

  Future<void> _goToEditNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(note: note),
      ),
    );
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ghi chú'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const EmptyNotes()
          : NoteList(
        notes: notes,
        onTapNote: _goToEditNote,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}