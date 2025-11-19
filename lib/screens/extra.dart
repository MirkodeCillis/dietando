import 'package:flutter/material.dart';
import 'package:gestore_spesa/components/new_extra.dart';
import 'package:gestore_spesa/models/models.dart';

class ExtraPage extends StatelessWidget {
  final List<ExtraItem> items;
  final Function(List<ExtraItem>) onUpdate;

  const ExtraPage({super.key, required this.items, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          NewExtra(onUpdate: (elem) => onUpdate([...items, elem])),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return ListTile(
                  onTap: () => _showEditDialog(context, item),
                  leading: Checkbox(
                    value: item.isBought,
                    activeColor: Colors.orange,
                    onChanged: (v) {
                      final newList = List<ExtraItem>.from(items);
                      newList[i] = ExtraItem(
                        id: item.id,
                        name: item.name,
                        quantity: item.quantity,
                        isBought: v!,
                      );
                      onUpdate(newList);
                    },
                  ),
                  title: Text(item.name, style: TextStyle(decoration: item.isBought ? TextDecoration.lineThrough : null, color: item.isBought ? Colors.grey : Colors.black)),
                  subtitle: item.quantity != null ? Text("Quantità: ${item.quantity}") : null,
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
      )
    );
  }

  void _showEditDialog(BuildContext context, ExtraItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity?.toString() ?? "");
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Modifica Extra"),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder(),
            labelText: "Nome")
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Quantità")
          ),
        ],
      ),
      actions: [
        FilledButton(onPressed: () {
          final newList = List<ExtraItem>.from(items);
          final index = newList.indexWhere((e) => e.id == item.id);
          newList[index] = ExtraItem(
            id: item.id,
            name: nameCtrl.text,
            quantity: double.tryParse(qtyCtrl.text),
            isBought: item.isBought,
          );
          onUpdate(newList);
          Navigator.pop(ctx);
        },
        child: const Text("Aggiorna")),
      ],
    ));
  }
}
