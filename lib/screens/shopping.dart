import 'package:flutter/material.dart';
import 'package:dietando/components/filter.dart';
import 'package:dietando/models/models.dart';

class ShoppingPage extends StatefulWidget {
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
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<ExtraItem> filteredExtraItems = [];
  List<DietItem> filteredDietItems = [];

  @override
  void initState() {
    super.initState();
    filteredDietItems = widget.dietItems;
    filteredExtraItems = widget.extraItems;
  }

  @override
  void didUpdateWidget(covariant ShoppingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredDietItems = widget.dietItems;
    filteredExtraItems = widget.extraItems;
  }

  @override
  Widget build(BuildContext context) {
    final missingDiet = filteredDietItems.where((i) => (i.weeklyTarget - i.currentStock) > 0).toList();
    final pendingExtras = filteredExtraItems.where((i) => !i.isBought).toList();

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
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("DA DIETA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Filter<DietItem>(list: widget.dietItems, filterBy: (item) => item.name, updateList: (List<DietItem> resultItems) {
          setState(() {
            filteredDietItems = resultItems;
          });
        }),
        if (missingDiet.isNotEmpty) ...[
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
                    final index = widget.dietItems.indexWhere((e) => e.id == item.id);
                    final updatedList = List<DietItem>.from(widget.dietItems);
                    updatedList[index].currentStock += missing;
                    widget.onUpdateDiet(updatedList);
                  },
                ),
              ),
            );
          }),
        ] else ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nessun alimento da comprare!"),
          ),
        ],
        const Padding(
            padding: EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: Text("EXTRA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Filter<ExtraItem>(list: widget.extraItems, filterBy: (item) => item.name, updateList: (List<ExtraItem> resultItems) {
            setState(() {
              filteredExtraItems = resultItems;
            });
          }),
        if (pendingExtras.isNotEmpty) ...[
          ...pendingExtras.map((item) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.local_pizza, color: Colors.white, size: 20)),
                title: Text(item.name),
                subtitle: Text(item.quantity != null ? "Quantità ${item.quantity!.toStringAsFixed(2)}" : "N. S."),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.orange),
                  onPressed: () {
                    item.isBought = true;
                    widget.onUpdateExtra(widget.extraItems);
                  },
                ),
              ),
            );
          }),
        ] else ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nessun extra da comprare!"),
          ),
        ]
      ],
    );
  }
}
