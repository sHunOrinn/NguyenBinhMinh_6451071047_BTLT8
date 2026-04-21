import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final int? selectedValue;
  final ValueChanged<int?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      decoration: const InputDecoration(
        labelText: 'Danh mục',
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn danh mục';
        }
        return null;
      },
    );
  }
}