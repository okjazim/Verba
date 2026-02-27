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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'languageId': languageId,
      'title': title,
      'description': description,
      'sortOrder': sortOrder,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      languageId: json['languageId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

