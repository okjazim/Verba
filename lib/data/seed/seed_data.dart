import 'package:sqflite/sqflite.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/domain/models/language.dart';
import 'package:verba/domain/models/lesson.dart';
import 'package:verba/domain/models/lesson_item.dart';

class SeedData {
  static Future<void> ensure(AppDatabase db) async {
    final conn = await db.database;
    final count = Sqflite.firstIntValue(
      await conn.rawQuery('SELECT COUNT(*) FROM languages'),
    );
    if (count != null && count > 0) return;

    await _seed(conn);
  }

  static Future<void> _seed(Database db) async {
    const spanish = Language(
      id: 'lang_es',
      name: 'Spanish',
      code: 'es',
      emoji: '🇪🇸',
    );
    const german = Language(
      id: 'lang_de',
      name: 'German',
      code: 'de',
      emoji: '🇩🇪',
    );

    for (final lang in [spanish, german]) {
      await db.insert('languages', lang.toMap());
    }

    for (final lang in [spanish, german]) {
      for (final level in ['A1', 'A2']) {
        for (var unit = 1; unit <= 50; unit++) {
          final levelIndex = level == 'A1' ? 0 : 1;
          final sortOrder = levelIndex * 50 + (unit - 1);
          final lesson = Lesson(
            id: '${lang.code}_${level}_$unit',
            languageId: lang.id,
            title: '$level Unit $unit',
            sortOrder: sortOrder,
          );
          await db.insert('lessons', lesson.toMap());
        }
      }
    }

    final seedItems = _buildSeedItems();
    for (final item in seedItems) {
      await db.insert('lesson_items', item.toMap());
    }
  }

  static List<LessonItem> _buildSeedItems() {
    final items = <LessonItem>[];

    void addItems(
      String langCode,
      String level,
      int unit,
      List<(String, String)> pairs,
    ) {
      final lessonId = '${langCode}_${level}_$unit';
      for (var i = 0; i < pairs.length; i++) {
        items.add(
          LessonItem(
            id: '${lessonId}_$i',
            lessonId: lessonId,
            type: LessonItemType.phrase,
            front: pairs[i].$1,
            back: pairs[i].$2,
          ),
        );
      }
    }

    addItems('es', 'A1', 1, [
      ('hola', 'hello'),
      ('adiós', 'goodbye'),
      ('por favor', 'please'),
      ('gracias', 'thank you'),
      ('sí', 'yes'),
      ('no', 'no'),
      ('buenos días', 'good morning'),
      ('buenas noches', 'good night'),
      ('¿cómo estás?', 'how are you?'),
      ('lo siento', 'sorry'),
      ('de nada', "you're welcome"),
      ('buenas tardes', 'good afternoon'),
      ('hasta luego', 'see you later'),
      ('mucho gusto', 'nice to meet you'),
      ('perdón', 'excuse me'),
    ]);

    addItems('es', 'A1', 2, [
      ('yo', 'I'),
      ('tú', 'you'),
      ('él', 'he'),
      ('ella', 'she'),
      ('nosotros', 'we'),
      ('ustedes', 'you (plural)'),
      ('ellos', 'they'),
      ('mi nombre es...', 'my name is...'),
      ('¿de dónde eres?', 'where are you from?'),
      ('soy de...', 'I am from...'),
      ('¿cuántos años tienes?', 'how old are you?'),
      ('tengo ... años', 'I am ... years old'),
      ('¿dónde vives?', 'where do you live?'),
      ('vivo en...', 'I live in...'),
      ('¿qué haces?', 'what do you do?'),
    ]);

    addItems('de', 'A1', 1, [
      ('hallo', 'hello'),
      ('tschüss', 'bye'),
      ('bitte', 'please'),
      ('danke', 'thank you'),
      ('ja', 'yes'),
      ('nein', 'no'),
      ('guten Morgen', 'good morning'),
      ('gute Nacht', 'good night'),
      ("wie geht's?", 'how are you?'),
      ('es tut mir leid', 'sorry'),
      ('bitte schön', "you're welcome"),
      ('guten Tag', 'good day'),
      ('bis bald', 'see you soon'),
      ('freut mich', 'nice to meet you'),
      ('Entschuldigung', 'excuse me'),
    ]);

    addItems('de', 'A1', 2, [
      ('ich', 'I'),
      ('du', 'you'),
      ('er', 'he'),
      ('sie', 'she'),
      ('wir', 'we'),
      ('ihr', 'you (plural)'),
      ('sie', 'they'),
      ('ich heiße...', 'my name is...'),
      ('woher kommst du?', 'where are you from?'),
      ('ich komme aus...', 'I am from...'),
      ('wie alt bist du?', 'how old are you?'),
      ('ich bin ... Jahre alt', 'I am ... years old'),
      ('wo wohnst du?', 'where do you live?'),
      ('ich wohne in...', 'I live in...'),
      ('was machst du?', 'what do you do?'),
    ]);

    return items;
  }
}
