import 'package:verba/domain/models/language.dart';

abstract class LanguageRepository {
  Future<List<Language>> getAll();
  Future<Language?> getById(String id);
  Future<void> upsert(Language language);
  Future<void> delete(String id);
}
