import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/data/lesson_item_repository.dart';
import 'package:verba/core/models/lesson_item.dart';

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
  final LessonItemRepository _repository = InMemoryLessonItemRepository();
  List<LessonItem> _items = const [];
  bool _showBack = false;
  bool _isLoading = true;
  int _correct = 0;
  int _incorrect = 0;
  int _currentIndex = 0;
  late List<int> _queue;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getByLessonId(widget.lessonId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _queue = List<int>.generate(items.length, (i) => i)..shuffle();
      _currentIndex = 0;
      _showBack = false;
      _isLoading = false;
      _correct = 0;
      _incorrect = 0;
    });
    if (items.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_lesson_id', widget.lessonId);
      await prefs.setString('last_lesson_title', widget.lessonTitle);
    }
  }

  void _toggleSide() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  LessonItem? get _currentItem {
    if (_queue.isEmpty || _items.isEmpty) return null;
    final idx = _queue[_currentIndex.clamp(0, _queue.length - 1)];
    return _items[idx];
  }

  void _advance() {
    if (_queue.isEmpty) return;
    setState(() {
      _showBack = false;
      if (_currentIndex >= _queue.length - 1) {
        _currentIndex = 0;
      } else {
        _currentIndex++;
      }
    });
  }

  void _markAgain() {
    final item = _currentItem;
    if (item == null || !_showBack) return;
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
    final item = _currentItem;
    if (item == null || !_showBack) return;
    setState(() {
      _correct++;
      _queue.removeAt(_currentIndex);
      if (_currentIndex >= _queue.length) _currentIndex = 0;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final item = _currentItem;
    final total = _items.length;
    final remaining = _queue.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice: ${widget.lessonTitle}'),
      ),
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
                      const SizedBox(height: 8),
                      Text(
                        _showBack
                            ? 'Tap the card to go back to the question.'
                            : 'Tap the card or \"Show back\" to reveal the answer.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: _toggleSide,
                            child: Text(
                              _showBack ? 'Show front' : 'Show back',
                            ),
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
              color: Colors.black.withOpacity(0.05),
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

