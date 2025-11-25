import 'package:flutter/material.dart';
import 'package:dietando/models/models.dart';
import 'package:uuid/uuid.dart';

class MealPlanPage extends StatefulWidget {
  final MealPlan mealPlan;
  final List<DietItem> dietItems;
  final Function(MealPlan) onUpdateMealPlan;
  final Function(List<DietItem>) onUpdateDietItems;

  const MealPlanPage({
    super.key,
    required this.mealPlan,
    required this.dietItems,
    required this.onUpdateMealPlan,
    required this.onUpdateDietItems,
  });

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  late DayOfWeek _selectedDay;
  late MealPlan _mealPlan;

  @override
  void initState() {
    super.initState();
    _selectedDay = DayOfWeek.lunedi;
    _mealPlan = widget.mealPlan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildDaySelector(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: MealType.values.map((mealType) {
                return _buildMealSection(mealType);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: DayOfWeek.values.length,
        itemBuilder: (context, index) {
          final day = DayOfWeek.values[index];
          final isSelected = day == _selectedDay;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(day.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDay = day;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealSection(MealType mealType) {
    final items = _mealPlan.plan[_selectedDay]![mealType]!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                mealType.icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              mealType.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddItemDialog(mealType),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Nessun alimento inserito',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...items.map((item) => _buildMealItem(mealType, item)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMealItem(MealType mealType, MealPlanItem item) {
    final dietItem = widget.dietItems.firstWhere(
      (di) => di.id == item.dietItemId,
      orElse: () => DietItem(
        id: '',
        name: 'Alimento eliminato',
        description: '',
        weeklyTarget: 0,
        currentStock: 0,
        unit: Unit.Grammi,
      ),
    );

    return ListTile(
      dense: true,
      leading: const Icon(Icons.restaurant, size: 20),
      title: Text(dietItem.name),
      subtitle: Text('${item.quantity.toStringAsFixed(0)} ${dietItem.unit.name}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditItemDialog(mealType, item),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => _deleteItem(mealType, item),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(MealType mealType) {
    _showItemDialog(mealType, null);
  }

  void _showEditItemDialog(MealType mealType, MealPlanItem item) {
    _showItemDialog(mealType, item);
  }

  void _showItemDialog(MealType mealType, MealPlanItem? item) {
    DietItem? selectedDietItem;

    if (item != null) {
      selectedDietItem = widget.dietItems.firstWhere(
        (di) => di.id == item.dietItemId,
        orElse: () => widget.dietItems.first,
      );
    }

    final quantityCtrl = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item == null ? 'Aggiungi Alimento' : 'Modifica Alimento'),

              // FIX: dà un vincolo stabile al dialog
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleziona alimento:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // ListView con altezza fissa (stabile e senza shrinkWrap)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: widget.dietItems.length,
                        itemBuilder: (context, index) {
                          final dietItem = widget.dietItems[index];
                          final isSelected = selectedDietItem?.id == dietItem.id;

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            dense: true,
                            selected: isSelected,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            title: Text(dietItem.name),
                            subtitle: Text(dietItem.unit.name),
                            onTap: () {
                              setDialogState(() {
                                selectedDietItem = dietItem;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pulsante crea nuovo
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateNewDietItemDialog(mealType);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crea Nuovo Alimento'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantità',
                        suffix: Text(selectedDietItem?.unit.name ?? ''),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedDietItem == null || quantityCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleziona un alimento e inserisci la quantità'),
                        ),
                      );
                      return;
                    }

                    final quantity = double.tryParse(quantityCtrl.text) ?? 0;
                    selectedDietItem!.weeklyTarget = (selectedDietItem?.weeklyTarget ?? 0) + quantity;

                    final newItem = MealPlanItem(
                      id: item?.id ?? const Uuid().v4(),
                      dietItemId: selectedDietItem!.id,
                      quantity: quantity,
                    );

                    setState(() {
                      final items = _mealPlan.plan[_selectedDay]![mealType]!;
                      if (item != null) {
                        final index = items.indexWhere((i) => i.id == item.id);
                        if (index != -1) {
                          items[index] = newItem;
                        }
                      } else {
                        items.add(newItem);
                      }
                    });

                    widget.onUpdateMealPlan(_mealPlan);
                    widget.onUpdateDietItems(widget.dietItems);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateNewDietItemDialog(MealType mealType) {
    final nameCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    Unit selectedUnit = Unit.Grammi;
    final unitCtrl = TextEditingController(text: selectedUnit.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo Alimento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
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
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inserisci il nome dell\'alimento')),
                );
                return;
              }

              final newDietItem = DietItem(
                id: const Uuid().v4(),
                name: nameCtrl.text,
                description: descriptionCtrl.text,
                weeklyTarget: 0,
                currentStock: 0,
                unit: selectedUnit,
              );

              final updatedDietItems = [...widget.dietItems, newDietItem];
              widget.onUpdateDietItems(updatedDietItems);

              Navigator.pop(ctx);
              
              Future.delayed(const Duration(milliseconds: 100), () {
                _showItemDialog(mealType, null);
              });
            },
            child: const Text('Crea e Seleziona'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(MealType mealType, MealPlanItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Vuoi rimuovere questo alimento dal pasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _mealPlan.plan[_selectedDay]![mealType]!.removeWhere((i) => i.id == item.id);
              });
              final int idx = widget.dietItems.indexWhere((di) {return di.id == item.dietItemId;});
              if (idx > -1) {
                widget.dietItems[idx].weeklyTarget -= item.quantity;
              }
              widget.onUpdateMealPlan(_mealPlan);
              widget.onUpdateDietItems(widget.dietItems);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}