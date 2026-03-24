import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ExtraItemRepository {
  Future<List<ExtraItem>> getAll();
  Future<void> saveAll(List<ExtraItem> items);
}

class SharedPrefsExtraItemRepository implements ExtraItemRepository {
  static const _key = 'extra_items';

  final SharedPreferences _prefs;
  SharedPrefsExtraItemRepository(this._prefs);

  @override
  Future<List<ExtraItem>> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => ExtraItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<ExtraItem> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
