import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/data/verba_storage.dart';
import 'package:verba/core/models/lesson_item.dart';

abstract class LessonItemRepository {
  Future<List<LessonItem>> getByLessonId(String lessonId);

  Future<LessonItem?> getById(String id);

  Future<void> upsert(LessonItem item);

  Future<void> delete(String id);
}

class InMemoryLessonItemRepository implements LessonItemRepository {
  final VerbaStorage _storage = VerbaStorage();

  Future<VerbaData> _loadData() => _storage.load();

  Future<void> _saveData(VerbaData data) => _storage.save(data);

  @override
  Future<List<LessonItem>> getByLessonId(String lessonId) async {
    final data = await _loadData();
    return data.items
        .where((i) => i.lessonId == lessonId)
        .toList(growable: false);
  }

  @override
  Future<LessonItem?> getById(String id) async {
    final data = await _loadData();
    try {
      return data.items.firstWhere((i) => i.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(LessonItem item) async {
    final data = await _loadData();
    final items = List<LessonItem>.from(data.items);
    final index = items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await _saveData(data.copyWith(items: items));
  }

  @override
  Future<void> delete(String id) async {
    final data = await _loadData();
    final items = List<LessonItem>.from(data.items)
      ..removeWhere((i) => i.id == id);
    await _saveData(data.copyWith(items: items));
  }
}

