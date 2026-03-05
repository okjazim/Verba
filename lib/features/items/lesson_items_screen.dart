import 'package:flutter/material.dart';

class LessonItemsScreen extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonItemsScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$lessonTitle items'),
      ),
      body: const Center(
        child: Text('Lesson items will appear here.'),
      ),
    );
  }
}

