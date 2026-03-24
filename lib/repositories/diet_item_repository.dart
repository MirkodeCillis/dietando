import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DietItemRepository {
  Future<List<DietItem>> getAll();
  Future<void> saveAll(List<DietItem> items);
}

class SharedPrefsDietItemRepository implements DietItemRepository {
  static const _key = 'diet_items';

  final SharedPreferences _prefs;
  SharedPrefsDietItemRepository(this._prefs);

  @override
  Future<List<DietItem>> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => DietItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<DietItem> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
