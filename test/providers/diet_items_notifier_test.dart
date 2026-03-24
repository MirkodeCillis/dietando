import 'package:dietando/models/models.dart';
import 'package:dietando/providers/diet_items_provider.dart';
import 'package:dietando/repositories/diet_item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Hand-written fake repository — no mocking package needed.
class FakeDietItemRepository implements DietItemRepository {
  List<DietItem> _items = [];
  int saveCallCount = 0;

  @override
  Future<List<DietItem>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> saveAll(List<DietItem> items) async {
    _items = List.from(items);
    saveCallCount++;
  }
}

ProviderContainer makeContainer(FakeDietItemRepository repo) {
  return ProviderContainer(
    overrides: [
      dietItemRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

final sampleItem = DietItem(
  id: 'item-1',
  name: 'Riso',
  description: '',
  weeklyTarget: 500,
  currentStock: 0,
  unit: Unit.Grammi,
  categoryId: '',
);

void main() {
  group('DietItemsNotifier', () {
    test('initial state loads from repository', () async {
      final repo = FakeDietItemRepository();
      repo._items = [sampleItem];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      // Wait for async build
      final result = await container.read(dietItemsProvider.future);
      expect(result.length, 1);
      expect(result.first.name, 'Riso');
    });

    test('add inserts item and calls saveAll', () async {
      final repo = FakeDietItemRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      final newItem = DietItem(
        id: 'item-2',
        name: 'Pasta',
        description: '',
        weeklyTarget: 400,
        currentStock: 0,
        unit: Unit.Grammi,
        categoryId: '',
      );

      await container.read(dietItemsProvider.notifier).add(newItem);

      final state = container.read(dietItemsProvider).requireValue;
      expect(state.length, 1);
      expect(state.first.name, 'Pasta');
      expect(repo.saveCallCount, 1);
    });

    test('add throws ArgumentError for empty name', () async {
      final repo = FakeDietItemRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      final invalidItem = sampleItem.copyWith(name: '  ');
      expect(
        () => container.read(dietItemsProvider.notifier).add(invalidItem),
        throwsArgumentError,
      );
    });

    test('add throws ArgumentError for non-positive weeklyTarget', () async {
      final repo = FakeDietItemRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      final invalidItem = sampleItem.copyWith(weeklyTarget: 0);
      expect(
        () => container.read(dietItemsProvider.notifier).add(invalidItem),
        throwsArgumentError,
      );
    });

    test('edit updates existing item in state', () async {
      final repo = FakeDietItemRepository();
      repo._items = [sampleItem];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      final updated = sampleItem.copyWith(name: 'Riso Integrale');
      await container.read(dietItemsProvider.notifier).edit(updated);

      final state = container.read(dietItemsProvider).requireValue;
      expect(state.first.name, 'Riso Integrale');
    });

    test('delete removes item from state', () async {
      final repo = FakeDietItemRepository();
      repo._items = [sampleItem];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      await container
          .read(dietItemsProvider.notifier)
          .delete(sampleItem.id);

      final state = container.read(dietItemsProvider).requireValue;
      expect(state, isEmpty);
      expect(repo.saveCallCount, 1);
    });

    test('replaceAll replaces entire list', () async {
      final repo = FakeDietItemRepository();
      repo._items = [sampleItem];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dietItemsProvider.future);

      final newItems = [
        sampleItem.copyWith(id: 'x', name: 'Farro'),
        sampleItem.copyWith(id: 'y', name: 'Orzo'),
      ];
      await container.read(dietItemsProvider.notifier).replaceAll(newItems);

      final state = container.read(dietItemsProvider).requireValue;
      expect(state.length, 2);
      expect(state.map((e) => e.name), containsAll(['Farro', 'Orzo']));
    });
  });
}
