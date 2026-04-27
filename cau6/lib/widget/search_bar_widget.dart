import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Nhập từ cần tra cứu...',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: onClear,
            color: colorScheme.onSurfaceVariant,
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}