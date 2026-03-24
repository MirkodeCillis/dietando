import 'package:dietando/models/models.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:dietando/repositories/meal_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (ref) => SharedPrefsMealPlanRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

/// Returns a deep copy of a MealPlan to avoid mutating provider state directly.
MealPlan _copyMealPlan(MealPlan source) {
  return MealPlan.fromJson(source.toJson());
}

class MealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() => ref.watch(mealPlanRepositoryProvider).get();

  Future<void> addItem(
    DayOfWeek day,
    MealType meal,
    MealPlanItem item,
  ) async {
    final previous = state;
    final updated = _copyMealPlan(state.requireValue);
    updated.plan[day]![meal]!.add(item);
    state = AsyncData(updated);
    try {
      await ref.read(mealPlanRepositoryProvider).save(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeItem(
    DayOfWeek day,
    MealType meal,
    String itemId,
  ) async {
    final previous = state;
    final updated = _copyMealPlan(state.requireValue);
    updated.plan[day]![meal]!.removeWhere((e) => e.id == itemId);
    state = AsyncData(updated);
    try {
      await ref.read(mealPlanRepositoryProvider).save(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Removes all meal plan items referencing a deleted diet item.
  Future<void> removeItemsByDietItemId(String dietItemId) async {
    final previous = state;
    final updated = _copyMealPlan(state.requireValue);
    for (final day in DayOfWeek.values) {
      for (final meal in MealType.values) {
        updated.plan[day]![meal]!
            .removeWhere((e) => e.dietItemId == dietItemId);
      }
    }
    state = AsyncData(updated);
    try {
      await ref.read(mealPlanRepositoryProvider).save(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> replaceAll(MealPlan mealPlan) async {
    final previous = state;
    state = AsyncData(mealPlan);
    try {
      await ref.read(mealPlanRepositoryProvider).save(mealPlan);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final mealPlanProvider =
    AsyncNotifierProvider<MealPlanNotifier, MealPlan>(
  MealPlanNotifier.new,
);
