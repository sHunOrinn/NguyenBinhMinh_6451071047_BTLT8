import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/file_service.dart';
import '../services/task_database.dart';
import '../widget/empty_task.dart';
import '../widget/task_input.dart';
import '../widget/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();

  List<Task> tasks = [];
  bool isLoading = true;
  String backupPath = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadTasks();
    final path = await _fileService.getFilePath();
    setState(() {
      backupPath = path;
    });
  }

  Future<void> _loadTasks() async {
    final data = await TaskDatabase.instance.getAllTasks();
    setState(() {
      tasks = data;
      isLoading = false;
    });
  }

  Future<void> _addTask(String title) async {
    await TaskDatabase.instance.insertTask(
      Task(title: title, isDone: false),
    );
    await _loadTasks();
  }

  Future<void> _toggleTask(Task task, bool value) async {
    await TaskDatabase.instance.updateTask(
      task.copyWith(isDone: value),
    );
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id != null) {
      await TaskDatabase.instance.deleteTask(task.id!);
      await _loadTasks();
    }
  }

  Future<void> _exportJson() async {
    await _fileService.exportTasks(tasks);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export thành công: $backupPath'),
      ),
    );
  }

  Future<void> _importJson() async {
    final importedTasks = await _fileService.importTasks();

    if (importedTasks.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy file JSON để import'),
        ),
      );
      return;
    }

    await TaskDatabase.instance.replaceAllTasks(importedTasks);
    await _loadTasks();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import thành công'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do list'),
        actions: [
          IconButton(
            onPressed: _exportJson,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Export JSON',
          ),
          IconButton(
            onPressed: _importJson,
            icon: const Icon(Icons.download),
            tooltip: 'Import JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          TaskInput(onAdd: _addTask),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? const EmptyTask()
                : TaskList(
              tasks: tasks,
              onChanged: _toggleTask,
              onDelete: _deleteTask,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              backupPath.isEmpty
                  ? ''
                  : 'File JSON: $backupPath',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Text('Nguyễn Bình Minh - 6451071047'),
        ],
      ),
    );
  }
}