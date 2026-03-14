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
  int _currentIndex = 0;
  bool _showBack = false;
  bool _isLoading = true;
  int _correct = 0;
  int _incorrect = 0;

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
      _currentIndex = 0;
      _showBack = false;
      _isLoading = false;
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

  void _nextCard() {
    if (_items.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Card ${_currentIndex + 1} of ${_items.length}',
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
                            front: _items[_currentIndex].front,
                            back: _items[_currentIndex].back,
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
                            onPressed: () {
                              setState(() {
                                _incorrect++;
                              });
                              _nextCard();
                            },
                            child: const Text('Again'),
                          ),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _correct++;
                              });
                              _nextCard();
                            },
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

