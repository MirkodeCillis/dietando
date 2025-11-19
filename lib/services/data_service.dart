import 'dart:convert';

import 'package:gestore_spesa/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _dietKey = 'diet_items';
  static const String _extraKey = 'extra_items';

  static Future<void> saveDiet(List<DietItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_dietKey, encoded);
  }

  static Future<List<DietItem>> loadDiet() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_dietKey);
    if (encoded == null) {
      // Dati di default come nell'app React
      return [
        DietItem(id: '1', name: 'Petto di Pollo', weeklyTarget: 1000, currentStock: 200, unit: Unit.grams),
        DietItem(id: '2', name: 'Riso Basmati', weeklyTarget: 700, currentStock: 700, unit: Unit.grams),
      ];
    }
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => DietItem.fromJson(e)).toList();
  }

  static Future<void> saveExtras(List<ExtraItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_extraKey, encoded);
  }

  static Future<List<ExtraItem>> loadExtras() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_extraKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => ExtraItem.fromJson(e)).toList();
  }
}
