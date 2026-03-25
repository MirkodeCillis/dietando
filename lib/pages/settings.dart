import 'package:dietando/components/topbar.dart';
import 'package:dietando/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final categories = categoriesAsync.value ?? [];
    final settings = settingsAsync.value ?? SettingsData.defaultSettings;
    final currentThemeMode = settings.themeModeEnum;

    return Scaffold(
      appBar: AppTopBar(title: l10n.pageSettings),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildSectionTitle(l10n.settingsCategoriesTitle)),
              IconButton(
                icon: _isCategoryReorderEnabled
                    ? const Icon(Icons.check)
                    : const Icon(Icons.edit),
                onPressed: () => setState(
                    () => _isCategoryReorderEnabled = !_isCategoryReorderEnabled),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsCategoriesHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesList(categories, l10n),
          const SizedBox(height: 8),
          Opacity(
            opacity: _isCategoryReorderEnabled ? 1.0 : 0.8,
            child: IgnorePointer(
              ignoring: !_isCategoryReorderEnabled,
              child: FilledButton.tonalIcon(
                onPressed: () => _showCategoryDialog(categories, null, null, l10n),
                icon: const Icon(Icons.add),
                label: Text(l10n.settingsAddCategory),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle(l10n.settingsDataTitle),
          const SizedBox(height: 16),
          _buildDataManagementSection(l10n),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle(l10n.settingsAppearance),
          const SizedBox(height: 16),
          _buildThemeSelector(currentThemeMode, settings, l10n),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _buildSectionTitle(l10n.settingsLanguageTitle),
          const SizedBox(height: 16),
          _buildLanguageSelector(settings, l10n),

          const SizedBox(height: 32),
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

  Widget _buildCategoriesList(
      List<ShoppingCategory> categories, AppLocalizations l10n) {
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
                    subtitle:
                        Text(l10n.settingsPriority(category.priority + 1)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showCategoryDialog(
                              categories, category, index, l10n),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteCategory(category, l10n),
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

  Widget _buildDataManagementSection(AppLocalizations l10n) {
    return Column(
      children: [
        Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.upload_file,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: Text(l10n.settingsExport),
            subtitle: Text(l10n.settingsExportSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final res = await ImportExportService.export(ref);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res ? l10n.settingsExportSuccess : l10n.settingsExportError,
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
            title: Text(l10n.settingsImport),
            subtitle: Text(l10n.settingsImportSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final res = await ImportExportService.importFromFile(ref);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res ? l10n.settingsImportSuccess : l10n.settingsImportError,
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

  Widget _buildThemeSelector(
      ThemeMode currentThemeMode, SettingsData settings, AppLocalizations l10n) {
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
              title: Text(l10n.settingsThemeSystem),
              subtitle: Text(l10n.settingsThemeSystemSubtitle),
              secondary: const Icon(Icons.brightness_auto),
            ),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              title: Text(l10n.settingsThemeLight),
              subtitle: Text(l10n.settingsThemeLightSubtitle),
              secondary: const Icon(Icons.light_mode),
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
              title: Text(l10n.settingsThemeDark),
              subtitle: Text(l10n.settingsThemeDarkSubtitle),
              secondary: const Icon(Icons.dark_mode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsData settings, AppLocalizations l10n) {
    final languages = [
      ('it', l10n.languageItalian, '🇮🇹'),
      ('en', l10n.languageEnglish, '🇬🇧'),
      ('es', l10n.languageSpanish, '🇪🇸'),
      ('fr', l10n.languageFrench, '🇫🇷'),
      ('de', l10n.languageGerman, '🇩🇪'),
    ];

    return Card(
      child: Column(
        children: [
          for (int i = 0; i < languages.length; i++) ...[
            RadioListTile<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(12) : Radius.zero,
                  bottom: i == languages.length - 1
                      ? const Radius.circular(12)
                      : Radius.zero,
                ),
              ),
              value: languages[i].$1,
              groupValue: settings.language,
              title: Text(languages[i].$2),
              secondary: Text(
                languages[i].$3,
                style: const TextStyle(fontSize: 24),
              ),
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                }
              },
            ),
            if (i < languages.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  void _showCategoryDialog(
    List<ShoppingCategory> categories,
    ShoppingCategory? category,
    int? index,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null
            ? l10n.settingsNewCategory
            : l10n.settingsEditCategory),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.settingsCategoryNameLabel,
                  hintText: l10n.settingsCategoryNameHint,
                ),
              ),
              const SizedBox(height: 24),
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
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsInsertName)),
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
            child: Text(l10n.btnSave),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(ShoppingCategory category, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogConfirmTitle),
        content: Text(l10n.settingsDeleteCategoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).delete(category.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
  }
}
