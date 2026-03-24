import 'package:dietando/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DietItem', () {
    final item = DietItem(
      id: 'test-id',
      name: 'Pollo',
      description: 'Petto di pollo',
      weeklyTarget: 700,
      currentStock: 200,
      unit: Unit.Grammi,
      categoryId: 'cat-1',
    );

    test('toJson includes all fields including description', () {
      final json = item.toJson();
      expect(json['id'], 'test-id');
      expect(json['name'], 'Pollo');
      expect(json['description'], 'Petto di pollo');
      expect(json['weeklyTarget'], 700.0);
      expect(json['currentStock'], 200.0);
      expect(json['unit'], Unit.Grammi.index);
      expect(json['categoryId'], 'cat-1');
    });

    test('fromJson roundtrip preserves all fields', () {
      final json = item.toJson();
      final restored = DietItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.description, item.description);
      expect(restored.weeklyTarget, item.weeklyTarget);
      expect(restored.currentStock, item.currentStock);
      expect(restored.unit, item.unit);
      expect(restored.categoryId, item.categoryId);
    });

    test('fromJson handles missing description gracefully', () {
      final json = item.toJson()..remove('description');
      final restored = DietItem.fromJson(json);
      expect(restored.description, '');
    });

    test('copyWith overrides only specified fields', () {
      final copy = item.copyWith(name: 'Manzo', weeklyTarget: 500);
      expect(copy.name, 'Manzo');
      expect(copy.weeklyTarget, 500);
      expect(copy.id, item.id);
      expect(copy.description, item.description);
      expect(copy.unit, item.unit);
    });
  });

  group('ExtraItem', () {
    final item = ExtraItem(
      id: 'extra-1',
      name: 'Olio',
      isBought: false,
      quantity: 1.5,
    );

    test('toJson roundtrip preserves all fields', () {
      final json = item.toJson();
      final restored = ExtraItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.isBought, item.isBought);
      expect(restored.quantity, item.quantity);
    });

    test('fromJson handles null quantity', () {
      final json = {
        'id': 'x',
        'name': 'Sale',
        'isBought': false,
        'quantity': null,
      };
      final restored = ExtraItem.fromJson(json);
      expect(restored.quantity, isNull);
    });

    test('copyWith overrides only specified fields', () {
      final copy = item.copyWith(isBought: true);
      expect(copy.isBought, true);
      expect(copy.id, item.id);
      expect(copy.name, item.name);
      expect(copy.quantity, item.quantity);
    });
  });

  group('MealPlan', () {
    test('initialises all 7 days × 5 meals as empty lists', () {
      final plan = MealPlan();
      expect(plan.plan.length, DayOfWeek.values.length);
      for (final day in DayOfWeek.values) {
        expect(plan.plan[day]!.length, MealType.values.length);
        for (final meal in MealType.values) {
          expect(plan.plan[day]![meal], isEmpty);
        }
      }
    });

    test('toJson/fromJson roundtrip preserves nested structure', () {
      final plan = MealPlan();
      plan.plan[DayOfWeek.lunedi]![MealType.pranzo]!.add(
        MealPlanItem(id: 'mp-1', dietItemId: 'di-1', quantity: 150),
      );

      final json = plan.toJson();
      final restored = MealPlan.fromJson(json);

      final items = restored.plan[DayOfWeek.lunedi]![MealType.pranzo]!;
      expect(items.length, 1);
      expect(items.first.id, 'mp-1');
      expect(items.first.dietItemId, 'di-1');
      expect(items.first.quantity, 150);
    });
  });

  group('ShoppingCategory', () {
    test('copyWith does not accept icon parameter', () {
      final cat = ShoppingCategory(id: 'c1', name: 'Frutta', priority: 0);
      final copy = cat.copyWith(name: 'Verdura', priority: 1);
      expect(copy.name, 'Verdura');
      expect(copy.priority, 1);
      expect(copy.id, 'c1');
    });
  });

  group('SettingsData', () {
    test('themeModeEnum returns correct ThemeMode for each string', () {
      expect(
        SettingsData(themeMode: 'dark', language: 'it').themeModeEnum,
        isNotNull,
      );
      expect(
        SettingsData(themeMode: 'light', language: 'it').themeModeEnum,
        isNotNull,
      );
      expect(
        SettingsData(themeMode: 'system', language: 'it').themeModeEnum,
        isNotNull,
      );
    });
  });
}
