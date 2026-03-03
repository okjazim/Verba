import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/data/verba_storage.dart';
import 'package:verba/core/models/language.dart';

abstract class LanguageRepository {
  Future<List<Language>> getAll();

  Future<Language?> getById(String id);

  Future<void> upsert(Language language);

  Future<void> delete(String id);
}

class InMemoryLanguageRepository implements LanguageRepository {
  final VerbaStorage _storage = VerbaStorage();

  Future<VerbaData> _loadData() => _storage.load();

  Future<void> _saveData(VerbaData data) => _storage.save(data);

  @override
  Future<List<Language>> getAll() async {
    final data = await _loadData();
    return List<Language>.unmodifiable(data.languages);
  }

  @override
  Future<Language?> getById(String id) async {
    final data = await _loadData();
    try {
      return data.languages.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsert(Language language) async {
    final data = await _loadData();
    final languages = List<Language>.from(data.languages);
    final index = languages.indexWhere((l) => l.id == language.id);
    if (index == -1) {
      languages.add(language);
    } else {
      languages[index] = language;
    }
    await _saveData(data.copyWith(languages: languages));
  }

  @override
  Future<void> delete(String id) async {
    final data = await _loadData();
    final languages = List<Language>.from(data.languages)
      ..removeWhere((l) => l.id == id);
    await _saveData(data.copyWith(languages: languages));
  }
}

