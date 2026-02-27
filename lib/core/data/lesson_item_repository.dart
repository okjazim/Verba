import 'package:verba/core/models/lesson_item.dart';

abstract class LessonItemRepository {
  Future<List<LessonItem>> getByLessonId(String lessonId);

  Future<LessonItem?> getById(String id);

  Future<void> upsert(LessonItem item);

  Future<void> delete(String id);
}

class InMemoryLessonItemRepository implements LessonItemRepository {
  final List<LessonItem> _items = [];

  @override
  Future<List<LessonItem>> getByLessonId(String lessonId) async {
    return _items
        .where((i) => i.lessonId == lessonId)
        .toList(growable: false);
  }

  @override
  Future<LessonItem?> getById(String id) async {
    try {
      return _items.firstWhere((i) => i.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(LessonItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}

