import 'package:flutter/material.dart';

import 'package:verba/core/data/profile_storage.dart';
import 'package:verba/core/models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileStorage _storage = ProfileStorage();
  final _nameController = TextEditingController();
  String _languageCode = 'es';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _storage.load();
    setState(() {
      _nameController.text = profile.name;
      _languageCode = profile.languageCode;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final profile = Profile(
      name: _nameController.text.trim().isEmpty
          ? 'Learner'
          : _nameController.text.trim(),
      languageCode: _languageCode,
    );
    await _storage.save(profile);
    if (!mounted) return;
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
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
                  Text(
                    'Primary language',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Spanish'),
                        selected: _languageCode == 'es',
                        onSelected: (_) =>
                            setState(() => _languageCode = 'es'),
                      ),
                      ChoiceChip(
                        label: const Text('German'),
                        selected: _languageCode == 'de',
                        onSelected: (_) =>
                            setState(() => _languageCode = 'de'),
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

