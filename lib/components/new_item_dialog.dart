import 'package:flutter/material.dart';
import 'package:gestore_spesa/models/models.dart';
import 'package:uuid/uuid.dart';

class NewItemDialog extends AlertDialog {

  const NewItemDialog({
    super.key,
    required BuildContext ctx,
    required List<DietItem> items,
    DietItem? item,
    required Function(List<DietItem>) onUpdate,
  });

  const NewItemDialog(BuildContext ctx, List<DietItem> items, DietItem? item) :{
    super(
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
            DropdownMenu<Unit>(
                        initialSelection: Unit.grams,
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
                      ),
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
    )
    )
  }

  
}