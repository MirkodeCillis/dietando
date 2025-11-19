import 'package:flutter/material.dart';
import 'package:diet_shopping/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Shopping',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)), // Brand color simile al React
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate-50
        cardTheme: const CardThemeData(
          surfaceTintColor: Colors.white,
          color: Colors.white,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
