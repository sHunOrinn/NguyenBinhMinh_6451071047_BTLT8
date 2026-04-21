import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
  const EmptyTask({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chưa có task nào',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}