import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/data/verba_storage.dart';
import 'package:verba/core/models/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getAll();

  Future<List<Lesson>> getByLanguageId(String languageId);

  Future<Lesson?> getById(String id);

  Future<void> upsert(Lesson lesson);

  Future<void> delete(String id);
}

class InMemoryLessonRepository implements LessonRepository {
  final VerbaStorage _storage = VerbaStorage();

  Future<VerbaData> _loadData() => _storage.load();

  Future<void> _saveData(VerbaData data) => _storage.save(data);

  @override
  Future<List<Lesson>> getAll() async {
    final data = await _loadData();
    return List<Lesson>.unmodifiable(data.lessons);
  }

  @override
  Future<List<Lesson>> getByLanguageId(String languageId) async {
    final data = await _loadData();
    return data.lessons
        .where((l) => l.languageId == languageId)
        .toList(growable: false);
  }

  @override
  Future<Lesson?> getById(String id) async {
    final data = await _loadData();
    try {
      return data.lessons.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(Lesson lesson) async {
    final data = await _loadData();
    final lessons = List<Lesson>.from(data.lessons);
    final index = lessons.indexWhere((l) => l.id == lesson.id);
    if (index == -1) {
      lessons.add(lesson);
    } else {
      lessons[index] = lesson;
    }
    await _saveData(data.copyWith(lessons: lessons));
  }

  @override
  Future<void> delete(String id) async {
    final data = await _loadData();
    final lessons = List<Lesson>.from(data.lessons)
      ..removeWhere((l) => l.id == id);
    await _saveData(data.copyWith(lessons: lessons));
  }
}

