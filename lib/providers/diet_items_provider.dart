import 'package:dietando/models/models.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:dietando/repositories/diet_item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dietItemRepositoryProvider = Provider<DietItemRepository>(
  (ref) => SharedPrefsDietItemRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

class DietItemsNotifier extends AsyncNotifier<List<DietItem>> {
  @override
  Future<List<DietItem>> build() =>
      ref.watch(dietItemRepositoryProvider).getAll();

  Future<void> add(DietItem item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    if (item.weeklyTarget <= 0) {
      throw ArgumentError('Il target settimanale deve essere maggiore di zero');
    }
    final previous = state;
    final updated = [...state.requireValue, item];
    state = AsyncData(updated);
    try {
      await ref.read(dietItemRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> edit(DietItem item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    if (item.weeklyTarget <= 0) {
      throw ArgumentError('Il target settimanale deve essere maggiore di zero');
    }
    final previous = state;
    final updated = state.requireValue
        .map((e) => e.id == item.id ? item : e)
        .toList();
    state = AsyncData(updated);
    try {
      await ref.read(dietItemRepositoryProvider).saveAll(updated);
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
      await ref.read(dietItemRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> replaceAll(List<DietItem> items) async {
    final previous = state;
    state = AsyncData(items);
    try {
      await ref.read(dietItemRepositoryProvider).saveAll(items);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final dietItemsProvider =
    AsyncNotifierProvider<DietItemsNotifier, List<DietItem>>(
  DietItemsNotifier.new,
);
