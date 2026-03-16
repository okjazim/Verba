import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/models/language.dart';
import 'package:verba/core/models/lesson.dart';

class VerbaSeed {
  static VerbaData defaultData() {
    const spanish = Language(id: 'lang_es', name: 'Spanish', code: 'es', emoji: '🇪🇸');
    const german = Language(id: 'lang_de', name: 'German', code: 'de', emoji: '🇩🇪');

    final lessons = <Lesson>[
      ..._seedLessonsFor(spanish),
      ..._seedLessonsFor(german),
    ];

    return VerbaData(
      languages: const [spanish, german],
      lessons: lessons,
      items: const [],
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
}

