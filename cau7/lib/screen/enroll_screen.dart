import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../services/database_service.dart';

class EnrollScreen extends StatefulWidget {
  final Student student;

  const EnrollScreen({super.key, required this.student});

  @override
  State<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  final _db = DatabaseService();
  List<Course> _allCourses = [];
  Set<int> _selected = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final courses = await _db.getCourses();
    final enrolled = await _db.getEnrolledCourseIds(widget.student.id!);
    setState(() {
      _allCourses = courses;
      _selected = enrolled;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await _db.updateEnrollments(widget.student.id!, _selected);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đăng ký môn - ${widget.student.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save_rounded),
            label: const Text('Lưu'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    widget.student.name[0],
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Đã chọn ${_selected.length}/${_allCourses.length} môn',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Course list with CheckboxListTile
          Expanded(
            child: ListView.builder(
              itemCount: _allCourses.length,
              itemBuilder: (context, i) {
                final course = _allCourses[i];
                final checked = _selected.contains(course.id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selected.add(course.id!);
                      } else {
                        _selected.remove(course.id);
                      }
                    });
                  },
                  title: Text(
                    course.name,
                    style: TextStyle(
                      fontWeight: checked
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  secondary: CircleAvatar(
                    radius: 18,
                    backgroundColor: checked
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.menu_book_outlined,
                      size: 16,
                      color: checked
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: checked
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}