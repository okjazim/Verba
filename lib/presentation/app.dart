import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/theme/app_theme.dart';
import 'package:verba/presentation/screens/home/home_screen.dart';
import 'package:verba/presentation/screens/intro/intro_screen.dart';

class VerbaApp extends StatelessWidget {
  const VerbaApp({super.key});

  Future<Widget> _decideStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('verba_seen_intro_v1') ?? false;
    return seenIntro ? const HomeScreen() : const IntroScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verba',
      theme: AppTheme.light,
      home: FutureBuilder<Widget>(
        future: _decideStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          return snapshot.data ?? const IntroScreen();
        },
      ),
    );
  }
}
