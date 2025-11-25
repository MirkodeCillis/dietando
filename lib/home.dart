import 'package:dietando/pages/meal_plan.dart';
import 'package:flutter/material.dart';
import 'package:dietando/pages/all.dart';
import 'package:dietando/models/models.dart';
import 'package:dietando/services/data_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(SettingsData) saveSettings;

  const HomeScreen({super.key, required this.saveSettings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  MealPlan _mealPlan = MealPlan();
  List<DietItem> _dietItems = [];
  List<ExtraItem> _extraItems = [];
  List<ShoppingCategory> _categoryItems = [];
  SettingsData _settings = SettingsData.defaultSettings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final m = await DataService.loadMealPlan();
    final d = await DataService.loadDiet();
    final e = await DataService.loadExtras();
    final c = await DataService.loadCategories();
    final s = await DataService.loadSettings();

    setState(() {
      _mealPlan = m;
      _dietItems = d;
      _extraItems = e;
      _categoryItems = c;
      _settings = s;
      _loading = false;
    });
  }

  void _saveMealPlan() {
    DataService.saveMealPlan(_mealPlan);
    setState(() {});
  }

  void _saveDiet() {
    DataService.saveDiet(_dietItems);
    setState(() {});
  }

  void _saveExtras() {
    DataService.saveExtras(_extraItems);
    setState(() {});
  }

  void _saveCategories() {
    DataService.saveCategories(_categoryItems);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final tabs = <Map<String, dynamic>>[
      {
        'title': 'Piano Alimentare',
        'page': MealPlanPage(
          mealPlan: _mealPlan,
          onUpdateMealPlan: (plan) { _mealPlan = plan; _saveMealPlan(); },
          dietItems: _dietItems,
          onUpdateDietItems: (items) { _dietItems = items; _saveDiet(); },
        )
      },
      {
        'title': 'Inventario Dieta',
        'page': InventoryPage(
          items: _dietItems,
          onUpdate: (items) { _dietItems = items; _saveDiet(); },
        )
      },
      {
        'title': 'Spese Extra',
        'page': ExtraPage(
          items: _extraItems,
          onUpdate: (items) { _extraItems = items; _saveExtras(); },
        ),
      },
      {
        'title': 'Lista della Spesa',
        'page': ShoppingPage(
          dietItems: _dietItems,
          extraItems: _extraItems,
          onUpdateDiet: (items) { _dietItems = items; _saveDiet(); },
          onUpdateExtra: (items) { _extraItems = items; _saveExtras(); },
        ),
      },
      {
        'title': 'Impostazioni',
        'page':  SettingsPage(
          categories: _categoryItems,
          onCategoriesChanged: (items) { _categoryItems = items; _saveCategories(); },
          settings: _settings,
          onSettingsChanged: (settings) { _settings = settings; widget.saveSettings(settings); },
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tabs[_currentIndex]['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: tabs[_currentIndex]['page'],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Dieta'),
          NavigationDestination(icon: Icon(Icons.food_bank_outlined), label: 'Inventario'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Extra'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: 'Spesa'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Impostazioni'),
        ],
      ),
    );
  }
}
