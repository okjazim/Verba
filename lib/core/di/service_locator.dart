import 'package:get_it/get_it.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/data/repositories/sql_language_repository.dart';
import 'package:verba/data/repositories/sql_lesson_item_repository.dart';
import 'package:verba/data/repositories/sql_lesson_repository.dart';
import 'package:verba/data/repositories/sql_profile_repository.dart';
import 'package:verba/data/repositories/sql_review_data_repository.dart';
import 'package:verba/domain/repositories/language_repository.dart';
import 'package:verba/domain/repositories/lesson_item_repository.dart';
import 'package:verba/domain/repositories/lesson_repository.dart';
import 'package:verba/domain/repositories/profile_repository.dart';
import 'package:verba/domain/repositories/review_data_repository.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);

  sl.registerSingleton<LanguageRepository>(SqlLanguageRepository(db));
  sl.registerSingleton<LessonRepository>(SqlLessonRepository(db));
  sl.registerSingleton<LessonItemRepository>(SqlLessonItemRepository(db));
  sl.registerSingleton<ProfileRepository>(SqlProfileRepository(db));
  sl.registerSingleton<ReviewDataRepository>(SqlReviewDataRepository(db));
}
