import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/lesson_item.dart';
import 'package:verba/domain/repositories/lesson_item_repository.dart';

class PracticeScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const PracticeScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<LessonItem> _items = [];
  late List<int> _queue;
  int _currentIndex = 0;
  bool _showBack = false;
  bool _isLoading = true;
  int _correct = 0;
  int _incorrect = 0;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await sl<LessonItemRepository>().getByLessonId(
      widget.lessonId,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
      _queue = List<int>.generate(items.length, (i) => i)..shuffle();
      _currentIndex = 0;
      _showBack = false;
      _correct = 0;
      _incorrect = 0;
      _isLoading = false;
    });
    if (items.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_lesson_id', widget.lessonId);
      await prefs.setString('last_lesson_title', widget.lessonTitle);
    }
  }

  LessonItem? get _currentItem {
    if (_queue.isEmpty || _items.isEmpty) return null;
    final idx = _queue[_currentIndex.clamp(0, _queue.length - 1)];
    return _items[idx];
  }

  void _toggleSide() {
    setState(() => _showBack = !_showBack);
  }

  void _markAgain() {
    if (_queue.isEmpty || !_showBack) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _incorrect++;
      final currentId = _queue.removeAt(_currentIndex);
      final insertAt = (_currentIndex + 3).clamp(0, _queue.length);
      _queue.insert(insertAt, currentId);
      if (_currentIndex >= _queue.length) _currentIndex = 0;
      _showBack = false;
    });
  }

  void _markGotIt() {
    if (_queue.isEmpty || !_showBack) return;
    HapticFeedback.lightImpact();
    setState(() {
      _correct++;
      _queue.removeAt(_currentIndex);
      if (_currentIndex >= _queue.length) _currentIndex = 0;
      _showBack = false;
    });
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _currentItem;
    final total = _items.length;
    final remaining = _queue.length;

    return Scaffold(
      appBar: AppBar(title: Text('Practice: ${widget.lessonTitle}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Text(
                'No items in this lesson yet.\nAdd some words or phrases first.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            )
          : _queue.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Session complete',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Got it: $_correct · Again: $_incorrect',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to home'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadItems,
                      child: const Text('Restart session'),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Remaining $remaining of $total',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Got it: $_correct · Again: $_incorrect',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: _Flashcard(
                        front: item?.front ?? '',
                        back: item?.back ?? '',
                        showBack: _showBack,
                        onTap: _toggleSide,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Listen',
                        onPressed: () => _speak(
                          _showBack ? (item?.back ?? '') : (item?.front ?? ''),
                        ),
                        icon: const Icon(Icons.volume_up_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: _toggleSide,
                        child: Text(_showBack ? 'Show front' : 'Show back'),
                      ),
                      FilledButton(
                        onPressed: _showBack ? _markAgain : null,
                        child: const Text('Again'),
                      ),
                      FilledButton(
                        onPressed: _showBack ? _markGotIt : null,
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  final String front;
  final String back;
  final bool showBack;
  final VoidCallback onTap;

  const _Flashcard({
    required this.front,
    required this.back,
    required this.showBack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            showBack ? back : front,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
