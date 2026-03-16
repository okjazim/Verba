import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/models/language.dart';
import 'package:verba/core/models/lesson.dart';
import 'package:verba/core/models/lesson_item.dart';

class VerbaSeed {
  static VerbaData defaultData() {
    const spanish = Language(id: 'lang_es', name: 'Spanish', code: 'es', emoji: '🇪🇸');
    const german = Language(id: 'lang_de', name: 'German', code: 'de', emoji: '🇩🇪');

    final lessons = <Lesson>[
      ..._seedLessonsFor(spanish),
      ..._seedLessonsFor(german),
    ];

    final items = <LessonItem>[
      ..._seedItemsFor(language: spanish, level: 'A1', unit: 1),
      ..._seedItemsFor(language: spanish, level: 'A1', unit: 2),
      ..._seedItemsFor(language: german, level: 'A1', unit: 1),
      ..._seedItemsFor(language: german, level: 'A1', unit: 2),
    ];

    return VerbaData(
      languages: const [spanish, german],
      lessons: lessons,
      items: items,
    );
  }

  static Iterable<Lesson> _seedLessonsFor(Language language) sync* {
    const levels = ['A1', 'A2'];
    for (var levelIndex = 0; levelIndex < levels.length; levelIndex++) {
      final level = levels[levelIndex];
      for (var unit = 1; unit <= 50; unit++) {
        final sortOrder = levelIndex * 50 + (unit - 1);
        yield Lesson(
          id: '${language.code}_${level}_$unit',
          languageId: language.id,
          title: '$level Unit $unit',
          sortOrder: sortOrder,
        );
      }
    }
  }

  static Iterable<LessonItem> _seedItemsFor({
    required Language language,
    required String level,
    required int unit,
  }) sync* {
    final lessonId = '${language.code}_${level}_$unit';
    final pairs = <(String, String)>[];

    if (language.code == 'es' && level == 'A1' && unit == 1) {
      pairs.addAll([
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
      ]);
    } else if (language.code == 'es' && level == 'A1' && unit == 2) {
      pairs.addAll([
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
      ]);
    } else if (language.code == 'de' && level == 'A1' && unit == 1) {
      pairs.addAll([
        ('hallo', 'hello'),
        ('tschüss', 'bye'),
        ('bitte', 'please'),
        ('danke', 'thank you'),
        ('ja', 'yes'),
        ('nein', 'no'),
        ('guten Morgen', 'good morning'),
        ('gute Nacht', 'good night'),
        ('wie geht\'s?', 'how are you?'),
        ('es tut mir leid', 'sorry'),
      ]);
    } else if (language.code == 'de' && level == 'A1' && unit == 2) {
      pairs.addAll([
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
      ]);
    }

    for (var i = 0; i < pairs.length; i++) {
      final pair = pairs[i];
      yield LessonItem(
        id: '${lessonId}_$i',
        lessonId: lessonId,
        type: LessonItemType.phrase,
        front: pair.$1,
        back: pair.$2,
      );
    }
  }
}

