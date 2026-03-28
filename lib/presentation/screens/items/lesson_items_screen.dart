import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/lesson_item.dart';
import 'package:verba/domain/repositories/lesson_item_repository.dart';

final lessonItemsProvider = FutureProvider.autoDispose
    .family<List<LessonItem>, String>((ref, lessonId) {
      return sl<LessonItemRepository>().getByLessonId(lessonId);
    });

class LessonItemsScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonItemsScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<LessonItemsScreen> createState() => _LessonItemsScreenState();
}

class _LessonItemsScreenState extends ConsumerState<LessonItemsScreen> {
  Future<void> _showUpsertDialog({LessonItem? existing}) async {
    final frontController = TextEditingController(text: existing?.front ?? '');
    final backController = TextEditingController(text: existing?.back ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    LessonItemType type = existing?.type ?? LessonItemType.word;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existing == null ? 'Add item' : 'Edit item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: frontController,
                      decoration: const InputDecoration(
                        labelText: 'Front',
                        hintText: 'hola',
                      ),
                    ),
                    TextField(
                      controller: backController,
                      decoration: const InputDecoration(
                        labelText: 'Back',
                        hintText: 'hello',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Type:'),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Word'),
                          selected: type == LessonItemType.word,
                          onSelected: (_) =>
                              setStateDialog(() => type = LessonItemType.word),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Phrase'),
                          selected: type == LessonItemType.phrase,
                          onSelected: (_) => setStateDialog(
                            () => type = LessonItemType.phrase,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Context or usage notes',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
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
      },
    );

    if (result != true) return;

    final front = frontController.text.trim();
    final back = backController.text.trim();
    final notes = notesController.text.trim();
    if (front.isEmpty || back.isEmpty) return;

    final item = LessonItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: widget.lessonId,
      type: type,
      front: front,
      back: back,
      notes: notes.isEmpty ? null : notes,
    );

    await sl<LessonItemRepository>().upsert(item);
    if (!mounted) return;
    ref.invalidate(lessonItemsProvider(widget.lessonId));
  }

  Future<void> _confirmDelete(LessonItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('This will delete "${item.front}".'),
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

    await sl<LessonItemRepository>().delete(item.id);
    if (!mounted) return;
    ref.invalidate(lessonItemsProvider(widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(lessonItemsProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.lessonTitle} items')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No items yet.\nTap + to add your first word or phrase.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.front),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.back),
                    if ((item.notes ?? '').trim().isNotEmpty)
                      Text(
                        item.notes!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
                onTap: () => _showUpsertDialog(existing: item),
                trailing: IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpsertDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
