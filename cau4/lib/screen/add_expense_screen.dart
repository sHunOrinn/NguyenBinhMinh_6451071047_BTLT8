import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; // null = thêm mới, có giá trị = sửa

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _db = DatabaseService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (_isEditing) {
      _amountController.text = widget.expense!.amount.toStringAsFixed(0);
      _noteController.text = widget.expense!.note;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await _db.getCategories();
    setState(() {
      _categories = cats;
      if (_isEditing) {
        _selectedCategory = cats.firstWhere(
              (c) => c.id == widget.expense!.categoryId,
          orElse: () => cats.first,
        );
      } else if (cats.isNotEmpty) {
        _selectedCategory = cats.first;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    setState(() => _isLoading = true);

    final expense = Expense(
      id: widget.expense?.id,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      note: _noteController.text.trim(),
      categoryId: _selectedCategory!.id!,
    );

    if (_isEditing) {
      await _db.updateExpense(expense);
    } else {
      await _db.insertExpense(expense);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa chi tiêu' : 'Thêm chi tiêu'),
        backgroundColor: colorScheme.surface,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền (₫)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                  final val = double.tryParse(v.replaceAll(',', ''));
                  if (val == null || val <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Note field
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập ghi chú' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                ),
                validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: 32),

              // Save button
              FilledButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Cập nhật' : 'Lưu chi tiêu'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}