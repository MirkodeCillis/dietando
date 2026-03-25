import 'package:dietando/models/models.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:dietando/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPrefsSettingsRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

class SettingsNotifier extends AsyncNotifier<SettingsData> {
  @override
  Future<SettingsData> build() =>
      ref.watch(settingsRepositoryProvider).get();

  Future<void> setThemeMode(String themeMode) async {
    final current = state.requireValue;
    final updated = SettingsData(
      themeMode: themeMode,
      language: current.language,
    );
    final previous = state;
    state = AsyncData(updated);
    try {
      await ref.read(settingsRepositoryProvider).save(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> setLanguage(String language) async {
    final current = state.requireValue;
    final updated = SettingsData(
      themeMode: current.themeMode,
      language: language,
    );
    final previous = state;
    state = AsyncData(updated);
    try {
      await ref.read(settingsRepositoryProvider).save(updated);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> replaceAll(SettingsData settings) async {
    final previous = state;
    state = AsyncData(settings);
    try {
      await ref.read(settingsRepositoryProvider).save(settings);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsData>(
  SettingsNotifier.new,
);
