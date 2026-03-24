import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CategoryRepository {
  Future<List<ShoppingCategory>> getAll();
  Future<void> saveAll(List<ShoppingCategory> items);
}

class SharedPrefsCategoryRepository implements CategoryRepository {
  static const _key = 'categories_items';

  final SharedPreferences _prefs;
  SharedPrefsCategoryRepository(this._prefs);

  @override
  Future<List<ShoppingCategory>> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => ShoppingCategory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<ShoppingCategory> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
