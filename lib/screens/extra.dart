import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';
import 'package:uuid/uuid.dart';

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
