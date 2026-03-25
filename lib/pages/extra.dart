import 'package:dietando/components/filter.dart';
import 'package:dietando/components/navbar.dart';
import 'package:dietando/components/topbar.dart';
import 'package:dietando/models/models.dart';
import 'package:dietando/providers/extra_items_provider.dart';
import 'package:dietando/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ExtraPage extends ConsumerStatefulWidget {
  const ExtraPage({super.key});

  @override
  ConsumerState<ExtraPage> createState() => _ExtraPageState();
}

class _ExtraPageState extends ConsumerState<ExtraPage> {
  List<ExtraItem> _filteredItems = [];
  final FilterController _filterController = FilterController();

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(extraItemsProvider);

    final items = itemsAsync.valueOrNull;

    return Scaffold(
      appBar: AppTopBar(title: 'Spese Extra'),
      bottomNavigationBar: const AppNavBar(currentRoute: AppRoutes.extra),
      floatingActionButton: items != null
          ? FloatingActionButton.extended(
              onPressed: () => _showItemDialog(context, null, items),
              label: const Text('Aggiungi'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (items) {
          final displayItems = (_filterController.isFiltering ? _filteredItems : items)
              .map((fi) => items.firstWhere((i) => i.id == fi.id,
                  orElse: () => fi))
              .toList();

          return items.isEmpty
              ? const Center(child: Text('Nessuna spesa extra da fare.'))
              : Column(
                  children: [
                    Filter<ExtraItem>(
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
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  _showItemDialog(context, item, items),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 16),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: item.isBought,
                                    onChanged: (v) {
                                      if (v != null) {
                                        ref
                                            .read(extraItemsProvider.notifier)
                                            .edit(item.copyWith(isBought: v));
                                      }
                                    },
                                  ),
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      decoration: item.isBought
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isBought
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null,
                                    ),
                                  ),
                                  subtitle: item.quantity != null
                                      ? Text('Quantità: ${item.quantity}')
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showItemDialog(context, item, items),
                                  ),
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
    ExtraItem? item,
    List<ExtraItem> allItems,
  ) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl =
        TextEditingController(text: item?.quantity?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item == null ? 'Nuovo Articolo' : 'Modifica Articolo'),
            if (item != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  ref.read(extraItemsProvider.notifier).delete(item.id);
                  _filterController.reset();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantità'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
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
                ref.read(extraItemsProvider.notifier).add(newItem);
              } else {
                ref.read(extraItemsProvider.notifier).edit(newItem);
              }
              _filterController.reset();
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
