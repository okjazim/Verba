class Language {
  final String id;
  final String name;
  final String code;
  final String? emoji;

  const Language({
    required this.id,
    required this.name,
    required this.code,
    this.emoji,
  });

  Language copyWith({
    String? id,
    String? name,
    String? code,
    String? emoji,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'code': code,
      'emoji': emoji,
    };
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      emoji: json['emoji'] as String?,
    );
  }
}

