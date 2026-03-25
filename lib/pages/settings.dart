import 'package:dietando/components/topbar.dart';
import 'package:dietando/models/models.dart';
import 'package:dietando/providers/categories_provider.dart';
import 'package:dietando/providers/settings_provider.dart';
import 'package:dietando/services/import_export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isCategoryReorderEnabled = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final categories = categoriesAsync.value ?? [];
    final settings = settingsAsync.value ?? SettingsData.defaultSettings;
    final currentThemeMode = settings.themeModeEnum;

    return Scaffold(
      appBar: AppTopBar(title: 'Impostazioni'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildSectionTitle('Categorie Lista della Spesa'),),
              IconButton(
                icon: _isCategoryReorderEnabled ? const Icon(Icons.check) : const Icon(Icons.edit),
                onPressed: () => setState(() => _isCategoryReorderEnabled = !_isCategoryReorderEnabled)
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ordina le categorie per priorità (trascina per riordinare)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesList(categories),
          const SizedBox(height: 8),
          Opacity(
            opacity: _isCategoryReorderEnabled ? 1.0 : 0.8,
            child: IgnorePointer(
              ignoring: !_isCategoryReorderEnabled,
              child: 
                FilledButton.tonalIcon(
                  onPressed: () => _showCategoryDialog(categories, null, null),
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi Categoria'),
                ),
            )
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle('Dati'),
          const SizedBox(height: 16),
          _buildDataManagementSection(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle('Aspetto'),
          const SizedBox(height: 16),
          _buildThemeSelector(currentThemeMode, settings),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle('Lingua'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      )
    );
  }

  Widget _buildCategoriesList(List<ShoppingCategory> categories) {
    return Opacity(
      opacity: _isCategoryReorderEnabled ? 1.0 : 0.8,
      child: IgnorePointer(
        ignoring: !_isCategoryReorderEnabled,
        child: Card(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              final reordered = List<ShoppingCategory>.from(categories);
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              final updated = [
                for (int i = 0; i < reordered.length; i++)
                  reordered[i].copyWith(priority: i),
              ];
              ref.read(categoriesProvider.notifier).reorder(updated);
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return ReorderableDragStartListener(
                key: ValueKey(category.id),
                index: index,
                enabled: _isCategoryReorderEnabled,
                child: Card(
                  key: ValueKey(category.id),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Text('Priorità: ${category.priority + 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _showCategoryDialog(categories, category, index),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Column(
      children: [
        Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.upload_file,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Esporta Dati'),
            subtitle: const Text('Salva i tuoi dati in un file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final res = await ImportExportService.export(ref);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res
                          ? 'Esportazione completata con successo'
                          : "C'è stato un errore con l'esportazione.",
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.download,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('Importa Dati'),
            subtitle: const Text('Carica dati da un file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final res = await ImportExportService.importFromFile(ref);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res
                          ? 'Importazione completata con successo'
                          : "C'è stato un errore con l'importazione.",
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeMode currentThemeMode, SettingsData settings) {
    return Card(
      child: RadioGroup<ThemeMode>(
        groupValue: currentThemeMode,
        onChanged: (value) {
          if (value != null) {
            final modeStr = value == ThemeMode.dark
                ? 'dark'
                : value == ThemeMode.light
                    ? 'light'
                    : 'system';
            ref.read(settingsProvider.notifier).setThemeMode(modeStr);
          }
        },
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.zero,
                ),
              ),
              value: ThemeMode.system,
              title: const Text('Sistema'),
              subtitle: const Text('Segue le impostazioni del dispositivo'),
              secondary: const Icon(Icons.brightness_auto),
            ),
            const Divider(height: 1),
            const RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              title: Text('Chiaro'),
              subtitle: Text('Tema chiaro'),
              secondary: Icon(Icons.light_mode),
            ),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(12),
                ),
              ),
              value: ThemeMode.dark,
              title: const Text('Scuro'),
              subtitle: const Text('Tema scuro'),
              secondary: const Icon(Icons.dark_mode),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(
    List<ShoppingCategory> categories,
    ShoppingCategory? category,
    int? index,
  ) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Nuova Categoria' : 'Modifica Categoria'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome Categoria',
                  hintText: 'Es. Frutta e Verdura',
                ),
              ),
              const SizedBox(height: 24),
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
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inserisci un nome')),
                );
                return;
              }

              final newCategory = ShoppingCategory(
                id: category?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text,
                priority: category?.priority ?? categories.length,
              );

              if (category == null) {
                ref.read(categoriesProvider.notifier).add(newCategory);
              } else {
                ref.read(categoriesProvider.notifier).edit(newCategory);
              }

              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(ShoppingCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Vuoi eliminare questa categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).delete(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
