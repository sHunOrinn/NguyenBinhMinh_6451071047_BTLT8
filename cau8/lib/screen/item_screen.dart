import 'package:flutter/material.dart';
import '../models/item.dart';
import '../screen/log_screen.dart';
import '../services/database_service.dart';
import '../services/log_service.dart';
import '../utils/action_type.dart';
import '../widget/item_card.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final _db = DatabaseService();
  final _log = LogService();

  List<Item> _items = [];
  bool _isLoading = true;
  bool _readLogged = false;

  @override
  void initState() {
    super.initState();
    _loadItems(logRead: true);
  }

  Future<void> _loadItems({bool logRead = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final items = await _db.getItems();

    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });

    if (logRead && !_readLogged) {
      _readLogged = true;
      await _log.log(
        '${ActionType.read.emoji} ${ActionType.read.label}: '
            'Xem danh sách (${items.length} bản ghi)',
      );
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<_ItemFormResult>(
      context,
      MaterialPageRoute(builder: (_) => const _ItemFormScreen()),
    );
    if (result == null) return;

    final id = await _db.insertItem(
      Item(name: result.name, description: result.description),
    );

    await _log.log(
      '${ActionType.create.emoji} ${ActionType.create.label}: '
          'Thêm item #$id - "${result.name}"',
    );

    if (!mounted) return;
    await _loadItems();
  }

  Future<void> _editItem(Item item) async {
    final result = await Navigator.push<_ItemFormResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _ItemFormScreen(
          initialName: item.name,
          initialDescription: item.description,
        ),
      ),
    );
    if (result == null) return;

    await _db.updateItem(
      Item(id: item.id, name: result.name, description: result.description),
    );

    await _log.log(
      '${ActionType.update.emoji} ${ActionType.update.label}: '
          'Sửa item #${item.id} - "${result.name}"',
    );

    if (!mounted) return;
    await _loadItems();
  }

  Future<void> _deleteItem(Item item) async {
    if (item.id == null) return;

    await _db.deleteItem(item.id!);
    await _log.log(
      '${ActionType.delete.emoji} ${ActionType.delete.label}: '
          'Xóa item #${item.id} - "${item.name}"',
    );

    if (!mounted) return;
    await _loadItems();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa "${item.name}"')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý dữ liệu (CRUD)\nNguyễn Bình Minh - 6451071047',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại dữ liệu',
            onPressed: _loadItems,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Xem nhật ký',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
        child: Text(
          'Chưa có dữ liệu.\nNhấn nút + để thêm mới.',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _items.length,
        itemBuilder: (_, i) => ItemCard(
          item: _items[i],
          onEdit: () => _editItem(_items[i]),
          onDelete: () => _deleteItem(_items[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }
}

class _ItemFormResult {
  final String name;
  final String description;

  const _ItemFormResult({required this.name, required this.description});
}

class _ItemFormScreen extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;

  const _ItemFormScreen({
    this.initialName,
    this.initialDescription,
  });

  @override
  State<_ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<_ItemFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty || desc.isEmpty) {
      setState(() => _errorText = 'Vui lòng nhập đầy đủ tên và mô tả.');
      return;
    }
    Navigator.of(context).pop(_ItemFormResult(name: name, description: desc));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null || widget.initialDescription != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa dữ liệu' : 'Thêm dữ liệu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên',
                hintText: 'Nhập tên',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Nhập mô tả',
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

