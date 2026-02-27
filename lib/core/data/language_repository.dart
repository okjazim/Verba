import 'package:verba/core/models/language.dart';

abstract class LanguageRepository {
  Future<List<Language>> getAll();

  Future<Language?> getById(String id);

  Future<void> upsert(Language language);

  Future<void> delete(String id);
}

class InMemoryLanguageRepository implements LanguageRepository {
  final List<Language> _languages = [];

  @override
  Future<List<Language>> getAll() async {
    return List<Language>.unmodifiable(_languages);
  }

  @override
  Future<Language?> getById(String id) async {
    try {
      return _languages.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(Language language) async {
    final index = _languages.indexWhere((l) => l.id == language.id);
    if (index == -1) {
      _languages.add(language);
    } else {
      _languages[index] = language;
    }
  }

  @override
  Future<void> delete(String id) async {
    _languages.removeWhere((l) => l.id == id);
  }
}

