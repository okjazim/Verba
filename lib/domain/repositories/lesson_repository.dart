import 'package:verba/domain/models/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getAll();
  Future<List<Lesson>> getByLanguageId(String languageId);
  Future<Lesson?> getById(String id);
  Future<void> upsert(Lesson lesson);
  Future<void> delete(String id);
}
