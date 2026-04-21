import 'package:flutter/material.dart';
import '../models/category.dart';

class NoteFilterBar extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const NoteFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<int?>(
        value: selectedCategoryId,
        decoration: const InputDecoration(
          labelText: 'Lọc theo danh mục',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Tất cả danh mục'),
          ),
          ...categories.map(
                (category) => DropdownMenuItem<int?>(
              value: category.id,
              child: Text(category.name),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}