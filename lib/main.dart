import 'package:dietando/home.dart';
import 'package:dietando/providers/settings_provider.dart';
import 'package:dietando/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: const Color(0xFF7692FF),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Errore nel caricamento delle impostazioni'),
              ],
            ),
          ),
        ),
      ),
      data: (settings) => MaterialApp(
        title: 'Dietando',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: settings.themeModeEnum,
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7692FF),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      onError: const Color.fromARGB(255, 239, 43, 43),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(0),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationThemeData(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationThemeData(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: colorScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
