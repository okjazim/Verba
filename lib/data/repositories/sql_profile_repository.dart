import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/profile.dart';
import 'package:verba/domain/repositories/profile_repository.dart';

class SqlProfileRepository implements ProfileRepository {
  final AppDatabase _db;

  SqlProfileRepository(this._db);

  @override
  Future<Profile> get() async {
    final db = await _db.database;
    final rows = await db.query('profiles', where: 'id = 0');
    if (rows.isEmpty) {
      await db.insert('profiles', Profile.empty.toMap());
      return Profile.empty;
    }
    return Profile.fromMap(rows.first);
  }

  @override
  Future<void> save(Profile profile) async {
    final db = await _db.database;
    await db.insert('profiles', {
      'id': 0,
      ...profile.toMap(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
