import 'package:flutter/material.dart';
import '../models/category.dart';
import 'category_dropdown.dart';

class NoteForm extends StatefulWidget {
  final List<Category> categories;
  final String initialTitle;
  final String initialContent;
  final int initialCategoryId;
  final Function(String title, String content, int categoryId) onSave;

  const NoteForm({
    super.key,
    required this.categories,
    required this.initialTitle,
    required this.initialContent,
    required this.initialCategoryId,
    required this.onSave,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && selectedCategoryId != null) {
      widget.onSave(
        _titleController.text.trim(),
        _contentController.text.trim(),
        selectedCategoryId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CategoryDropdown(
              categories: widget.categories,
              selectedValue: selectedCategoryId,
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Lưu ghi chú'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}