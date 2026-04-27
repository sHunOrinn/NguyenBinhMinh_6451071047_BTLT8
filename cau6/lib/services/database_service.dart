import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dictionary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dictionary(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            meaning TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Kiểm tra database đã có dữ liệu chưa (để tránh import lại)
  Future<bool> isPopulated() async {
    final db = await database;
    final result =
    await db.rawQuery('SELECT COUNT(*) as cnt FROM dictionary');
    final count = result.first['cnt'] as int;
    return count > 0;
  }

  /// Bulk insert danh sách từ (dùng transaction để nhanh)
  Future<void> insertWords(List<Word> words) async {
    final db = await database;
    final batch = db.batch();
    for (final w in words) {
      batch.insert('dictionary', w.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  /// Tìm kiếm từ (LIKE, không phân biệt hoa thường)
  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    if (query.trim().isEmpty) {
      final maps =
      await db.query('dictionary', orderBy: 'word ASC', limit: 50);
      return maps.map((m) => Word.fromMap(m)).toList();
    }
    final maps = await db.query(
      'dictionary',
      where: 'word LIKE ?',
      whereArgs: ['%${query.trim()}%'],
      orderBy: 'word ASC',
      limit: 100,
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  /// Lấy tổng số từ trong DB
  Future<int> totalWords() async {
    final db = await database;
    final result =
    await db.rawQuery('SELECT COUNT(*) as cnt FROM dictionary');
    return result.first['cnt'] as int;
  }
}