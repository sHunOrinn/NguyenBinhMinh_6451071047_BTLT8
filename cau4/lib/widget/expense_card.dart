import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/currency_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            expense.categoryName?.isNotEmpty == true
                ? expense.categoryName![0]
                : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          expense.note,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          expense.categoryName ?? '',
          style: TextStyle(color: colorScheme.secondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(expense.amount),
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}