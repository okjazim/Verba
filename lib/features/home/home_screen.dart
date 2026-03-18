import 'package:flutter/material.dart';

import 'package:verba/core/data/language_repository.dart';
import 'package:verba/core/data/profile_storage.dart';
import 'package:verba/core/models/language.dart';
import 'package:verba/core/models/profile.dart';
import 'package:verba/features/lessons/lesson_list_screen.dart';
import 'package:verba/features/practice/practice_screen.dart';
import 'package:verba/features/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LanguageRepository _languageRepository = InMemoryLanguageRepository();
  final ProfileStorage _profileStorage = ProfileStorage();

  String? _lastLessonId;
  String? _lastLessonTitle;
  bool _loadingLast = true;
  List<Language> _languages = const [];
  Profile _profile = const Profile(name: 'Learner', languageCode: 'es');
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final languages = await _languageRepository.getAll();
    final profile = await _profileStorage.load();
    setState(() {
      _lastLessonId = prefs.getString('last_lesson_id');
      _lastLessonTitle = prefs.getString('last_lesson_title');
      _loadingLast = false;
      _languages = languages;
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verba'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
              if (!mounted) return;
              if (result is Profile) {
                setState(() => _profile = result);
              } else {
                final profile = await _profileStorage.load();
                if (mounted) setState(() => _profile = profile);
              }
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome, ${_profile.name}',
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
                        title: Text('Continue'),
                        subtitle:
                            Text(_lastLessonTitle ?? 'Last lesson'),
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
                  Text(
                    'Courses',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_languages.isEmpty)
                    const Text('No courses available.')
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _languages.length,
                      itemBuilder: (context, index) {
                        final language = _languages[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LessonListScreen(
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
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language.emoji ?? '🌐',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const Spacer(),
                                Text(
                                  language.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  'A1–A2',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
