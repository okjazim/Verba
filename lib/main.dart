import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const VerbaApp());
}

class VerbaApp extends StatelessWidget {
  const VerbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verba',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
