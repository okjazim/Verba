import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/models/profile.dart';

class ProfileStorage {
  static const _key = 'verba_profile_v1';

  Future<Profile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return const Profile(name: 'Learner', languageCode: 'es');
    }
    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return Profile.fromJson(map);
    } catch (_) {
      return const Profile(name: 'Learner', languageCode: 'es');
    }
  }

  Future<void> save(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(profile.toJson()));
  }
}

