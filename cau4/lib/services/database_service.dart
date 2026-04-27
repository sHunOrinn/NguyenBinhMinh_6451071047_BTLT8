import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/expense.dart';

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
    final path = join(dbPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        note TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Seed default categories
    final defaultCategories = [
      'Ăn uống',
      'Di chuyển',
      'Mua sắm',
      'Giải trí',
      'Sức khỏe',
      'Giáo dục',
      'Khác',
    ];
    for (final name in defaultCategories) {
      await db.insert('categories', {'name': name});
    }
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT e.*, c.name AS categoryName
      FROM expenses e
      INNER JOIN categories c ON e.categoryId = c.id
      ORDER BY e.id DESC
    ''');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSummaryByCategory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.name AS categoryName, SUM(e.amount) AS total
      FROM expenses e
      INNER JOIN categories c ON e.categoryId = c.id
      GROUP BY e.categoryId
      ORDER BY total DESC
    ''');
  }
}