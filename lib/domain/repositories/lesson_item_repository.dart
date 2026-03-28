import 'package:verba/domain/models/lesson_item.dart';

abstract class LessonItemRepository {
  Future<List<LessonItem>> getByLessonId(String lessonId);
  Future<LessonItem?> getById(String id);
  Future<void> upsert(LessonItem item);
  Future<void> delete(String id);
  Future<int> countByLessonId(String lessonId);
}
