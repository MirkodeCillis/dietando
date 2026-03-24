import 'package:dietando/pages/all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = [
    'Piano Alimentare',
    'Inventario Dieta',
    'Spese Extra',
    'Lista della Spesa',
    'Impostazioni',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MealPlanPage(),
      const InventoryPage(),
      const ExtraPage(),
      const ShoppingPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Dieta',
          ),
          NavigationDestination(
            icon: Icon(Icons.food_bank_outlined),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: 'Extra',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            label: 'Spesa',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
