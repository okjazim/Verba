import 'dart:convert';

enum LessonItemType { word, phrase }

class LessonItem {
  final String id;
  final String lessonId;
  final LessonItemType type;
  final String front;
  final String back;
  final String? notes;
  final List<String> tags;

  const LessonItem({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.front,
    required this.back,
    this.notes,
    this.tags = const [],
  });

  LessonItem copyWith({
    String? id,
    String? lessonId,
    LessonItemType? type,
    String? front,
    String? back,
    String? notes,
    List<String>? tags,
  }) {
    return LessonItem(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      front: front ?? this.front,
      back: back ?? this.back,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'type': type.name,
      'front': front,
      'back': back,
      'notes': notes,
      'tags': jsonEncode(tags),
    };
  }

  factory LessonItem.fromMap(Map<String, dynamic> map) {
    final tagsJson = map['tags'] as String? ?? '[]';
    final tagsList = jsonDecode(tagsJson) as List<dynamic>;
    return LessonItem(
      id: map['id'] as String,
      lessonId: map['lesson_id'] as String,
      type: LessonItemType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => LessonItemType.word,
      ),
      front: map['front'] as String,
      back: map['back'] as String,
      notes: map['notes'] as String?,
      tags: tagsList.map((e) => e as String).toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
