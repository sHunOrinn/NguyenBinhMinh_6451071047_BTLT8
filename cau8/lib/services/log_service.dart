import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/log_entry.dart';
import 'database_service.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final _db = DatabaseService();
  File? _logFile;

  Future<File> get logFile async {
    if (_logFile != null) return _logFile!;
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File(p.join(dir.path, 'activity_log.txt'));
    return _logFile!;
  }

  /// Ghi log: đồng thời lưu SQLite + append vào file text
  Future<LogEntry> log(String action) async {
    final now = DateTime.now();
    final timeStr =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';

    final entry = LogEntry(action: action, time: timeStr);

    // 1. Lưu vào SQLite
    await _db.insertLog(entry);

    // 2. Append vào file text
    try {
      final file = await logFile;
      await file.writeAsString(
        '${entry.toLogLine()}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      debugPrint('[LogService] File write error: $e');
    }

    return entry;
  }

  Future<List<LogEntry>> getLogs() => _db.getLogs();

  /// Đọc nội dung file log text thô
  Future<String> readLogFile() async {
    try {
      final file = await logFile;
      if (!await file.exists()) return '(file log chưa có dữ liệu)';
      return await file.readAsString();
    } catch (e) {
      return 'Lỗi đọc file: $e';
    }
  }

  /// Lấy đường dẫn file log
  Future<String> getLogFilePath() async {
    final file = await logFile;
    return file.path;
  }

  /// Xóa toàn bộ log
  Future<void> clearAll() async {
    await _db.clearLogs();
    try {
      final file = await logFile;
      if (await file.exists()) await file.delete();
      _logFile = null;
    } catch (e) {
      debugPrint('[LogService] Clear error: $e');
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}