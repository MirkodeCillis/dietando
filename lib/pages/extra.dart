import 'package:flutter/material.dart';
import 'package:dietando/components/filter.dart';
import 'package:dietando/models/models.dart';
import 'package:uuid/uuid.dart';

class ExtraPage extends StatefulWidget {
  final List<ExtraItem> items;
  final Function(List<ExtraItem>) onUpdate;

  const ExtraPage({super.key, required this.items, required this.onUpdate});

  @override
  State<ExtraPage> createState() => _ExtraPageState();
}

class _ExtraPageState extends State<ExtraPage> {
  List<ExtraItem> filteredItems = [];
  final FilterController filterController = FilterController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(covariant ExtraPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context, null),
        label: const Text("Aggiungi"),
        icon: const Icon(Icons.add),
      ),
      body: widget.items.isEmpty 
      ? const Center(child: Text("Nessuna spesa extra da fare.")) 
      : Column(
          children: [
            Filter<ExtraItem>(
              controller: filterController,
              list: widget.items, 
              filterBy: (item) => item.name, 
              updateList: (List<ExtraItem> resultItems) {
                setState(() {
                  filteredItems = resultItems;
                });
              }
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: filteredItems.length,
                itemBuilder: (ctx, i) {
                  final item = filteredItems[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showItemDialog(context, item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isBought,
                            onChanged: (v) {
                              final index = widget.items.indexWhere((e) => e.id == item.id);
                              if (index != -1) {
                                final newList = List<ExtraItem>.from(widget.items);
                                newList[index] = ExtraItem(
                                  id: item.id,
                                  name: item.name,
                                  quantity: item.quantity,
                                  isBought: v!,
                                );
                                widget.onUpdate(newList);
                              }
                            },
                          ),
                          title: Text(
                            item.name, 
                            style: TextStyle(
                              decoration: item.isBought ? TextDecoration.lineThrough : null,
                              color: item.isBought ? Theme.of(context).colorScheme.primary : null
                            )
                          ), 
                          subtitle: item.quantity != null ? Text("Quantità: ${item.quantity}") : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                ),
                                onPressed: () => _showItemDialog(context, item),
                              )
                            ],
                          ),
                        )
                      )
                    )
                  );
                },
              ),
            ),
          ],
        )
    );
  }

  void _showItemDialog(BuildContext context, ExtraItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(text: item?.quantity?.toString() ?? "");
    
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Text(item == null ? "Nuovo Articolo" : "Modifica Articolo"),
            if (item != null) ...[ 
              IconButton(
                icon: Icon(
                  Icons.delete_outline, 
                  color: Theme.of(context).colorScheme.error
                ),
                onPressed: () {
                  final int idx = widget.items.indexWhere((e) => e.id == item.id);
                  if (idx != -1) {
                    final newList = List<ExtraItem>.from(widget.items)..removeAt(idx);
                    widget.onUpdate(newList);
                    filterController.reset();
                  }
                  Navigator.pop(ctx);
                },
              ),
            ]
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nome")
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantità")
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Annulla")
          ),
          FilledButton(
            onPressed: () {
              final newItem = ExtraItem(
                id: item?.id ?? const Uuid().v4(),
                name: nameCtrl.text,
                quantity: double.tryParse(qtyCtrl.text),
                isBought: item?.isBought ?? false,
              );

              if (item == null) {
                widget.onUpdate([...widget.items, newItem]);
              } else {
                final index = widget.items.indexWhere((e) => e.id == item.id);
                if (index != -1) {
                  final newList = List<ExtraItem>.from(widget.items);
                  newList[index] = newItem;
                  widget.onUpdate(newList);
                }
              }
              filterController.reset();
              Navigator.pop(ctx);
            }, 
            child: const Text("Salva")
          ),
        ],
      )
    );
  }
}
