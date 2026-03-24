import 'dart:convert';

import 'package:dietando/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MealPlanRepository {
  Future<MealPlan> get();
  Future<void> save(MealPlan mealPlan);
}

class SharedPrefsMealPlanRepository implements MealPlanRepository {
  static const _key = 'meal_plan_data';

  final SharedPreferences _prefs;
  SharedPrefsMealPlanRepository(this._prefs);

  @override
  Future<MealPlan> get() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return MealPlan();
    try {
      final dynamic decoded = jsonDecode(raw);
      return MealPlan.fromJson(decoded);
    } catch (_) {
      return MealPlan();
    }
  }

  @override
  Future<void> save(MealPlan mealPlan) async {
    await _prefs.setString(_key, jsonEncode(mealPlan.toJson()));
  }
}
