import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../services/database_service.dart';
import '../widget/student_card.dart';
import '../widget/course_card.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = DatabaseService();

  List<Student> _students = [];
  List<Course> _courses = [];
  // cache số lượng
  Map<int, int> _courseCountPerStudent = {};
  Map<int, int> _studentCountPerCourse = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final students = await _db.getStudents();
    final courses = await _db.getCourses();

    // Đếm môn của từng sinh viên
    final Map<int, int> ccps = {};
    for (final s in students) {
      final ids = await _db.getEnrolledCourseIds(s.id!);
      ccps[s.id!] = ids.length;
    }
    // Đếm sinh viên của từng môn
    final Map<int, int> scpc = {};
    for (final c in courses) {
      final sv = await _db.getStudentsOfCourse(c.id!);
      scpc[c.id!] = sv.length;
    }

    if (mounted) {
      setState(() {
        _students = students;
        _courses = courses;
        _courseCountPerStudent = ccps;
        _studentCountPerCourse = scpc;
        _isLoading = false;
      });
    }
  }

  // ── Thêm sinh viên ────────────────────────────────────
  Future<void> _addStudent() async {
    final name = await _showInputDialog('Thêm sinh viên', 'Nhập tên sinh viên');
    if (name == null || name.trim().isEmpty) return;
    await _db.insertStudent(Student(name: name.trim()));
    _loadAll();
  }

  // ── Thêm môn học ──────────────────────────────────────
  Future<void> _addCourse() async {
    final name = await _showInputDialog('Thêm môn học', 'Nhập tên môn học');
    if (name == null || name.trim().isEmpty) return;
    await _db.insertCourse(Course(name: name.trim()));
    _loadAll();
  }

  Future<void> _deleteStudent(Student s) async {
    final ok = await _confirmDialog('Xóa sinh viên "${s.name}"?');
    if (ok == true) {
      await _db.deleteStudent(s.id!);
      _loadAll();
    }
  }

  Future<void> _deleteCourse(Course c) async {
    final ok = await _confirmDialog('Xóa môn học "${c.name}"?');
    if (ok == true) {
      await _db.deleteCourse(c.id!);
      _loadAll();
    }
  }

  Future<String?> _showInputDialog(String title, String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Thêm')),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: const Text(
          '🎓 Quản Lý Sinh Viên\nNguyễn Bình Minh - 6451071047',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_outline),
              text: 'Sinh viên (${_students.length})',
            ),
            Tab(
              icon: const Icon(Icons.menu_book_outlined),
              text: 'Môn học (${_courses.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStudentTab(),
          _buildCourseTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _addStudent();
          } else {
            _addCourse();
          }
        },
        icon: const Icon(Icons.add),
        label: AnimatedBuilder(
          animation: _tabController,
          builder: (_, __) => Text(
            _tabController.index == 0 ? 'Thêm sinh viên' : 'Thêm môn học',
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTab() {
    if (_students.isEmpty) {
      return const Center(
        child: Text('Chưa có sinh viên nào.\nNhấn + để thêm.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _students.length,
        itemBuilder: (context, i) {
          final s = _students[i];
          return StudentCard(
            student: s,
            courseCount: _courseCountPerStudent[s.id] ?? 0,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StudentDetailScreen(student: s)),
              );
              _loadAll();
            },
            onDelete: () => _deleteStudent(s),
          );
        },
      ),
    );
  }

  Widget _buildCourseTab() {
    if (_courses.isEmpty) {
      return const Center(
        child: Text('Chưa có môn học nào.\nNhấn + để thêm.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _courses.length,
        itemBuilder: (context, i) {
          final c = _courses[i];
          return CourseCard(
            course: c,
            studentCount: _studentCountPerCourse[c.id] ?? 0,
            onTap: () {}, // có thể mở màn hình chi tiết môn
            onDelete: () => _deleteCourse(c),
          );
        },
      ),
    );
  }
}