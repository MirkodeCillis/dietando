import 'package:flutter/material.dart';
import 'package:dietando/components/filter.dart';
import 'package:dietando/models/models.dart';
import 'package:uuid/uuid.dart';

class DietPage extends StatefulWidget {
  final List<DietItem> items;
  final Function(List<DietItem>) onUpdate;

  const DietPage({super.key, required this.items, required this.onUpdate});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  List<DietItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(covariant DietPage oldWidget) {
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
      ? const Center(child: Text("Nessun alimento nel piano.")) 
      : Column( children: [
          Filter<DietItem>(list: widget.items, filterBy: (item) => item.name, updateList: (List<DietItem> resultItems) {
            setState(() {
              filteredItems = resultItems;
            });
          }),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: filteredItems.length,
            itemBuilder: (ctx, i) {
              final item = filteredItems[i];
              final progress = item.weeklyTarget > 0 ? (item.currentStock / item.weeklyTarget).clamp(0.0, 1.0) : 0.0;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showItemDialog(context, item),
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
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showItemDialog(context, item),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            color: progress >= 1 ? const Color.fromARGB(255, 86, 170, 89) : (progress > 0.5 ? const Color.fromARGB(255, 206, 96, 59) : Theme.of(context).colorScheme.onError),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Target: ${item.weeklyTarget.toStringAsFixed(0)} ${item.unit.name}"),
                            Text("Stock: ${item.currentStock.toStringAsFixed(0)} ${item.unit.name}"),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              );
            }),
          )
        ])
    );
  }

  void _showItemDialog(BuildContext context, DietItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final targetCtrl = TextEditingController(text: item?.weeklyTarget.toString() ?? '');
    final stockCtrl = TextEditingController(text: item?.currentStock.toString() ?? '');
    Unit selectedUnit = item?.unit ?? Unit.Grammi;
    final unitCtrl = TextEditingController(text: selectedUnit.name);
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          Text(item == null ? "Nuovo Alimento" : "Modifica Alimento"),
          if (item != null) ...[ 
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
              onPressed: () {
                final int idx = widget.items.indexWhere((e) => e.id == item.id);
                final newList = List<DietItem>.from(widget.items)..removeAt(idx);
                widget.onUpdate(newList);
              },
            ),
          ]
          
        ],
      ) ,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome")),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Target"
                    )
                  )
                ),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Stock"
                    )
                  )
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownMenu<Unit>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: selectedUnit,
                  controller: unitCtrl,
                  requestFocusOnTap: false,
                  label: const Text('Unità di Misura'),
                  onSelected: (Unit? unit) {
                    if (unit != null) {
                      selectedUnit = unit;
                      unitCtrl.text = unit.name;
                    }
                  },
                  dropdownMenuEntries: Unit.values
                      .map((unit) => DropdownMenuEntry<Unit>(
                            value: unit,
                            label: unit.name,
                          ))
                      .toList(),
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
            unit: selectedUnit,
          );
          
          if (item == null) {
            widget.onUpdate([...widget.items, newItem]);
          } else {
            final index = widget.items.indexWhere((e) => e.id == item.id);
            final newList = List<DietItem>.from(widget.items);
            newList[index] = newItem;
            widget.onUpdate(newList);
          }
          Navigator.pop(ctx);
        }, child: const Text("Salva")),
      ],
    ));
  }
}