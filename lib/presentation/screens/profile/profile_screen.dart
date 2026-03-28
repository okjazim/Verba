import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/core/di/service_locator.dart';
import 'package:verba/domain/models/profile.dart';
import 'package:verba/domain/repositories/profile_repository.dart';
import 'package:verba/presentation/screens/home/home_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  String _languageCode = 'es';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await sl<ProfileRepository>().get();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile.name;
      _languageCode = profile.languageCode;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final profile = Profile(
      name: name.isEmpty ? 'Learner' : name,
      languageCode: _languageCode,
    );
    await sl<ProfileRepository>().save(profile);
    if (!mounted) return;
    ref.invalidate(profileProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Learner',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Primary language', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Spanish'),
                        selected: _languageCode == 'es',
                        onSelected: (_) => setState(() => _languageCode = 'es'),
                      ),
                      ChoiceChip(
                        label: const Text('German'),
                        selected: _languageCode == 'de',
                        onSelected: (_) => setState(() => _languageCode = 'de'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
