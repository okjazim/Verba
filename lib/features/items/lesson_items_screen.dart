import 'package:flutter/material.dart';

import 'package:verba/core/data/lesson_item_repository.dart';
import 'package:verba/core/models/lesson_item.dart';

class LessonItemsScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonItemsScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonItemsScreen> createState() => _LessonItemsScreenState();
}

class _LessonItemsScreenState extends State<LessonItemsScreen> {
  final LessonItemRepository _repository = InMemoryLessonItemRepository();
  List<LessonItem> _items = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _showUpsertItemDialog({LessonItem? existing}) async {
    final frontController =
        TextEditingController(text: existing?.front ?? '');
    final backController = TextEditingController(text: existing?.back ?? '');
    final notesController =
        TextEditingController(text: existing?.notes ?? '');
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
                          onSelected: (_) =>
                              setStateDialog(() => type = LessonItemType.phrase),
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
    final notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    if (front.isEmpty || back.isEmpty) return;

    final item = LessonItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: widget.lessonId,
      type: type,
      front: front,
      back: back,
      notes: notes,
    );

    await _repository.upsert(item);
    await _loadItems();
  }

  Future<void> _confirmDeleteItem(LessonItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item?'),
          content: Text('This will delete \"${item.front}\".'),
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

    await _repository.delete(item.id);
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getByLessonId(widget.lessonId);
    setState(() {
      items.sort((a, b) => a.front.toLowerCase().compareTo(b.front.toLowerCase()));
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lessonTitle} items'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'No items yet.\nTap + to add your first word or phrase.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item.front),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.back),
                          if ((item.notes ?? '').trim().isNotEmpty)
                            Text(
                              item.notes!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () => _showUpsertItemDialog(existing: item),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteItem(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUpsertItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

