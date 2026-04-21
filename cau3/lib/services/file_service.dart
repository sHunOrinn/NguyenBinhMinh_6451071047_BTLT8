import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class FileService {
  static const String fileName = 'tasks_backup.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<String> getFilePath() async {
    final file = await _getFile();
    return file.path;
  }

  Future<void> exportTasks(List<Task> tasks) async {
    final file = await _getFile();
    final jsonData = tasks.map((task) => task.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<List<Task>> importTasks() async {
    final file = await _getFile();

    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(content);

    return jsonData
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}