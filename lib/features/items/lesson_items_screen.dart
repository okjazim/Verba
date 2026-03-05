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

  Future<void> _loadItems() async {
    final items = await _repository.getByLessonId(widget.lessonId);
    setState(() {
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
              ? const Center(
                  child: Text('No items yet. We will add some next.'),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text(item.front),
                      subtitle: Text(item.back),
                      trailing: Text(
                        item.type == LessonItemType.word ? 'word' : 'phrase',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                ),
    );
  }
}

