import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../models/note.dart';

class NoteDatabase {
  NoteDatabase._privateConstructor();
  static final NoteDatabase instance = NoteDatabase._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes_category.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    await db.insert('categories', {'name': 'Công việc'});
    await db.insert('categories', {'name': 'Học tập'});
    await db.insert('categories', {'name': 'Cá nhân'});
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'id DESC');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getNotes({int? categoryId}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT notes.id, notes.title, notes.content, notes.categoryId, categories.name AS categoryName
      FROM notes
      INNER JOIN categories ON notes.categoryId = categories.id
      ${categoryId != null ? 'WHERE notes.categoryId = ?' : ''}
      ORDER BY notes.id DESC
    ''', categoryId != null ? [categoryId] : []);

    return result.map((e) => Note.fromMap(e)).toList();
  }
}