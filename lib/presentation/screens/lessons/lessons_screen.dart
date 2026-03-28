import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/lesson.dart';
import 'package:verba/domain/repositories/lesson_repository.dart';
import 'package:verba/presentation/screens/items/lesson_items_screen.dart';
import 'package:verba/presentation/screens/practice/practice_screen.dart';

final lessonsProvider = FutureProvider.autoDispose.family<List<Lesson>, String>(
  (ref, languageId) {
    return sl<LessonRepository>().getByLanguageId(languageId);
  },
);

class LessonsScreen extends ConsumerStatefulWidget {
  final String languageId;
  final String languageName;

  const LessonsScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  Future<void> _showUpsertDialog({Lesson? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add lesson' : 'Edit lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'A1 Unit 1',
              ),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Common greetings',
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
      ),
    );

    if (result != true) return;

    final title = titleController.text.trim();
    final desc = descController.text.trim();
    if (title.isEmpty) return;

    final lesson = Lesson(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      languageId: widget.languageId,
      title: title,
      description: desc.isEmpty ? null : desc,
      sortOrder: existing?.sortOrder ?? 0,
    );

    await sl<LessonRepository>().upsert(lesson);
    if (!mounted) return;
    ref.invalidate(lessonsProvider(widget.languageId));
  }

  Future<void> _confirmDelete(Lesson lesson) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    if (result != true) return;

    await sl<LessonRepository>().delete(lesson.id);
    if (!mounted) return;
    ref.invalidate(lessonsProvider(widget.languageId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessonsAsync = ref.watch(lessonsProvider(widget.languageId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.languageName} lessons')),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (lessons) {
          if (lessons.isEmpty) {
            return const Center(
              child: Text(
                'No lessons yet.\nTap + to add your first lesson.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final a1 = lessons.where((l) => l.title.startsWith('A1 ')).toList();
          final a2 = lessons.where((l) => l.title.startsWith('A2 ')).toList();

          return CustomScrollView(
            slivers: [
              if (a1.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text('A1', style: theme.textTheme.titleLarge),
                  ),
                ),
                _UnitGrid(
                  lessons: a1,
                  onOpen: (lesson) => _openItems(lesson),
                  onPractice: (lesson) => _openPractice(lesson),
                ),
              ],
              if (a2.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text('A2', style: theme.textTheme.titleLarge),
                  ),
                ),
                _UnitGrid(
                  lessons: a2,
                  onOpen: (lesson) => _openItems(lesson),
                  onPractice: (lesson) => _openPractice(lesson),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpsertDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openItems(Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            LessonItemsScreen(lessonId: lesson.id, lessonTitle: lesson.title),
      ),
    );
  }

  void _openPractice(Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PracticeScreen(lessonId: lesson.id, lessonTitle: lesson.title),
      ),
    );
  }
}

class _UnitGrid extends StatelessWidget {
  final List<Lesson> lessons;
  final void Function(Lesson) onOpen;
  final void Function(Lesson) onPractice;

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
        delegate: SliverChildBuilderDelegate((context, index) {
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
                    color: Colors.black.withValues(alpha: 0.05),
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
        }, childCount: lessons.length),
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
