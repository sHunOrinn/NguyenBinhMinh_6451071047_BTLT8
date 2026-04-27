import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widget/expense_card.dart';
import '../widget/summary_card.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  List<Expense> _expenses = [];
  List<Map<String, dynamic>> _summary = [];
  double _total = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final expenses = await _db.getExpenses();
    final summary = await _db.getSummaryByCategory();
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    setState(() {
      _expenses = expenses;
      _summary = summary;
      _total = total;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAdd([Expense? expense]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddExpenseScreen(expense: expense)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${expense.note}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteExpense(expense.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Chi Tiêu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            // Summary card
            SummaryCard(summaryData: _summary, totalAmount: _total),

            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách chi tiêu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_expenses.length} khoản',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Expense list
            if (_expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có chi tiêu nào\nNhấn + để thêm mới',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._expenses.map((e) => ExpenseCard(
                expense: e,
                onEdit: () => _navigateToAdd(e),
                onDelete: () => _deleteExpense(e),
              )),

            const SizedBox(height: 80),
            Text('Nguyễn Bình Minh - 6451071047',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 26
                )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm chi tiêu'),
      ),
    );
  }
}