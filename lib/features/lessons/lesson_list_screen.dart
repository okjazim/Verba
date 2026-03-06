import 'package:flutter/material.dart';

import 'package:verba/core/data/lesson_repository.dart';
import 'package:verba/core/models/lesson.dart';
import 'package:verba/features/items/lesson_items_screen.dart';
import 'package:verba/features/practice/practice_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String languageId;
  final String languageName;

  const LessonListScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonRepository _repository = InMemoryLessonRepository();
  List<Lesson> _lessons = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await _repository.getByLanguageId(widget.languageId);
    lessons.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _showUpsertLessonDialog({Lesson? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add lesson' : 'Edit lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Basics',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Common greetings and introductions',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim();
    if (title.isEmpty) return;

    final lesson = Lesson(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      languageId: widget.languageId,
      title: title,
      description: description,
      sortOrder: existing?.sortOrder ?? _lessons.length,
    );

    await _repository.upsert(lesson);
    await _loadLessons();
  }

  Future<void> _confirmDelete(Lesson lesson) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete lesson?'),
          content: Text('This will delete "${lesson.title}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (result != true) return;

    await _repository.delete(lesson.id);
    await _loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.languageName} lessons'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? const Center(
                  child: Text('No lessons yet. Add your first one!'),
                )
              : ListView.separated(
                  itemCount: _lessons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    return ListTile(
                      title: Text(lesson.title),
                      subtitle: (lesson.description ?? '').trim().isEmpty
                          ? null
                          : Text(lesson.description!),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LessonItemsScreen(
                              lessonId: lesson.id,
                              lessonTitle: lesson.title,
                            ),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Practice',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PracticeScreen(
                                    lessonId: lesson.id,
                                    lessonTitle: lesson.title,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(lesson),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUpsertLessonDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

