import 'package:dietando/models/models.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:dietando/repositories/extra_item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final extraItemRepositoryProvider = Provider<ExtraItemRepository>(
  (ref) => SharedPrefsExtraItemRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

class ExtraItemsNotifier extends AsyncNotifier<List<ExtraItem>> {
  @override
  Future<List<ExtraItem>> build() =>
      ref.watch(extraItemRepositoryProvider).getAll();

  Future<void> add(ExtraItem item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    final previous = state;
    final updated = [...state.requireValue, item];
    state = AsyncData(updated);
    try {
      await ref.read(extraItemRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> edit(ExtraItem item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    final previous = state;
    final updated = state.requireValue
        .map((e) => e.id == item.id ? item : e)
        .toList();
    state = AsyncData(updated);
    try {
      await ref.read(extraItemRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final previous = state;
    final updated = state.requireValue.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    try {
      await ref.read(extraItemRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> replaceAll(List<ExtraItem> items) async {
    final previous = state;
    state = AsyncData(items);
    try {
      await ref.read(extraItemRepositoryProvider).saveAll(items);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final extraItemsProvider =
    AsyncNotifierProvider<ExtraItemsNotifier, List<ExtraItem>>(
  ExtraItemsNotifier.new,
);
