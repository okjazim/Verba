import 'package:verba/domain/models/review_data.dart';

abstract class ReviewDataRepository {
  Future<ReviewData?> getByItemId(String itemId);
  Future<Map<String, ReviewData>> getByLessonId(String lessonId);
  Future<void> upsert(ReviewData data);
  Future<void> delete(String itemId);
  Future<List<String>> getDueItemIds(String lessonId);
}
