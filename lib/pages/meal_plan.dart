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

class MealPlanPage extends ConsumerStatefulWidget {
  const MealPlanPage({super.key});

  @override
  ConsumerState<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends ConsumerState<MealPlanPage> {
  late DayOfWeek _selectedDay;
  final List<GlobalKey> _dayKeys =
      List.generate(DayOfWeek.values.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _selectedDay = DayOfWeek.values[DateTime.now().weekday - 1];
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    final ctx = _dayKeys[_selectedDay.index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.5, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealPlanAsync = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: AppTopBar(title: l10n.pageMealPlan),
      bottomNavigationBar: const AppNavBar(currentRoute: AppRoutes.mealPlan),
      body: mealPlanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.errorWithMessage(e.toString()))),
        data: (mealPlan) => Column(
          children: [
            _buildDaySelector(l10n),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: MealType.values
                    .map((mealType) =>
                        _buildMealSection(mealType, mealPlan, l10n))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(AppLocalizations l10n) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: DayOfWeek.values.length,
        itemBuilder: (context, index) {
          final day = DayOfWeek.values[index];
          final isSelected = day == _selectedDay;

          return Padding(
            key: _dayKeys[index],
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(day.l10nName(l10n)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedDay = day);
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToSelected());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealSection(
      MealType mealType, MealPlan mealPlan, AppLocalizations l10n) {
    final items = mealPlan.plan[_selectedDay]?[mealType] ?? [];
    final dietItems = ref.watch(dietItemsProvider).value ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.only(left: 8, right: 8, top: 4),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                mealType.icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              mealType.l10nName(l10n),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () =>
                      _showItemDialog(mealType, null, dietItems, l10n),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () =>
                      _consumeMeal(mealType, items, dietItems, l10n),
                  child: const Icon(Icons.dinner_dining, size: 18),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n.mealPlanNoItems,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...items.map((item) =>
                _buildMealItem(mealType, item, dietItems, l10n)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    MealType mealType,
    MealPlanItem item,
    List<DietItem> dietItems,
    AppLocalizations l10n,
  ) {
    final dietItem = dietItems.firstWhere(
      (di) => di.id == item.dietItemId,
      orElse: () => DietItem(
        id: '',
        name: l10n.mealPlanDeletedFood,
        description: '',
        weeklyTarget: 0,
        currentStock: 0,
        unit: Unit.Grammi,
        categoryId: '',
      ),
    );

    final progress = dietItem.weeklyTarget > 0
        ? ((dietItem.currentStock) / dietItem.weeklyTarget).clamp(0.0, 1.0)
        : 1.0;

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.restaurant,
        size: 20,
        color: progress < 0.3 || dietItem.currentStock < item.quantity
            ? Theme.of(context).colorScheme.error
            : progress < 0.7
                ? const Color.fromARGB(255, 227, 184, 170)
                : null,
      ),
      title: Text(dietItem.name),
      subtitle: Text(
          '${item.quantity.toStringAsFixed(0)} ${dietItem.unit.l10nName(l10n)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                _showEditItemDialog(mealType, item, dietItems, l10n),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _deleteItem(mealType, item, dietItems, l10n),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(
    MealType mealType,
    MealPlanItem? item,
    List<DietItem> dietItems,
    AppLocalizations l10n, {
    DietItem? preselected,
  }) {
    final FilterController filterController = FilterController();
    List<DietItem> filteredItems = [...dietItems];
    DietItem? selectedDietItem = preselected;

    if (item != null) {
      selectedDietItem = dietItems.firstWhere(
        (di) => di.id == item.dietItemId,
        orElse: () => dietItems.isNotEmpty ? dietItems.first : dietItems.first,
      );
    }

    final quantityCtrl = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              item == null ? l10n.mealPlanAddFood : l10n.mealPlanEditFood),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Filter<DietItem>(
                          controller: filterController,
                          list: dietItems,
                          filterBy: (item) => item.name,
                          updateList: (resultItems) {
                            setDialogState(() => filteredItems = resultItems);
                          },
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final di = filteredItems[index];
                              final isSelected =
                                  selectedDietItem?.id == di.id;
                              return Container(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.3)
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  title: Text(di.name),
                                  subtitle: Text(di.unit.l10nName(l10n)),
                                  onTap: () => setDialogState(
                                    () => selectedDietItem = di,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showCreateNewDietItemDialog(mealType, dietItems, l10n);
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.mealPlanCreateNewFood),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.fieldQuantity,
                    suffix: Text(
                        selectedDietItem?.unit.l10nName(l10n) ?? ''),
                  ),
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
                if (selectedDietItem == null ||
                    quantityCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.mealPlanSelectFoodAndQty),
                    ),
                  );
                  return;
                }

                final quantity =
                    double.tryParse(quantityCtrl.text) ?? 0;
                final prevQuantity = item?.quantity ?? 0;

                final updatedDietItem = selectedDietItem!.copyWith(
                  weeklyTarget:
                      selectedDietItem!.weeklyTarget + quantity - prevQuantity,
                );
                ref.read(dietItemsProvider.notifier).edit(updatedDietItem);

                final newItem = MealPlanItem(
                  id: item?.id ?? const Uuid().v4(),
                  dietItemId: selectedDietItem!.id,
                  quantity: quantity,
                );

                if (item != null) {
                  ref.read(mealPlanProvider.notifier).removeItem(
                        _selectedDay,
                        mealType,
                        item.id,
                      );
                }
                ref.read(mealPlanProvider.notifier).addItem(
                      _selectedDay,
                      mealType,
                      newItem,
                    );

                Navigator.pop(ctx);
              },
              child: Text(l10n.btnSave),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(
    MealType mealType,
    MealPlanItem item,
    List<DietItem> dietItems,
    AppLocalizations l10n,
  ) {
    _showItemDialog(mealType, item, dietItems, l10n);
  }

  void _showCreateNewDietItemDialog(
    MealType mealType,
    List<DietItem> dietItems,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    Unit selectedUnit = Unit.Grammi;
    final unitCtrl =
        TextEditingController(text: selectedUnit.l10nName(l10n));
    final categories = ref.read(categoriesProvider).value ?? [];
    ShoppingCategory selectedCategory =
        ShoppingCategory(id: '', name: l10n.mealPlanNoCategory, priority: 999);
    final categoryCtrl =
        TextEditingController(text: selectedCategory.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mealPlanNewFood),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.fieldName),
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
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.fieldDescription,
                  alignLabelWithHint: true,
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
                  if (category != null) {
                    selectedCategory = category;
                    categoryCtrl.text = category.name;
                  }
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
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n.settingsInsertName)),
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
                categoryId: selectedCategory.id,
              );

              ref.read(dietItemsProvider.notifier).add(newDietItem);

              Navigator.pop(ctx);

              Future.delayed(const Duration(milliseconds: 100), () {
                final updatedItems =
                    ref.read(dietItemsProvider).value ?? [];
                _showItemDialog(
                  mealType,
                  null,
                  updatedItems,
                  l10n,
                  preselected: newDietItem,
                );
              });
            },
            child: Text(l10n.mealPlanCreateAndSelect),
          ),
        ],
      ),
    );
  }

  void _deleteItem(
    MealType mealType,
    MealPlanItem item,
    List<DietItem> dietItems,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogConfirmTitle),
        content: Text(l10n.mealPlanDeleteFoodConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              final di = dietItems.firstWhere(
                (d) => d.id == item.dietItemId,
                orElse: () => DietItem(
                  id: '',
                  name: '',
                  description: '',
                  weeklyTarget: 0,
                  currentStock: 0,
                  unit: Unit.Grammi,
                  categoryId: '',
                ),
              );
              if (di.id.isNotEmpty) {
                final newTarget = (di.weeklyTarget - item.quantity)
                    .clamp(0.0, double.infinity);
                ref
                    .read(dietItemsProvider.notifier)
                    .edit(di.copyWith(weeklyTarget: newTarget));
              }

              ref.read(mealPlanProvider.notifier).removeItem(
                    _selectedDay,
                    mealType,
                    item.id,
                  );
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
  }

  void _consumeMeal(
    MealType mealType,
    List<MealPlanItem> items,
    List<DietItem> dietItems,
    AppLocalizations l10n,
  ) {
    if (items.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mealPlanConfirmConsumptionTitle),
        content: Text(l10n.mealPlanConfirmConsumptionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              for (final di in dietItems) {
                final mealItem = items.firstWhere(
                  (i) => i.dietItemId == di.id,
                  orElse: () =>
                      MealPlanItem(id: '', dietItemId: '', quantity: 0),
                );
                if (mealItem.id.isNotEmpty) {
                  final newStock = di.currentStock - mealItem.quantity;
                  ref.read(dietItemsProvider.notifier).edit(
                        di.copyWith(
                            currentStock: newStock < 0 ? 0 : newStock),
                      );
                }
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnConfirm),
          ),
        ],
      ),
    );
  }
}
