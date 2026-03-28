import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/core/database/app_database.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/data/seed/seed_data.dart';
import 'package:verba/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await SeedData.ensure(sl<AppDatabase>());
  runApp(const ProviderScope(child: VerbaApp()));
}
