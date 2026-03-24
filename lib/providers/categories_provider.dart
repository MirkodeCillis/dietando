import 'package:dietando/models/models.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:dietando/repositories/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => SharedPrefsCategoryRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

class CategoriesNotifier extends AsyncNotifier<List<ShoppingCategory>> {
  @override
  Future<List<ShoppingCategory>> build() =>
      ref.watch(categoryRepositoryProvider).getAll();

  Future<void> add(ShoppingCategory category) async {
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    final previous = state;
    final updated = [...state.requireValue, category];
    state = AsyncData(updated);
    try {
      await ref.read(categoryRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> edit(ShoppingCategory category) async {
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Il nome non può essere vuoto');
    }
    final previous = state;
    final updated = state.requireValue
        .map((e) => e.id == category.id ? category : e)
        .toList();
    state = AsyncData(updated);
    try {
      await ref.read(categoryRepositoryProvider).saveAll(updated);
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
      await ref.read(categoryRepositoryProvider).saveAll(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> reorder(List<ShoppingCategory> reordered) async {
    final previous = state;
    state = AsyncData(reordered);
    try {
      await ref.read(categoryRepositoryProvider).saveAll(reordered);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> replaceAll(List<ShoppingCategory> items) async {
    final previous = state;
    state = AsyncData(items);
    try {
      await ref.read(categoryRepositoryProvider).saveAll(items);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<ShoppingCategory>>(
  CategoriesNotifier.new,
);
