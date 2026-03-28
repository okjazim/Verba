import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'verba.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE languages (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        emoji TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        language_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE lesson_items (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'word',
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        notes TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY DEFAULT 0,
        name TEXT NOT NULL DEFAULT 'Learner',
        language_code TEXT NOT NULL DEFAULT 'es'
      )
    ''');

    await db.execute('''
      CREATE TABLE review_data (
        item_id TEXT PRIMARY KEY,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 0,
        next_review INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        last_quality INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES lesson_items(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
    }
  }
}
