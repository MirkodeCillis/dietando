import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<SettingsData> get();
  Future<void> save(SettingsData settings);
}

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const _key = 'settings_data';

  final SharedPreferences _prefs;
  SharedPrefsSettingsRepository(this._prefs);

  @override
  Future<SettingsData> get() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return SettingsData.defaultSettings;
    try {
      final dynamic decoded = jsonDecode(raw);
      return SettingsData.fromJson(decoded);
    } catch (_) {
      return SettingsData.defaultSettings;
    }
  }

  @override
  Future<void> save(SettingsData settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
