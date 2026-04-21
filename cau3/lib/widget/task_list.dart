import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task task, bool value) onChanged;
  final Function(Task task) onDelete;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onChanged: (value) => onChanged(task, value),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}