import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _mealPlanKey = 'meal_plan_data';
  static const String _dietKey = 'diet_items';
  static const String _extraKey = 'extra_items';
  static const String _categoriesKey = 'categories_items';
  static const String _settingsKey = 'settings_data';

  static Future<void> saveMealPlan(MealPlan mealPlan) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(mealPlan.toJson());
    await prefs.setString(_mealPlanKey, encoded);
  }

  static Future<MealPlan> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_mealPlanKey);
    if (encoded == null) {
      return MealPlan();
    }
    final dynamic decoded = jsonDecode(encoded);
    return MealPlan.fromJson(decoded);
  }

  static Future<void> saveDiet(List<DietItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_dietKey, encoded);
  }

  static Future<List<DietItem>> loadDiet() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_dietKey);
    if (encoded == null) {
      return [];
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

  static Future<void> saveCategories(List<ShoppingCategory> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_categoriesKey, encoded);
  }

  static Future<List<ShoppingCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_categoriesKey);
    if (encoded == null) {
      return [];
    };
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => ShoppingCategory.fromJson(e)).toList();
  }

  static Future<void> saveSettings(SettingsData settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, encoded);
  }

  static Future<SettingsData> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_settingsKey);
    if (encoded == null) return SettingsData.defaultSettings;
    final dynamic decoded = jsonDecode(encoded);
    return SettingsData.fromJson(decoded);
  }
}
