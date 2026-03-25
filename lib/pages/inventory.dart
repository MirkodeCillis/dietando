import 'package:dietando/components/filter.dart';
import 'package:dietando/components/navbar.dart';
import 'package:dietando/components/topbar.dart';
import 'package:dietando/l10n/app_localizations.dart';
import 'package:dietando/l10n/extensions.dart';
import 'package:dietando/models/models.dart';
import 'package:dietando/providers/categories_provider.dart';
import 'package:dietando/providers/diet_items_provider.dart';
import 'package:dietando/providers/meal_plan_provider.dart';
import 'package:dietando/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  List<DietItem> _filteredItems = [];
  final FilterController _filterController = FilterController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(dietItemsProvider);
    final categories = ref.watch(categoriesProvider).value ?? [];

    final items = itemsAsync.value;

    return Scaffold(
      appBar: AppTopBar(title: l10n.pageInventory),
      bottomNavigationBar: const AppNavBar(currentRoute: AppRoutes.inventory),
      floatingActionButton: items != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showItemDialog(context, null, items, categories),
              label: Text(l10n.btnAdd),
              icon: const Icon(Icons.add),
            )
          : null,
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.errorWithMessage(e.toString()))),
        data: (items) {
          final displayItems =
              (_filterController.isFiltering ? _filteredItems : items)
                  .map((fi) => items.firstWhere((i) => i.id == fi.id,
                      orElse: () => fi))
                  .toList();

          return items.isEmpty
              ? Center(child: Text(l10n.inventoryNoItems))
              : Column(
                  children: [
                    Filter<DietItem>(
                      controller: _filterController,
                      list: items,
                      filterBy: (item) => item.name,
                      updateList: (resultItems) {
                        setState(() => _filteredItems = resultItems);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: displayItems.length,
                        itemBuilder: (ctx, i) {
                          final item = displayItems[i];
                          final progress = item.weeklyTarget > 0
                              ? (item.currentStock / item.weeklyTarget)
                                  .clamp(0.0, 1.0)
                              : 1.0;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showItemDialog(
                                  context, item, items, categories),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showItemDialog(
                                              context, item, items, categories),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        color: progress >= 0.7
                                            ? const Color.fromARGB(
                                                255, 86, 170, 89)
                                            : (progress > 0.3
                                                ? const Color.fromARGB(
                                                    255, 206, 96, 59)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onError),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${l10n.fieldTarget}: ${item.weeklyTarget.toStringAsFixed(0)} ${item.unit.l10nName(l10n)}'),
                                        Text(
                                            '${l10n.fieldStock}: ${item.currentStock.toStringAsFixed(0)} ${item.unit.l10nName(l10n)}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  void _showItemDialog(
    BuildContext context,
    DietItem? item,
    List<DietItem> allItems,
    List<ShoppingCategory> categories,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final descriptionCtrl =
        TextEditingController(text: item?.description ?? '');
    final targetCtrl =
        TextEditingController(text: item?.weeklyTarget.toString() ?? '');
    final stockCtrl =
        TextEditingController(text: item?.currentStock.toString() ?? '');
    Unit selectedUnit = item?.unit ?? Unit.Grammi;
    final unitCtrl =
        TextEditingController(text: selectedUnit.l10nName(l10n));
    ShoppingCategory selectedCategory = categories.firstWhere(
      (cat) => cat.id == item?.categoryId,
      orElse: () =>
          ShoppingCategory(id: '', name: l10n.mealPlanNoCategory, priority: 999),
    );
    final categoryCtrl = TextEditingController(text: selectedCategory.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item == null ? l10n.mealPlanNewFood : l10n.mealPlanEditFood),
            if (item != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  ref.read(dietItemsProvider.notifier).delete(item.id);
                  ref
                      .read(mealPlanProvider.notifier)
                      .removeItemsByDietItemId(item.id);
                  _filterController.reset();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.fieldName),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.fieldTarget),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.fieldStock),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownMenu<Unit>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: selectedUnit,
                controller: unitCtrl,
                requestFocusOnTap: false,
                label: Text(l10n.fieldUnit),
                onSelected: (Unit? unit) {
                  if (unit != null) {
                    selectedUnit = unit;
                    unitCtrl.text = unit.l10nName(l10n);
                  }
                },
                dropdownMenuEntries: Unit.values
                    .map((unit) => DropdownMenuEntry<Unit>(
                          value: unit,
                          label: unit.l10nName(l10n),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionCtrl,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: l10n.fieldDescription,
                  hintText: l10n.inventoryDescriptionHint,
                ),
              ),
              const SizedBox(height: 16),
              DropdownMenu<ShoppingCategory>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: selectedCategory,
                controller: categoryCtrl,
                requestFocusOnTap: false,
                label: Text(l10n.fieldCategory),
                onSelected: (ShoppingCategory? category) {
                  if (category != null) selectedCategory = category;
                },
                dropdownMenuEntries: categories
                    .map((cat) => DropdownMenuEntry<ShoppingCategory>(
                          value: cat,
                          label: cat.name,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              final newItem = DietItem(
                id: item?.id ?? const Uuid().v4(),
                name: nameCtrl.text,
                description: descriptionCtrl.text,
                weeklyTarget: double.tryParse(targetCtrl.text) ?? 0,
                currentStock: double.tryParse(stockCtrl.text) ?? 0,
                unit: selectedUnit,
                categoryId: selectedCategory.id,
              );

              if (item == null) {
                ref.read(dietItemsProvider.notifier).add(newItem);
              } else {
                ref.read(dietItemsProvider.notifier).edit(newItem);
              }
              _filterController.reset();
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnSave),
          ),
        ],
      ),
    );
  }
}
