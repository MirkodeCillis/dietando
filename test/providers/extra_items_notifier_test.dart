import 'package:dietando/models/models.dart';
import 'package:dietando/providers/extra_items_provider.dart';
import 'package:dietando/repositories/extra_item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExtraItemRepository implements ExtraItemRepository {
  List<ExtraItem> _items = [];

  @override
  Future<List<ExtraItem>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> saveAll(List<ExtraItem> items) async {
    _items = List.from(items);
  }
}

ProviderContainer makeContainer(FakeExtraItemRepository repo) {
  return ProviderContainer(
    overrides: [
      extraItemRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('ExtraItemsNotifier', () {
    test('add inserts item', () async {
      final repo = FakeExtraItemRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(extraItemsProvider.future);

      final item =
          ExtraItem(id: 'e-1', name: 'Sale', isBought: false);
      await container.read(extraItemsProvider.notifier).add(item);

      final state = container.read(extraItemsProvider).requireValue;
      expect(state.length, 1);
      expect(state.first.name, 'Sale');
    });

    test('add throws ArgumentError for empty name', () async {
      final repo = FakeExtraItemRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(extraItemsProvider.future);

      expect(
        () => container
            .read(extraItemsProvider.notifier)
            .add(ExtraItem(id: 'e-x', name: '', isBought: false)),
        throwsArgumentError,
      );
    });

    test('edit updates isBought', () async {
      final repo = FakeExtraItemRepository();
      repo._items = [ExtraItem(id: 'e-1', name: 'Sale', isBought: false)];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(extraItemsProvider.future);

      await container
          .read(extraItemsProvider.notifier)
          .edit(ExtraItem(id: 'e-1', name: 'Sale', isBought: true));

      final state = container.read(extraItemsProvider).requireValue;
      expect(state.first.isBought, true);
    });

    test('delete removes item', () async {
      final repo = FakeExtraItemRepository();
      repo._items = [ExtraItem(id: 'e-1', name: 'Sale', isBought: false)];
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(extraItemsProvider.future);
      await container.read(extraItemsProvider.notifier).delete('e-1');

      final state = container.read(extraItemsProvider).requireValue;
      expect(state, isEmpty);
    });
  });
}
