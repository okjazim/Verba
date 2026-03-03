import 'package:verba/core/models/language.dart';
import 'package:verba/core/models/lesson.dart';
import 'package:verba/core/models/lesson_item.dart';

class VerbaData {
  final List<Language> languages;
  final List<Lesson> lessons;
  final List<LessonItem> items;

  const VerbaData({
    this.languages = const [],
    this.lessons = const [],
    this.items = const [],
  });

  VerbaData copyWith({
    List<Language>? languages,
    List<Lesson>? lessons,
    List<LessonItem>? items,
  }) {
    return VerbaData(
      languages: languages ?? this.languages,
      lessons: lessons ?? this.lessons,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'languages': languages.map((e) => e.toJson()).toList(),
      'lessons': lessons.map((e) => e.toJson()).toList(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory VerbaData.fromJson(Map<String, dynamic> json) {
    return VerbaData(
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessons: (json['lessons'] as List<dynamic>? ?? const [])
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => LessonItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

