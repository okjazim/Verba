import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/lesson_item.dart';
import 'package:verba/domain/repositories/lesson_item_repository.dart';

class SqlLessonItemRepository implements LessonItemRepository {
  final AppDatabase _db;

  SqlLessonItemRepository(this._db);

  @override
  Future<List<LessonItem>> getByLessonId(String lessonId) async {
    final db = await _db.database;
    final rows = await db.query(
      'lesson_items',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'front ASC',
    );
    return rows.map(LessonItem.fromMap).toList();
  }

  @override
  Future<LessonItem?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'lesson_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return LessonItem.fromMap(rows.first);
  }

  @override
  Future<void> upsert(LessonItem item) async {
    final db = await _db.database;
    await db.insert(
      'lesson_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('lesson_items', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> countByLessonId(String lessonId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lesson_items WHERE lesson_id = ?',
      [lessonId],
    );
    return (result.first['count'] as num).toInt();
  }
}
