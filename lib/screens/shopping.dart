import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';

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
