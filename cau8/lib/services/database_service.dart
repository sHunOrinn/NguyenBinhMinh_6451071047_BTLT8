import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/item.dart';
import '../models/log_entry.dart';

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
    final path = p.join(await getDatabasesPath(), 'activity_log.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE items(
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT NOT NULL,
            description TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE logs(
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            time   TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final maps = await db.query('items', orderBy: 'id DESC');
    return maps.map((m) => Item.fromMap(m)).toList();
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update('items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertLog(LogEntry entry) async {
    final db = await database;
    await db.insert('logs', entry.toMap());
  }

  Future<List<LogEntry>> getLogs() async {
    final db = await database;
    final maps = await db.query('logs', orderBy: 'id DESC');
    return maps.map((m) => LogEntry.fromMap(m)).toList();
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}