import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/language.dart';
import 'package:verba/domain/models/profile.dart';
import 'package:verba/domain/repositories/language_repository.dart';
import 'package:verba/domain/repositories/profile_repository.dart';
import 'package:verba/presentation/screens/lessons/lessons_screen.dart';
import 'package:verba/presentation/screens/practice/practice_screen.dart';
import 'package:verba/presentation/screens/profile/profile_screen.dart';

final languagesProvider = FutureProvider.autoDispose<List<Language>>((ref) {
  return sl<LanguageRepository>().getAll();
});

final profileProvider = FutureProvider.autoDispose<Profile>((ref) {
  return sl<ProfileRepository>().get();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _lastLessonId;
  String? _lastLessonTitle;
  bool _loadingLast = true;

  @override
  void initState() {
    super.initState();
    _loadLastLesson();
  }

  Future<void> _loadLastLesson() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _lastLessonId = prefs.getString('last_lesson_id');
      _lastLessonTitle = prefs.getString('last_lesson_title');
      _loadingLast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languagesAsync = ref.watch(languagesProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verba'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
              if (!mounted) return;
              ref.invalidate(profileProvider);
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(languagesProvider);
          ref.invalidate(profileProvider);
          await _loadLastLesson();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', height: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome, ${profileAsync.valueOrNull?.name ?? 'Learner'}',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Pick a course and keep building your path.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!_loadingLast && _lastLessonId != null)
              Card(
                child: ListTile(
                  title: const Text('Continue'),
                  subtitle: Text(_lastLessonTitle ?? 'Last lesson'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticeScreen(
                          lessonId: _lastLessonId!,
                          lessonTitle: _lastLessonTitle ?? 'Last lesson',
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Text('Courses', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            languagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
              data: (languages) {
                if (languages.isEmpty) {
                  return const Text('No courses available.');
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return _LanguageCard(language: language);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;
  const _LanguageCard({required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LessonsScreen(
              languageId: language.id,
              languageName: language.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.emoji ?? '🌐', style: theme.textTheme.headlineSmall),
            const Spacer(),
            Text(language.name, style: theme.textTheme.titleMedium),
            Text('A1–A2', style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
