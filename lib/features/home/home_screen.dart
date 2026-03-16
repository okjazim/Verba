import 'package:flutter/material.dart';

import 'package:verba/features/languages/language_list_screen.dart';
import 'package:verba/features/practice/practice_screen.dart';
import 'package:verba/features/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    setState(() {
      _lastLessonId = prefs.getString('last_lesson_id');
      _lastLessonTitle = prefs.getString('last_lesson_title');
      _loadingLast = false;
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 72,
              ),
              const SizedBox(height: 12),
              Text(
                'Create and practice your own language lessons with a calm, focused experience.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (!_loadingLast && _lastLessonId != null)
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticeScreen(
                          lessonId: _lastLessonId!,
                          lessonTitle: _lastLessonTitle ?? 'Last lesson',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Continue practice: ${_lastLessonTitle ?? 'Last lesson'}',
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageListScreen(),
                      ),
                    );
                  },
                  child: const Text('Start practice'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
