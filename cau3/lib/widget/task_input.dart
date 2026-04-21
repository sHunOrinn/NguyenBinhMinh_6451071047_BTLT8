import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final Function(String title) onAdd;

  const TaskInput({
    super.key,
    required this.onAdd,
  });

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    widget.onAdd(title);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nhập task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}