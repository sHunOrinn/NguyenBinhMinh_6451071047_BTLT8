import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';

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
    final path = p.join(await getDatabasesPath(), 'student_mgmt.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE students(
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE courses(
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE enrollments(
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId INTEGER NOT NULL,
            courseId  INTEGER NOT NULL,
            FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE,
            FOREIGN KEY (courseId)  REFERENCES courses(id)  ON DELETE CASCADE,
            UNIQUE (studentId, courseId)
          )''');

        // Seed data mẫu
        for (final name in ['Nguyễn Văn An', 'Trần Thị Bình', 'Lê Văn Cường', 'Phạm Thị Dung']) {
          await db.insert('students', {'name': name});
        }
        for (final name in ['Toán cao cấp', 'Vật lý đại cương', 'Lập trình Flutter', 'Cơ sở dữ liệu', 'Mạng máy tính']) {
          await db.insert('courses', {'name': name});
        }
      },
    );
  }

  // ── STUDENTS ──────────────────────────────────────────
  Future<List<Student>> getStudents() async {
    final db = await database;
    final maps = await db.query('students', orderBy: 'name ASC');
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  Future<int> insertStudent(Student s) async {
    final db = await database;
    return await db.insert('students', s.toMap());
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ── COURSES ───────────────────────────────────────────
  Future<List<Course>> getCourses() async {
    final db = await database;
    final maps = await db.query('courses', orderBy: 'name ASC');
    return maps.map((m) => Course.fromMap(m)).toList();
  }

  Future<int> insertCourse(Course c) async {
    final db = await database;
    return await db.insert('courses', c.toMap());
  }

  Future<void> deleteCourse(int id) async {
    final db = await database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // ── ENROLLMENTS ───────────────────────────────────────
  /// Danh sách môn học của 1 sinh viên
  Future<List<Course>> getCoursesOfStudent(int studentId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.* FROM courses c
      INNER JOIN enrollments e ON c.id = e.courseId
      WHERE e.studentId = ?
      ORDER BY c.name ASC
    ''', [studentId]);
    return maps.map((m) => Course.fromMap(m)).toList();
  }

  /// Danh sách sinh viên của 1 môn
  Future<List<Student>> getStudentsOfCourse(int courseId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT s.* FROM students s
      INNER JOIN enrollments e ON s.id = e.studentId
      WHERE e.courseId = ?
      ORDER BY s.name ASC
    ''', [courseId]);
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  /// Set of courseId mà sinh viên đã đăng ký
  Future<Set<int>> getEnrolledCourseIds(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'enrollments',
      columns: ['courseId'],
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((m) => m['courseId'] as int).toSet();
  }

  Future<void> enroll(int studentId, int courseId) async {
    final db = await database;
    await db.insert(
      'enrollments',
      Enrollment(studentId: studentId, courseId: courseId).toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unenroll(int studentId, int courseId) async {
    final db = await database;
    await db.delete(
      'enrollments',
      where: 'studentId = ? AND courseId = ?',
      whereArgs: [studentId, courseId],
    );
  }

  /// Cập nhật toàn bộ đăng ký của sinh viên theo danh sách mới
  Future<void> updateEnrollments(int studentId, Set<int> courseIds) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('enrollments',
          where: 'studentId = ?', whereArgs: [studentId]);
      for (final cid in courseIds) {
        await txn.insert(
          'enrollments',
          {'studentId': studentId, 'courseId': cid},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}