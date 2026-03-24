import 'package:dietando/models/models.dart';
import 'package:dietando/repositories/diet_item_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsDietItemRepository', () {
    Future<SharedPrefsDietItemRepository> makeRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return SharedPrefsDietItemRepository(prefs);
    }

    final item = DietItem(
      id: 'id-1',
      name: 'Riso',
      description: 'Riso integrale',
      weeklyTarget: 500,
      currentStock: 100,
      unit: Unit.Grammi,
      categoryId: 'cat-1',
    );

    test('getAll returns empty list when storage is empty', () async {
      final repo = await makeRepo();
      final result = await repo.getAll();
      expect(result, isEmpty);
    });

    test('save then load roundtrip preserves all fields', () async {
      final repo = await makeRepo();
      await repo.saveAll([item]);
      final result = await repo.getAll();

      expect(result.length, 1);
      expect(result.first.id, item.id);
      expect(result.first.name, item.name);
      expect(result.first.description, item.description);
      expect(result.first.weeklyTarget, item.weeklyTarget);
      expect(result.first.currentStock, item.currentStock);
      expect(result.first.unit, item.unit);
      expect(result.first.categoryId, item.categoryId);
    });

    test('saveAll with multiple items preserves order', () async {
      final repo = await makeRepo();
      final items = [
        item,
        item.copyWith(id: 'id-2', name: 'Pasta'),
        item.copyWith(id: 'id-3', name: 'Pollo'),
      ];
      await repo.saveAll(items);
      final result = await repo.getAll();
      expect(result.map((e) => e.id), ['id-1', 'id-2', 'id-3']);
    });

    test('getAll returns empty list on corrupt data', () async {
      SharedPreferences.setMockInitialValues({'diet_items': 'not valid json'});
      final repo = await makeRepo();
      final result = await repo.getAll();
      expect(result, isEmpty);
    });

    test('saveAll with empty list clears storage', () async {
      final repo = await makeRepo();
      await repo.saveAll([item]);
      await repo.saveAll([]);
      final result = await repo.getAll();
      expect(result, isEmpty);
    });
  });
}
