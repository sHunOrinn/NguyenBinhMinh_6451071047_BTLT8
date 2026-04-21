import 'package:flutter/material.dart';

class EmptyNotes extends StatelessWidget {
  const EmptyNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chưa có ghi chú nào',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}