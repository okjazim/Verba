import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/language.dart';
import 'package:verba/domain/repositories/language_repository.dart';
import 'package:verba/presentation/screens/lessons/lessons_screen.dart';

final languagesListProvider = FutureProvider.autoDispose<List<Language>>((ref) {
  return sl<LanguageRepository>().getAll();
});

class LanguagesScreen extends ConsumerStatefulWidget {
  const LanguagesScreen({super.key});

  @override
  ConsumerState<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends ConsumerState<LanguagesScreen> {
  Future<void> _showUpsertDialog({Language? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final codeController = TextEditingController(text: existing?.code ?? '');
    final emojiController = TextEditingController(text: existing?.emoji ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (result != true) return;

    final name = nameController.text.trim();
    final code = codeController.text.trim();
    final emoji = emojiController.text.trim();
    if (name.isEmpty || code.isEmpty) return;

    final language = Language(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      code: code,
      emoji: emoji.isEmpty ? null : emoji,
    );

    await sl<LanguageRepository>().upsert(language);
    if (!mounted) return;
    ref.invalidate(languagesListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(languagesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Languages')),
      body: languagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (languages) {
          if (languages.isEmpty) {
            return const Center(
              child: Text(
                'No languages yet.\nTap + to add your first language.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: languages.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lang = languages[index];
              return ListTile(
                leading: Text(
                  lang.emoji ?? '🌐',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(lang.name),
                subtitle: Text(lang.code),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonsScreen(
                      languageId: lang.id,
                      languageName: lang.name,
                    ),
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _showUpsertDialog(existing: lang),
                  icon: const Icon(Icons.edit_outlined),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpsertDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
