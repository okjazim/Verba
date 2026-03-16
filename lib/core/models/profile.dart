class Profile {
  final String name;
  final String languageCode;

  const Profile({
    required this.name,
    required this.languageCode,
  });

  Profile copyWith({
    String? name,
    String? languageCode,
  }) {
    return Profile(
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'languageCode': languageCode,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String? ?? 'Learner',
      languageCode: json['languageCode'] as String? ?? 'es',
    );
  }
}

