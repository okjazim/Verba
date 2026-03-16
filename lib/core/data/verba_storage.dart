import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:verba/core/data/verba_data.dart';
import 'package:verba/core/data/verba_seed.dart';

class VerbaStorage {
  static const String _storageKey = 'verba_data_v1';

  Future<VerbaData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      final seeded = VerbaSeed.defaultData();
      await save(seeded);
      return seeded;
    }

    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return VerbaData.fromJson(map);
    } catch (_) {
      final seeded = VerbaSeed.defaultData();
      await save(seeded);
      return seeded;
    }
  }

  Future<void> save(VerbaData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data.toJson());
    await prefs.setString(_storageKey, jsonString);
  }
}

