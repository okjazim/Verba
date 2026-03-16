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
    final a1 = _lessons.where((l) => l.title.startsWith('A1 ')).toList();
    final a2 = _lessons.where((l) => l.title.startsWith('A2 ')).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.languageName} lessons'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(
                  child: Text(
                    'No lessons yet.\nTap + to add your first lesson.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    if (a1.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text('A1', style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ),
                      _UnitGrid(
                        lessons: a1,
                        onOpen: (lesson) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LessonItemsScreen(
                                lessonId: lesson.id,
                                lessonTitle: lesson.title,
                              ),
                            ),
                          );
                        },
                        onPractice: (lesson) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PracticeScreen(
                                lessonId: lesson.id,
                                lessonTitle: lesson.title,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (a2.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text('A2', style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ),
                      _UnitGrid(
                        lessons: a2,
                        onOpen: (lesson) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LessonItemsScreen(
                                lessonId: lesson.id,
                                lessonTitle: lesson.title,
                              ),
                            ),
                          );
                        },
                        onPractice: (lesson) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PracticeScreen(
                                lessonId: lesson.id,
                                lessonTitle: lesson.title,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUpsertLessonDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _UnitGrid extends StatelessWidget {
  final List<Lesson> lessons;
  final void Function(Lesson lesson) onOpen;
  final void Function(Lesson lesson) onPractice;

  const _UnitGrid({
    required this.lessons,
    required this.onOpen,
    required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = lessons[index];
            final unitNumber = _parseUnitNumber(lesson.title) ?? (index + 1);
            return InkWell(
              onTap: () => onOpen(lesson),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '$unitNumber',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: IconButton(
                        tooltip: 'Practice',
                        onPressed: () => onPractice(lesson),
                        icon: const Icon(Icons.play_arrow),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: lessons.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
      ),
    );
  }

  int? _parseUnitNumber(String title) {
    final match = RegExp(r'Unit\s+(\d+)$').firstMatch(title);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}

