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

  Language copyWith({String? id, String? name, String? code, String? emoji}) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'code': code, 'emoji': emoji};
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      emoji: map['emoji'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
