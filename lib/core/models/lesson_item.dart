enum LessonItemType {
  word,
  phrase,
}

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'lessonId': lessonId,
      'type': type.name,
      'front': front,
      'back': back,
      'notes': notes,
      'tags': tags,
    };
  }

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: LessonItemType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => LessonItemType.word,
      ),
      front: json['front'] as String,
      back: json['back'] as String,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

