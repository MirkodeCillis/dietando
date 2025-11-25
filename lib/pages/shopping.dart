import 'package:dietando/components/shopping_list_diet_item.dart';
import 'package:dietando/components/shopping_list_extra_item.dart';
import 'package:flutter/material.dart';
import 'package:dietando/components/filter.dart';
import 'package:dietando/models/models.dart';

class ShoppingPage extends StatefulWidget {
  final List<DietItem> dietItems;
  final List<ExtraItem> extraItems;
  final List<ShoppingCategory> categories;
  final Function(List<DietItem>) onUpdateDiet;
  final Function(List<ExtraItem>) onUpdateExtra;

  const ShoppingPage({
    super.key, 
    required this.dietItems, 
    required this.extraItems,
    required this.onUpdateDiet,
    required this.onUpdateExtra,
    required this.categories
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

  List<DietItem> _sortByCategory(
    List<DietItem> dietItems, 
    List<ShoppingCategory> categories
  ) {
    return List<DietItem>.from(dietItems)..sort((a, b) {
      final categoryA = categories.firstWhere(
        (cat) => cat.id == a.categoryId,
        orElse: () => ShoppingCategory(id: '', name: '', priority: 999),
      );
      
      final categoryB = categories.firstWhere(
        (cat) => cat.id == b.categoryId,
        orElse: () => ShoppingCategory(id: '', name: '', priority: 999),
      );
      
      return categoryA.priority.compareTo(categoryB.priority);
    });
  }

  @override
  Widget build(BuildContext context) {
    final missingDiet = filteredDietItems.where((i) => (i.weeklyTarget - i.currentStock) > 0).toList();
    final sortedItems = _sortByCategory(missingDiet, widget.categories);
    final pendingExtras = filteredExtraItems.where((i) => !i.isBought).toList();

    if (missingDiet.isEmpty && pendingExtras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline, 
              size: 100, 
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Tutto fatto!", 
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.restaurant, 
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text(
              "Da Dieta", 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: sortedItems.isNotEmpty 
              ? Text("${sortedItems.length} ${sortedItems.length == 1 ? 'articolo' : 'articoli'}")
              : const Text("Tutto completo"),
            children: [
              Filter<DietItem>(
                list: widget.dietItems, 
                filterBy: (item) => item.name, 
                updateList: (List<DietItem> resultItems) {
                  setState(() {
                    filteredDietItems = resultItems;
                  });
                },
              ),
              if (sortedItems.isNotEmpty) 
                ...sortedItems.map((item) {
                  return ShoppingListDietItem(
                    item: item, 
                    onUpdateDiet: (amount) {
                      final index = widget.dietItems.indexWhere((e) => e.id == item.id);
                      if (index != -1) {
                        final updatedList = List<DietItem>.from(widget.dietItems);
                        updatedList[index] = item.copyWith(currentStock: item.currentStock + amount);
                        widget.onUpdateDiet(updatedList);
                      }
                    }
                  );
                })
              else 
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text("Nessun alimento da comprare!"),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.local_pizza,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            title: const Text(
              "Spese Extra", 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: pendingExtras.isNotEmpty 
              ? Text("${pendingExtras.length} ${pendingExtras.length == 1 ? 'articolo' : 'articoli'}")
              : const Text("Tutto comprato"),
            children: [
              Filter<ExtraItem>(
                list: widget.extraItems, 
                filterBy: (item) => item.name, 
                updateList: (List<ExtraItem> resultItems) {
                  setState(() {
                    filteredExtraItems = resultItems;
                  });
                },
              ),
              if (pendingExtras.isNotEmpty) 
                ...pendingExtras.map((item) {
                  return ShoppingListExtraItem(
                    item: item, 
                    onUpdateExtra: () {
                      final index = widget.extraItems.indexWhere((e) => e.id == item.id);
                      if (index != -1) {
                        final updatedList = List<ExtraItem>.from(widget.extraItems);
                        updatedList[index] = ExtraItem(
                          id: item.id,
                          name: item.name,
                          quantity: item.quantity,
                          isBought: true,
                        );
                        widget.onUpdateExtra(updatedList);
                      }
                    }
                  );
                })
              else 
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text("Nessun extra da comprare!"),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}