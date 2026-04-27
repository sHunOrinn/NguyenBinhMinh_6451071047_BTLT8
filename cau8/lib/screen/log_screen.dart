import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/log_entry.dart';
import '../services/log_service.dart';
import '../widget/log_tile.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _logService = LogService();

  List<LogEntry> _logs = [];
  String _fileContent = '';
  String _filePath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final logs = await _logService.getLogs();
    final content = await _logService.readLogFile();
    final path = await _logService.getLogFilePath();
    if (mounted) {
      setState(() {
        _logs = logs;
        _fileContent = content;
        _filePath = path;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa toàn bộ log?'),
        content: const Text('Thao tác này sẽ xóa log trong DB và file text.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await _logService.clearAll();
      if (!mounted) return;
      _load();
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Nhật Ký Hoạt Động'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearLogs,
            tooltip: 'Xóa log',
            color: colorScheme.error,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
                icon: const Icon(Icons.list_alt_outlined),
                text: 'DB (${_logs.length})'),
            const Tab(
                icon: Icon(Icons.description_outlined),
                text: 'File text'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabs,
        children: [
          _buildDbTab(),
          _buildFileTab(colorScheme),
        ],
      ),
    );
  }

  Widget _buildDbTab() {
    if (_logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có log nào',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _logs.length,
      itemBuilder: (_, i) => LogTile(entry: _logs[i]),
    );
  }

  Widget _buildFileTab(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File path bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(Icons.folder_outlined,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _filePath,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _filePath));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã copy đường dẫn'),
                        duration: Duration(seconds: 1)),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),

        // File content - ScrollView
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _fileContent.isEmpty ? '(file log trống)' : _fileContent,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.6,
                color: _fileContent.isEmpty
                    ? Colors.grey
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}