import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/review_data.dart';
import 'package:verba/domain/repositories/review_data_repository.dart';

class SqlReviewDataRepository implements ReviewDataRepository {
  final AppDatabase _db;

  SqlReviewDataRepository(this._db);

  @override
  Future<ReviewData?> getByItemId(String itemId) async {
    final db = await _db.database;
    final rows = await db.query(
      'review_data',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    if (rows.isEmpty) return null;
    return ReviewData.fromMap(rows.first);
  }

  @override
  Future<Map<String, ReviewData>> getByLessonId(String lessonId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT rd.* FROM review_data rd
      INNER JOIN lesson_items li ON rd.item_id = li.id
      WHERE li.lesson_id = ?
    ''',
      [lessonId],
    );
    final map = <String, ReviewData>{};
    for (final row in rows) {
      final data = ReviewData.fromMap(row);
      map[data.itemId] = data;
    }
    return map;
  }

  @override
  Future<void> upsert(ReviewData data) async {
    final db = await _db.database;
    await db.insert(
      'review_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String itemId) async {
    final db = await _db.database;
    await db.delete('review_data', where: 'item_id = ?', whereArgs: [itemId]);
  }

  @override
  Future<List<String>> getDueItemIds(String lessonId) async {
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final rows = await db.rawQuery(
      '''
      SELECT rd.item_id FROM review_data rd
      INNER JOIN lesson_items li ON rd.item_id = li.id
      WHERE li.lesson_id = ? AND rd.next_review <= ?
      ORDER BY rd.next_review ASC
    ''',
      [lessonId, now],
    );
    return rows.map((r) => r['item_id'] as String).toList();
  }
}
