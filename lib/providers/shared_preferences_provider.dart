import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main.dart with the actual SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);
