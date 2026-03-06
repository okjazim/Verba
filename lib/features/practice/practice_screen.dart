import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;

  const PracticeScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice: $lessonTitle'),
      ),
      body: const Center(
        child: Text('Flashcard practice will go here.'),
      ),
    );
  }
}

