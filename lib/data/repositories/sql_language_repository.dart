import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/language.dart';
import 'package:verba/domain/repositories/language_repository.dart';

class SqlLanguageRepository implements LanguageRepository {
  final AppDatabase _db;

  SqlLanguageRepository(this._db);

  @override
  Future<List<Language>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('languages', orderBy: 'name ASC');
    return rows.map(Language.fromMap).toList();
  }

  @override
  Future<Language?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query('languages', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Language.fromMap(rows.first);
  }

  @override
  Future<void> upsert(Language language) async {
    final db = await _db.database;
    await db.insert(
      'languages',
      language.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('languages', where: 'id = ?', whereArgs: [id]);
  }
}
