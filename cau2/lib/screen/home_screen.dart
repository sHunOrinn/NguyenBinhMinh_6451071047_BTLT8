import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/note.dart';
import '../services/note_database.dart';
import '../widget/empty_notes.dart';
import '../widget/note_filter_bar.dart';
import '../widget/note_list.dart';
import 'category_screen.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Category> categories = [];
  int? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadCategories();
    await _loadNotes();
  }

  Future<void> _loadCategories() async {
    final data = await NoteDatabase.instance.getAllCategories();
    setState(() {
      categories = data;
    });
  }

  Future<void> _loadNotes() async {
    final data = await NoteDatabase.instance.getNotes(
      categoryId: selectedCategoryId,
    );
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
    await _loadCategories();
    await _loadNotes();
  }

  Future<void> _goToEditNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(note: note),
      ),
    );
    await _loadNotes();
  }

  Future<void> _goToCategoryScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoryScreen(),
      ),
    );
    await _loadCategories();
    await _loadNotes();
  }

  void _onFilterChanged(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú theo danh mục'),
        actions: [
          IconButton(
            onPressed: _goToCategoryScreen,
            icon: const Icon(Icons.folder_open),
          ),
        ],
      ),
      body: Column(
        children: [
          NoteFilterBar(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onChanged: _onFilterChanged,
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                ? const EmptyNotes()
                : NoteList(
              notes: notes,
              onTapNote: _goToEditNote,
            ),
          ),
          Text('Nguyễn Bình Minh - 6451071047')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}