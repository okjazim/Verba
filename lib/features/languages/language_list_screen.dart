import 'package:flutter/material.dart';

import 'package:verba/core/data/language_repository.dart';
import 'package:verba/core/models/language.dart';
import 'package:verba/features/lessons/lesson_list_screen.dart';

class LanguageListScreen extends StatefulWidget {
  const LanguageListScreen({super.key});

  @override
  State<LanguageListScreen> createState() => _LanguageListScreenState();
}

class _LanguageListScreenState extends State<LanguageListScreen> {
  final LanguageRepository _repository = InMemoryLanguageRepository();
  List<Language> _languages = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _showUpsertLanguageDialog({Language? existing}) async {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final codeController =
        TextEditingController(text: existing?.code ?? '');
    final emojiController =
        TextEditingController(text: existing?.emoji ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add language' : 'Edit language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Spanish',
                ),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'es',
                ),
              ),
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji (optional)',
                  hintText: '🇪🇸',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final name = nameController.text.trim();
    final code = codeController.text.trim();
    final emoji = emojiController.text.trim().isEmpty
        ? null
        : emojiController.text.trim();

    if (name.isEmpty || code.isEmpty) return;

    final language = Language(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      code: code,
      emoji: emoji,
    );

    await _repository.upsert(language);
    await _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final languages = await _repository.getAll();
    setState(() {
      _languages = languages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _languages.isEmpty
              ? Center(
                  child: Text(
                    'No languages yet.\nTap + to add your first language.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                    itemCount: _languages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      return ListTile(
                        leading: Text(language.emoji ?? '🌐'),
                        title: Text(language.name),
                        subtitle: Text(language.code),
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
                        trailing: IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showUpsertLanguageDialog(existing: language),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUpsertLanguageDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

