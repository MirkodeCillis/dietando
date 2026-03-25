import 'package:dietando/components/filter.dart';
import 'package:dietando/components/shopping_list_diet_item.dart';
import 'package:dietando/components/shopping_list_extra_item.dart';
import 'package:dietando/components/navbar.dart';
import 'package:dietando/components/topbar.dart';
import 'package:dietando/models/models.dart';
import 'package:dietando/providers/categories_provider.dart';
import 'package:dietando/providers/diet_items_provider.dart';
import 'package:dietando/providers/extra_items_provider.dart';
import 'package:dietando/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingPage extends ConsumerStatefulWidget {
  const ShoppingPage({super.key});

  @override
  ConsumerState<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ConsumerState<ShoppingPage> {
  List<DietItem> _filteredDietItems = [];
  List<ExtraItem> _filteredExtraItems = [];
  final FilterController _dietFilterController = FilterController();
  final FilterController _extraFilterController = FilterController();

  List<DietItem> _sortByCategory(
    List<DietItem> dietItems,
    List<ShoppingCategory> categories,
  ) {
    return List<DietItem>.from(dietItems)
      ..sort((a, b) {
        final catA = categories.firstWhere(
          (cat) => cat.id == a.categoryId,
          orElse: () =>
              ShoppingCategory(id: '', name: '', priority: 999),
        );
        final catB = categories.firstWhere(
          (cat) => cat.id == b.categoryId,
          orElse: () =>
              ShoppingCategory(id: '', name: '', priority: 999),
        );
        return catA.priority.compareTo(catB.priority);
      });
  }

  @override
  Widget build(BuildContext context) {
    final dietItems = ref.watch(dietItemsProvider).valueOrNull ?? [];
    final extraItems = ref.watch(extraItemsProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    // Sync filtered lists when source changes
    final filteredDietItems = (_dietFilterController.isFiltering ? _filteredDietItems : dietItems)
      .map((fi) => dietItems.firstWhere((i) => i.id == fi.id,
          orElse: () => fi))
      .toList();
    final filteredExtraItems = (_extraFilterController.isFiltering ? _filteredExtraItems : extraItems)
      .map((fi) => extraItems.firstWhere((i) => i.id == fi.id,
          orElse: () => fi))
      .toList();

    final missingDiet =
        filteredDietItems.where((i) => (i.weeklyTarget - i.currentStock) > 0).toList();
    final sortedDiet = _sortByCategory(missingDiet, categories);
    final pendingExtras = filteredExtraItems.where((i) => !i.isBought).toList();

    const navBar = AppNavBar(currentRoute: AppRoutes.shopping);

    if (missingDiet.isEmpty && pendingExtras.isEmpty) {
      return Scaffold(
        appBar: AppTopBar(title: 'Lista della Spesa'),
        bottomNavigationBar: navBar,
        body: Center(
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
                'Tutto fatto!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(title: 'Lista della Spesa'),
      bottomNavigationBar: navBar,
      body: ListView(
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
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.restaurant,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text(
              'Da Dieta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: sortedDiet.isNotEmpty
                ? Text(
                    '${sortedDiet.length} ${sortedDiet.length == 1 ? 'articolo' : 'articoli'}')
                : const Text('Tutto completo'),
            children: [
              Filter<DietItem>(
                controller: _dietFilterController,
                list: dietItems,
                filterBy: (item) => item.name,
                updateList: (resultItems) {
                  setState(() => _filteredDietItems = resultItems);
                },
              ),
              if (sortedDiet.isNotEmpty)
                ...sortedDiet.map((item) => ShoppingListDietItem(
                      item: item,
                      onUpdateDiet: (amount) {
                        ref.read(dietItemsProvider.notifier).edit(
                              item.copyWith(
                                  currentStock: item.currentStock + amount),
                            );
                      },
                    ))
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Nessun alimento da comprare!')),
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
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.local_pizza,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            title: const Text(
              'Spese Extra',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: pendingExtras.isNotEmpty
                ? Text(
                    '${pendingExtras.length} ${pendingExtras.length == 1 ? 'articolo' : 'articoli'}')
                : const Text('Tutto comprato'),
            children: [
              Filter<ExtraItem>(
                controller: _extraFilterController,
                list: extraItems,
                filterBy: (item) => item.name,
                updateList: (resultItems) {
                  setState(() => _filteredExtraItems = resultItems);
                },
              ),
              if (pendingExtras.isNotEmpty)
                ...pendingExtras.map((item) => ShoppingListExtraItem(
                      item: item,
                      onUpdateExtra: () {
                        ref.read(extraItemsProvider.notifier).edit(
                              item.copyWith(isBought: true),
                            );
                      },
                    ))
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Nessun extra da comprare!')),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
