import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/lesson.dart';
import 'package:verba/domain/repositories/lesson_repository.dart';

class SqlLessonRepository implements LessonRepository {
  final AppDatabase _db;

  SqlLessonRepository(this._db);

  @override
  Future<List<Lesson>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('lessons', orderBy: 'sort_order ASC');
    return rows.map(Lesson.fromMap).toList();
  }

  @override
  Future<List<Lesson>> getByLanguageId(String languageId) async {
    final db = await _db.database;
    final rows = await db.query(
      'lessons',
      where: 'language_id = ?',
      whereArgs: [languageId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(Lesson.fromMap).toList();
  }

  @override
  Future<Lesson?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query('lessons', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Lesson.fromMap(rows.first);
  }

  @override
  Future<void> upsert(Lesson lesson) async {
    final db = await _db.database;
    await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }
}
