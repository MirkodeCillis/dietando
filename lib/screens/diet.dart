import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';
import 'package:uuid/uuid.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      Text("Target: ${item.weeklyTarget.toStringAsFixed(0)} ${item.unit.name}"),
                      Text("Posseduto: ${item.currentStock.toStringAsFixed(0)} ${item.unit.name}"),
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
    final unitCtrl = TextEditingController(text: item?.unit.name ?? Unit.grams.name);
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(item == null ? "Nuovo Alimento" : "Modifica Alimento"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome")),
            Row(
              children: [
                Expanded(child: TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock"))),
              ],
            ),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: "Unità di Misura")),
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
