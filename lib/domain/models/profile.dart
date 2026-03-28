class Profile {
  final String name;
  final String languageCode;

  const Profile({required this.name, required this.languageCode});

  Profile copyWith({String? name, String? languageCode}) {
    return Profile(
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'language_code': languageCode};
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      name: map['name'] as String? ?? 'Learner',
      languageCode: map['language_code'] as String? ?? 'es',
    );
  }

  static const empty = Profile(name: 'Learner', languageCode: 'es');
}
