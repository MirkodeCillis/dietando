import 'package:dietando/models/models.dart';
import 'package:dietando/services/import_export_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final SettingsData settings;
  final Function(SettingsData) onSettingsChanged;
  final List<ShoppingCategory> categories;
  final Function(List<ShoppingCategory>) onCategoriesChanged;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode _currentThemeMode;
  late List<ShoppingCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
    _currentThemeMode = widget.settings.themeMode == 'dark'
        ? ThemeMode.dark
        : widget.settings.themeMode == 'light' 
        ? ThemeMode.light
        : ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Categorie Lista della Spesa'),
          const SizedBox(height: 8),
          Text(
            'Ordina le categorie per priorità (trascina per riordinare)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesList(),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Categoria'),
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
          _buildThemeSelector(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle('Lingua'),
          const SizedBox(height: 16),
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Card(
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _categories.removeAt(oldIndex);
            _categories.insert(newIndex, item);
            
            for (int i = 0; i < _categories.length; i++) {
              _categories[i] = _categories[i].copyWith(priority: i);
            }
            
            widget.onCategoriesChanged(_categories);
          });
        },
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ReorderableDragStartListener(
            key: ValueKey(category.id),
            index: index,
            child: Card(
              key: ValueKey(category.id),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      onPressed: () => _showEditCategoryDialog(category, index),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _deleteCategory(index),
                    ),
                  ],
                ),
              ),
            )
          );
        },
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
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.upload_file,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('Esporta Dati'),
            subtitle: const Text('Salva i tuoi dati in un file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              bool res = await ImportExportService.export();
              if (ScaffoldMessenger.of(context).mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res ? 'Esportazione completata con successo' : 'C\'è stato un errore con l\'esportazione.'),
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
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.download,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Importa Dati'),
            subtitle: const Text('Carica dati da un file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              bool res = await ImportExportService.importFromFile();
              if (ScaffoldMessenger.of(context).mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res ? 'Importazione completata con successo' : 'C\'è stato un errore con l\'importazione.'),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      child: RadioGroup<ThemeMode>(
        groupValue: _currentThemeMode,
        onChanged: (value) {
          if (value != null) {
            widget.onSettingsChanged(SettingsData(
              themeMode: value == ThemeMode.dark ? 'dark' : value == ThemeMode.light ? 'light' : 'system',
              language: widget.settings.language
            ));
            setState(() {
              _currentThemeMode = value;
            });
          }
        },
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.zero),
              ),
              value: ThemeMode.system,
              title: const Text('Sistema'),
              subtitle: const Text('Segue le impostazioni del dispositivo'),
              secondary: const Icon(Icons.brightness_auto),
            ),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              title: const Text('Chiaro'),
              subtitle: const Text('Tema chiaro'),
              secondary: const Icon(Icons.light_mode),
            ),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(12)),
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

  Widget _buildLanguageSelector() {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        title: const Text('Lingua'),
        subtitle: const Text('Italiano'), // TODO: Dinamico
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Implementare selezione lingua
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funzionalità da implementare'),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog(null, null);
  }

  void _showEditCategoryDialog(ShoppingCategory category, int index) {
    _showCategoryDialog(category, index);
  }

  void _showCategoryDialog(ShoppingCategory? category, int? index) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                if (nameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inserisci un nome')),
                  );
                  return;
                }

                final newCategory = ShoppingCategory(
                  id: category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  priority: category?.priority ?? _categories.length,
                );

                setState(() {
                  if (index != null) {
                    _categories[index] = newCategory;
                  } else {
                    _categories.add(newCategory);
                  }
                  widget.onCategoriesChanged(_categories);
                });

                Navigator.pop(ctx);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(int index) {
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
              setState(() {
                _categories.removeAt(index);
                for (int i = 0; i < _categories.length; i++) {
                  _categories[i] = _categories[i].copyWith(priority: i);
                }
                widget.onCategoriesChanged(_categories);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}