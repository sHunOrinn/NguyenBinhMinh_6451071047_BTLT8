import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../services/database_service.dart';
import 'enroll_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _db = DatabaseService();
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final courses = await _db.getCoursesOfStudent(widget.student.id!);
    if (mounted) setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  Future<void> _goEnroll() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => EnrollScreen(student: widget.student)),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Chưa đăng ký môn nào',
                style:
                TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _goEnroll,
              icon: const Icon(Icons.add),
              label: const Text('Đăng ký môn'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _courses.length,
        itemBuilder: (context, i) {
          final c = _courses[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color:
                  colorScheme.outlineVariant.withOpacity(0.4)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold)),
              ),
              title: Text(c.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goEnroll,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Sửa đăng ký'),
      ),
    );
  }
}