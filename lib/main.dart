import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

// --- 1. MODELLI DI DATI ---

enum Unit { grams, pieces, liters }

class DietItem {
  String id;
  String name;
  double weeklyTarget;
  double currentStock;
  Unit unit;
  String category;

  DietItem({
    required this.id,
    required this.name,
    required this.weeklyTarget,
    required this.currentStock,
    required this.unit,
    this.category = 'Generale',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'weeklyTarget': weeklyTarget,
        'currentStock': currentStock,
        'unit': unit.index,
        'category': category,
      };

  factory DietItem.fromJson(Map<String, dynamic> json) => DietItem(
        id: json['id'],
        name: json['name'],
        weeklyTarget: (json['weeklyTarget'] as num).toDouble(),
        currentStock: (json['currentStock'] as num).toDouble(),
        unit: Unit.values[json['unit']],
        category: json['category'] ?? 'Generale',
      );
}

class ExtraItem {
  String id;
  String name;
  bool isBought;
  double? estimatedCost;

  ExtraItem({
    required this.id,
    required this.name,
    this.isBought = false,
    this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isBought': isBought,
        'estimatedCost': estimatedCost,
      };

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
        id: json['id'],
        name: json['name'],
        isBought: json['isBought'] ?? false,
        estimatedCost: json['estimatedCost'] != null
            ? (json['estimatedCost'] as num).toDouble()
            : null,
      );
}

// --- 2. MAIN APP & THEME ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestore Spesa AI',
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

// --- 3. SERVICES ---

class DataService {
  static const String _dietKey = 'diet_items';
  static const String _extraKey = 'extra_items';

  static Future<void> saveDiet(List<DietItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_dietKey, encoded);
  }

  static Future<List<DietItem>> loadDiet() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_dietKey);
    if (encoded == null) {
      // Dati di default come nell'app React
      return [
        DietItem(id: '1', name: 'Petto di Pollo', weeklyTarget: 1000, currentStock: 200, unit: Unit.grams, category: 'Carne'),
        DietItem(id: '2', name: 'Riso Basmati', weeklyTarget: 700, currentStock: 700, unit: Unit.grams, category: 'Cereali'),
      ];
    }
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => DietItem.fromJson(e)).toList();
  }

  static Future<void> saveExtras(List<ExtraItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_extraKey, encoded);
  }

  static Future<List<ExtraItem>> loadExtras() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_extraKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => ExtraItem.fromJson(e)).toList();
  }
}

class GeminiService {
  // ⚠️ IMPORTANTE: Sostituisci con la tua chiave API reale
  static const String apiKey = 'INSERISCI_QUI_LA_TUA_API_KEY';

  static Future<String> getAdvice(List<DietItem> diet, List<ExtraItem> extras) async {
    if (apiKey.startsWith('INSERISCI')) return "Errore: Configura l'API Key nel codice Flutter.";

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final dietContext = diet.map((item) =>
      "- ${item.name}: Target ${item.weeklyTarget}, Attuale ${item.currentStock}. (Necessario: ${item.weeklyTarget - item.currentStock > 0 ? item.weeklyTarget - item.currentStock : 0})"
    ).join('\n');

    final extraContext = extras.map((item) =>
      "- ${item.name} (${item.isBought ? 'Comprato' : 'Da comprare'})"
    ).join('\n');

    final prompt = '''
      Sei un nutrizionista.
      DIETA:
      $dietContext
      EXTRA:
      $extraContext
      
      1. Analizza se l'utente è indietro.
      2. Suggerisci 2 ricette veloci con ciò che l'utente HA GIÀ (CurrentStock > 0).
      3. Consiglio breve.
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Nessun consiglio generato.";
    } catch (e) {
      return "Errore connessione Gemini: $e";
    }
  }
}

// --- 4. SCREEN PRINCIPALE ---

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
      ShoppingPage(
        dietItems: _dietItems,
        extraItems: _extraItems,
        onUpdateDiet: (items) { _dietItems = items; _saveDiet(); },
        onUpdateExtra: (items) { _extraItems = items; _saveExtras(); },
      ),
      ExtraPage(
        items: _extraItems,
        onUpdate: (items) { _extraItems = items; _saveExtras(); },
      ),
      AiPage(dietItems: _dietItems, extraItems: _extraItems),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Colors.green),
            SizedBox(width: 8),
            Text('Gestore Spesa', style: TextStyle(fontWeight: FontWeight.bold)),
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
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Piano'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Spesa'),
          NavigationDestination(icon: Icon(Icons.shopping_basket), label: 'Extra'),
          NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'),
        ],
      ),
    );
  }
}

// --- 5. COMPONENTI (PAGINE) ---

// 1. PIANO DIETA
class DietPage extends StatelessWidget {
  final List<DietItem> items;
  final Function(List<DietItem>) onUpdate;

  const DietPage({super.key, required this.items, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context, null),
        label: const Text("Aggiungi"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty 
      ? const Center(child: Text("Nessun alimento nel piano.")) 
      : ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final progress = item.weeklyTarget > 0 ? (item.currentStock / item.weeklyTarget).clamp(0.0, 1.0) : 0.0;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _showItemDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          final newList = List<DietItem>.from(items)..removeAt(i);
                          onUpdate(newList);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: progress >= 1 ? Colors.green : (progress > 0.5 ? Colors.orange : Colors.red),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Posseduto: ${item.currentStock.toStringAsFixed(0)} ${item.unit.name}"),
                      Text("Target: ${item.weeklyTarget.toStringAsFixed(0)} ${item.unit.name}"),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showItemDialog(BuildContext context, DietItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final targetCtrl = TextEditingController(text: item?.weeklyTarget.toString() ?? '');
    final stockCtrl = TextEditingController(text: item?.currentStock.toString() ?? '');
    final catCtrl = TextEditingController(text: item?.category ?? 'Generale');
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? "Nuovo Alimento" : "Modifica Alimento"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Categoria")),
            Row(
              children: [
                Expanded(child: TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock"))),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
        FilledButton(onPressed: () {
          final newItem = DietItem(
            id: item?.id ?? const Uuid().v4(),
            name: nameCtrl.text,
            weeklyTarget: double.tryParse(targetCtrl.text) ?? 0,
            currentStock: double.tryParse(stockCtrl.text) ?? 0,
            unit: Unit.grams, // Semplificato
            category: catCtrl.text,
          );
          
          if (item == null) {
            onUpdate([...items, newItem]);
          } else {
            final index = items.indexWhere((e) => e.id == item.id);
            final newList = List<DietItem>.from(items);
            newList[index] = newItem;
            onUpdate(newList);
          }
          Navigator.pop(ctx);
        }, child: const Text("Salva")),
      ],
    ));
  }
}

// 2. LISTA SPESA UNIFICATA
class ShoppingPage extends StatelessWidget {
  final List<DietItem> dietItems;
  final List<ExtraItem> extraItems;
  final Function(List<DietItem>) onUpdateDiet;
  final Function(List<ExtraItem>) onUpdateExtra;

  const ShoppingPage({
    super.key, 
    required this.dietItems, 
    required this.extraItems,
    required this.onUpdateDiet,
    required this.onUpdateExtra
  });

  @override
  Widget build(BuildContext context) {
    final missingDiet = dietItems.where((i) => (i.weeklyTarget - i.currentStock) > 0).toList();
    final pendingExtras = extraItems.where((i) => !i.isBought).toList();

    if (missingDiet.isEmpty && pendingExtras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green.shade200),
            const SizedBox(height: 16),
            const Text("Tutto fatto!", style: TextStyle(fontSize: 24, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (missingDiet.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("DA DIETA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...missingDiet.map((item) {
            final missing = item.weeklyTarget - item.currentStock;
            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.restaurant, color: Colors.white, size: 20)),
                title: Text(item.name),
                subtitle: Text("Mancano: $missing ${item.unit.name}"),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: () {
                    // Logica "Compra": aggiunge la differenza allo stock
                    final index = dietItems.indexWhere((e) => e.id == item.id);
                    final updatedList = List<DietItem>.from(dietItems);
                    updatedList[index].currentStock += missing;
                    onUpdateDiet(updatedList);
                  },
                ),
              ),
            );
          }),
        ],
        if (pendingExtras.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: Text("EXTRA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...pendingExtras.map((item) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.local_pizza, color: Colors.white, size: 20)),
                title: Text(item.name),
                subtitle: Text(item.estimatedCost != null ? "€ ${item.estimatedCost!.toStringAsFixed(2)}" : "Costo N/D"),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.orange),
                  onPressed: () {
                    item.isBought = true;
                    onUpdateExtra(extraItems);
                  },
                ),
              ),
            );
          }),
        ]
      ],
    );
  }
}

// 3. EXTRA PAGE
class ExtraPage extends StatelessWidget {
  final List<ExtraItem> items;
  final Function(List<ExtraItem>) onUpdate;

  const ExtraPage({super.key, required this.items, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final totalSpent = items.where((i) => i.isBought).fold(0.0, (sum, i) => sum + (i.estimatedCost ?? 0));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.orange.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("TOTALE SPESO EXTRA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              Text("€ ${totalSpent.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Nuovo extra...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (val) {
                    if (val.isEmpty) return;
                    onUpdate([...items, ExtraItem(id: const Uuid().v4(), name: val)]);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return ListTile(
                leading: Checkbox(
                  value: item.isBought,
                  activeColor: Colors.orange,
                  onChanged: (v) {
                    item.isBought = v!;
                    onUpdate(items);
                  },
                ),
                title: Text(item.name, style: TextStyle(decoration: item.isBought ? TextDecoration.lineThrough : null, color: item.isBought ? Colors.grey : Colors.black)),
                subtitle: item.estimatedCost != null ? Text("€ ${item.estimatedCost}") : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                      onPressed: () {
                        final newList = List<ExtraItem>.from(items)..removeAt(i);
                        onUpdate(newList);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, ExtraItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final costCtrl = TextEditingController(text: item.estimatedCost?.toString() ?? "");
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Modifica Extra"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome")),
          TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Costo (€)")),
        ],
      ),
      actions: [
        FilledButton(onPressed: () {
          item.name = nameCtrl.text;
          item.estimatedCost = double.tryParse(costCtrl.text);
          onUpdate(items);
          Navigator.pop(ctx);
        }, child: const Text("Aggiorna")),
      ],
    ));
  }
}

// 4. AI PAGE
class AiPage extends StatefulWidget {
  final List<DietItem> dietItems;
  final List<ExtraItem> extraItems;

  const AiPage({super.key, required this.dietItems, required this.extraItems});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  String _response = "";
  bool _loading = false;

  void _askGemini() async {
    setState(() { _loading = true; _response = ""; });
    final text = await GeminiService.getAdvice(widget.dietItems, widget.extraItems);
    setState(() { _loading = false; _response = text; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 60, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text("Analisi Intelligente", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Chiedi a Gemini consigli su ricette e bilanciamento.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _loading ? null : _askGemini,
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              icon: _loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.play_arrow),
              label: Text(_loading ? "Analisi in corso..." : "Genera Consigli"),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade50),
              ),
              child: SingleChildScrollView(
                child: Text(_response.isEmpty ? "I consigli appariranno qui..." : _response, 
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}