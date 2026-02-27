import 'package:verba/core/models/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getAll();

  Future<List<Lesson>> getByLanguageId(String languageId);

  Future<Lesson?> getById(String id);

  Future<void> upsert(Lesson lesson);

  Future<void> delete(String id);
}

class InMemoryLessonRepository implements LessonRepository {
  final List<Lesson> _lessons = [];

  @override
  Future<List<Lesson>> getAll() async {
    return List<Lesson>.unmodifiable(_lessons);
  }

  @override
  Future<List<Lesson>> getByLanguageId(String languageId) async {
    return _lessons
        .where((l) => l.languageId == languageId)
        .toList(growable: false);
  }

  @override
  Future<Lesson?> getById(String id) async {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(Lesson lesson) async {
    final index = _lessons.indexWhere((l) => l.id == lesson.id);
    if (index == -1) {
      _lessons.add(lesson);
    } else {
      _lessons[index] = lesson;
    }
  }

  @override
  Future<void> delete(String id) async {
    _lessons.removeWhere((l) => l.id == id);
  }
}

