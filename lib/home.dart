import 'package:flutter/material.dart';
import 'package:diet_shopping/screens/all.dart';
import 'package:diet_shopping/models/models.dart';
import 'package:diet_shopping/services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<DietItem> _dietItems = [];
  List<ExtraItem> _extraItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final d = await DataService.loadDiet();
    final e = await DataService.loadExtras();
    setState(() {
      _dietItems = d;
      _extraItems = e;
      _loading = false;
    });
  }

  void _saveDiet() {
    DataService.saveDiet(_dietItems);
    setState(() {});
  }

  void _saveExtras() {
    DataService.saveExtras(_extraItems);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final tabs = [
      DietPage(
        items: _dietItems,
        onUpdate: (items) { _dietItems = items; _saveDiet(); },
      ),
      ExtraPage(
        items: _extraItems,
        onUpdate: (items) { _extraItems = items; _saveExtras(); },
      ),
      ShoppingPage(
        dietItems: _dietItems,
        extraItems: _extraItems,
        onUpdateDiet: (items) { _dietItems = items; _saveDiet(); },
        onUpdateExtra: (items) { _extraItems = items; _saveExtras(); },
      ),
      AiPage(dietItems: _dietItems, extraItems: _extraItems),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Colors.green),
            SizedBox(width: 8),
            Text('Diet Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Dieta'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Extra'),
          NavigationDestination(icon: Icon(Icons.shopping_basket), label: 'Spesa'),
          NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'),
        ],
      ),
    );
  }
}
