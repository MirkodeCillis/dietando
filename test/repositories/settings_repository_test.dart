import 'package:dietando/models/models.dart';
import 'package:dietando/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsSettingsRepository', () {
    Future<SharedPrefsSettingsRepository> makeRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return SharedPrefsSettingsRepository(prefs);
    }

    test('get returns default settings when storage is empty', () async {
      final repo = await makeRepo();
      final result = await repo.get();
      expect(result.themeMode, 'system');
      expect(result.language, 'it');
    });

    test('save then get roundtrip preserves settings', () async {
      final repo = await makeRepo();
      final settings = SettingsData(themeMode: 'dark', language: 'it');
      await repo.save(settings);
      final result = await repo.get();
      expect(result.themeMode, 'dark');
    });

    test('get returns default settings on corrupt data', () async {
      SharedPreferences.setMockInitialValues(
          {'settings_data': 'not valid json'});
      final repo = await makeRepo();
      final result = await repo.get();
      expect(result.themeMode, 'system');
    });
  });
}
