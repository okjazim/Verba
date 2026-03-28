class Lesson {
  final String id;
  final String languageId;
  final String title;
  final String? description;
  final int sortOrder;

  const Lesson({
    required this.id,
    required this.languageId,
    required this.title,
    this.description,
    this.sortOrder = 0,
  });

  Lesson copyWith({
    String? id,
    String? languageId,
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return Lesson(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language_id': languageId,
      'title': title,
      'description': description,
      'sort_order': sortOrder,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      languageId: map['language_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
