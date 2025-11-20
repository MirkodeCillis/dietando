import 'package:dietando/global.dart';
import 'package:flutter/material.dart';
import 'package:dietando/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietando',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme, // Orange-500
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
        ),
        dialogTheme: const DialogThemeData(
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          )
        ),
        inputDecorationTheme: const InputDecorationThemeData(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
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
      ),
      home: const HomeScreen(),
    );
  }
}
